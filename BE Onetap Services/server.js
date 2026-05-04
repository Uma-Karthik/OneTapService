const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const http = require('http');
const { Server } = require('socket.io');
require('dotenv').config();

// Validate required environment variables
const requiredEnvVars = ['JWT_SECRET', 'MONGODB_URI'];
requiredEnvVars.forEach(envVar => {
    if (!process.env[envVar]) {
        console.error(`❌ Missing required environment variable: ${envVar}`);
        process.exit(1);
    }
});

const app = express();
const server = http.createServer(app);

// CORS Configuration - More flexible for development
const isDevelopment = process.env.NODE_ENV !== 'production';
const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000', 'http://localhost:8080', 'http://localhost:5000'];
const corsOptions = {
    origin: (origin, callback) => {
        // In development, allow all origins; in production, check against list
        if (isDevelopment || !origin || allowedOrigins.some(allowed => origin.includes(allowed))) {
            callback(null, true);
        } else {
            callback(new Error('CORS not allowed'));
        }
    },
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    credentials: true,
    optionsSuccessStatus: 200,
};

const io = new Server(server, {
    cors: corsOptions,
});

// Middleware
app.use(cors(corsOptions));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const parseNumberEnv = (value, fallback) => {
    const parsed = Number(value);
    return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
};

const isPrivateOrLoopbackIp = (ipAddress = '') => {
    const ip = String(ipAddress);
    return (
        ip === '::1' ||
        ip === '127.0.0.1' ||
        ip.startsWith('::ffff:127.') ||
        ip.startsWith('10.') ||
        ip.startsWith('192.168.') ||
        /^172\.(1[6-9]|2[0-9]|3[0-1])\./.test(ip)
    );
};

const shouldSkipLimiter = (req) => {
    if (req.method === 'OPTIONS') return true;
    if (!isDevelopment) return false;
    return isPrivateOrLoopbackIp(req.ip) || isPrivateOrLoopbackIp(req.socket?.remoteAddress);
};

// Rate Limiting
const limiter = rateLimit({
    windowMs: parseNumberEnv(process.env.RATE_LIMIT_WINDOW_MS, 15 * 60 * 1000),
    max: parseNumberEnv(process.env.RATE_LIMIT_MAX, isDevelopment ? 2000 : 100),
    // Auth routes already have dedicated limiters, so don't count them twice.
    skip: (req) =>
        shouldSkipLimiter(req) ||
        req.path.startsWith('/api/auth/login') ||
        req.path.startsWith('/api/auth/signup'),
    message: { error: 'Too many requests from this IP, please try again later.' },
    standardHeaders: true,
    legacyHeaders: false,
});

const createAuthLimiter = (actionLabel) => rateLimit({
    windowMs: parseNumberEnv(process.env.AUTH_RATE_LIMIT_WINDOW_MS, 15 * 60 * 1000),
    max: parseNumberEnv(process.env.AUTH_RATE_LIMIT_MAX, isDevelopment ? 50 : 5),
    skipSuccessfulRequests: true, // only failed attempts are counted
    skip: (req) => shouldSkipLimiter(req),
    message: { error: `Too many ${actionLabel} attempts, please try again later.` },
    standardHeaders: true,
    legacyHeaders: false,
});

const loginLimiter = createAuthLimiter('login');
const signupLimiter = createAuthLimiter('signup');

app.use(limiter);

// Error Handler Middleware
const errorHandler = require('./middleware/errorHandler');

// Socket.io (Real-time)
io.on('connection', (socket) => {
    console.log('✅ User connected:', socket.id);

    socket.on('join_room', (data) => {
        const roomId = data.userId || data.providerId;
        if (roomId) {
            socket.join(roomId);
            console.log(`✅ User ${socket.id} joined room: ${roomId}`);
        }
    });

    socket.on('disconnect', () => {
        console.log('❌ User disconnected:', socket.id);
    });

    socket.on('error', (error) => {
        console.error('Socket error:', error);
    });
});

// Make io accessible in routes
app.set('io', io);

// Basic Route
app.get('/', (req, res) => {
    res.json({
        message: 'OneTap HomeServices API is running...',
        status: 'online',
        timestamp: new Date().toISOString()
    });
});

// Health Check
app.get('/health', (req, res) => {
    const dbConnected = mongoose.connection.readyState === 1;
    res.status(dbConnected ? 200 : 503).json({
        status: dbConnected ? 'healthy' : 'unhealthy',
        database: dbConnected ? 'connected' : 'disconnected',
        timestamp: new Date().toISOString()
    });
});

// Routes with rate limiting for auth
app.use('/api/auth/login', loginLimiter);
app.use('/api/auth/signup', signupLimiter);
app.use('/api/auth', require('./routes/auth'));
app.use('/api/providers', require('./routes/providers'));
app.use('/api/services', require('./routes/services'));
app.use('/api/bookings', require('./routes/bookings'));

// Database Connection with Retry Logic
const MONGODB_URI = process.env.MONGODB_URI;
const connectDB = async () => {
    try {
        await mongoose.connect(MONGODB_URI, {
            retryWrites: true,
            w: 'majority',
            serverSelectionTimeoutMS: 5000,
        });
        console.log('✅ Successfully connected to MongoDB');
        console.log(`📍 Database: ${mongoose.connection.name}`);
    } catch (err) {
        console.error('❌ MongoDB connection error:', err.message);
        console.log('🔄 Retrying connection in 5 seconds...');
        setTimeout(connectDB, 5000);
    }
};

// Handle MongoDB connection events
mongoose.connection.on('connected', () => {
    console.log('✅ Mongoose connected to MongoDB');
});

mongoose.connection.on('error', (err) => {
    console.error('❌ Mongoose connection error:', err);
});

mongoose.connection.on('disconnected', () => {
    console.log('⚠️  Mongoose disconnected from MongoDB');
});

// 404 Handler
app.use((req, res) => {
    res.status(404).json({ error: 'Route not found' });
});

// Global Error Handler (must be last)
app.use(errorHandler);

// Connect to Database
connectDB();

// Start Server
const PORT = process.env.PORT || 5000;
server.listen(PORT, () => {
    console.log(`\n🚀 Server is running on port ${PORT}`);
    console.log(`🌐 Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log(`📡 Socket.io is active`);
    console.log(`\nAPI Base URL: http://localhost:${PORT}`);
    console.log(`Health Check: http://localhost:${PORT}/health\n`);
});

// Graceful Shutdown
process.on('SIGINT', async () => {
    console.log('\n⏹️  Server shutting down...');
    await mongoose.connection.close();
    server.close(() => {
        console.log('✅ Server closed');
        process.exit(0);
    });
});

