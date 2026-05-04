# Backend Fixes & Setup Guide

## ✅ All 11 Bugs Fixed

### 1. **Environment Variable Validation** ✓
- Added validation for required env vars (JWT_SECRET, MONGODB_URI)
- Server now exits gracefully if missing env vars
- Added error logging for configuration issues

### 2. **Socket.io Room Management** ✓
- Improved `join_room` handler to properly construct room IDs
- Added validation for socket events
- Added error handling for socket operations

### 3. **JWT Token with User Info** ✓
- JWT now includes: `id`, `name`, `email`, `role`
- User name is properly included in token payload
- Token expiration properly handled

### 4. **Input Validation** ✓
- Created comprehensive validation middleware using `express-validator`
- Validates: email format, password strength, phone numbers, dates, prices
- Custom validation errors with details
- Applies to all POST/PUT routes

### 5. **CORS Security** ✓
- Restricted CORS to specific origins (configurable via env)
- Default origins: `http://localhost:3000`, `http://localhost:8080`
- Can be customized with `ALLOWED_ORIGINS` env var

### 6. **Password Strength Requirements** ✓
- Minimum 6 characters
- Must contain at least one uppercase letter (A-Z)
- Must contain at least one number (0-9)
- Validated before saving to database

### 7. **Role-Based Authorization** ✓
- Proper status transition rules:
  - `pending` → `accepted`, `rejected`, `cancelled`
  - `accepted` → `completed`, `cancelled`
  - `completed` → no transitions
- Only providers can accept/reject
- Only customers can cancel
- Comprehensive authorization checks

### 8. **Entity Verification** ✓
- All booking creations verify provider, service, and customer exist
- Service belongs to correct provider
- Booking date is in future
- Prevents orphaned records

### 9. **Rate Limiting** ✓
- Implemented express-rate-limit
- General rate limit: 100 requests per 15 minutes
- Auth rate limit: 5 requests per 15 minutes (login/signup)
- Per-IP basis for security

### 10. **Error Handling Middleware** ✓
- Global error handler catches all routing errors
- Proper HTTP status codes
- Handles DB validation errors
- Handles JWT errors
- Prevents unhandled promise rejections
- Meaningful error messages

### 11. **Duplicate Service Prevention** ✓
- Checks for duplicate service names per provider
- Validates during create and update operations
- Uses MongoDB indexes for performance

---

## 🗄️ Database Setup

### Start MongoDB

**Windows - Using MongoDB Community Edition:**

1. Install MongoDB from: https://www.mongodb.com/try/download/community
2. Or use MongoDB Atlas (Cloud):
   - Create account at https://www.mongodb.com/cloud/atlas
   - Create a cluster
   - Get connection string
   - Update `.env` with connection string

**Using MongoDB Atlas (Recommended for production):**
```
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/home_services?retryWrites=true&w=majority
```

**Using Local MongoDB:**
```
mongod  # Start MongoDB server first
```

---

## 📦 Installation & Running

### Install Dependencies
```bash
cd backend
npm install
```

### Start Server
```bash
npm start
```

Server will run on `http://localhost:5000`

---

## ✅ Testing the API

### 1. **Health Check**
```bash
curl http://localhost:5000/health
```

**Expected Response:**
```json
{
  "status": "healthy",
  "database": "connected",
  "timestamp": "2026-02-25T...",
}
```

### 2. **User Signup**
```bash
curl -X POST http://localhost:5000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "SecurePass123",
    "phone": "+1234567890",
    "address": "123 Main St",
    "role": "customer"
  }'
```

**Expected Response:**
```json
{
  "message": "Registration successful",
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "...",
    "name": "John Doe",
    "email": "john@example.com",
    "role": "customer",
    "phone": "+1234567890",
    "address": "123 Main St"
  }
}
```

### 3. **User Login**
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "SecurePass123",
    "role": "customer"
  }'
```

### 4. **Create Service (Provider Only)**

First, signup as provider:
```bash
curl -X POST http://localhost:5000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jane Provider",
    "email": "jane@example.com",
    "password": "ProviderPass123",
    "phone": "+1987654321",
    "address": "456 Provider Lane",
    "role": "provider",
    "companyName": "Jane Cleaning Services"
  }'
```

Then create service with token:
```bash
curl -X POST http://localhost:5000/api/services \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "name": "House Cleaning",
    "description": "Professional house cleaning",
    "category": "Cleaning",
    "price": 50.00,
    "duration": "2 hours"
  }'
```

### 5. **Create Booking (Customer)**
```bash
curl -X POST http://localhost:5000/api/bookings \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer CUSTOMER_TOKEN" \
  -d '{
    "providerId": "PROVIDER_ID",
    "serviceId": "SERVICE_ID",
    "serviceName": "House Cleaning",
    "providerName": "Jane Cleaning Services",
    "dateTime": "2026-03-01T10:00:00Z",
    "price": 50.00,
    "address": "789 Customer Street"
  }'
```

---

## 📝 Security Features Implemented

✅ Password hashing with bcryptjs
✅ JWT authentication with expiration
✅ Role-based access control
✅ Input validation & sanitization
✅ Rate limiting on auth endpoints
✅ CORS security restrictions
✅ Error handling without exposing internals
✅ MongoDB connection retry logic
✅ Graceful shutdown handling
✅ Environment variable validation
✅ SQL injection prevention (using Mongoose)
✅ Authorization checks on all protected routes

---

## 🚀 Production Deployment

Before deploying to production:

1. **Update .env:**
   - Set `NODE_ENV=production`
   - Use secure JWT_SECRET (min 32 characters)
   - Use MongoDB Atlas connection string
   - Set specific ALLOWED_ORIGINS
   - Update CORS settings

2. **Enable HTTPS**: Use reverse proxy (nginx/Apache) or AWS/Heroku

3. **Database Backups**: Enable MongoDB Atlas backups

4. **Monitoring**: Set up error logging (Sentry, LogRocket)

5. **Rate Limiting**: Increase limits based on expected traffic

6. **Environment Variables**: Use secrets manager (AWS Secrets Manager, Google Cloud Secret Manager)

---

## 📊 API Endpoints Summary

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/auth/signup` | ❌ | Register user |
| POST | `/api/auth/login` | ❌ | Login user |
| GET | `/api/providers` | ❌ | Get all providers |
| GET | `/api/providers/:id` | ❌ | Get provider by ID |
| GET | `/api/providers/profile/me` | ✅ | Get current provider profile |
| PUT | `/api/providers/:id` | ✅ | Update provider profile |
| GET | `/api/services` | ❌ | Get all services |
| POST | `/api/services` | ✅ | Create service (provider) |
| PUT | `/api/services/:id` | ✅ | Update service |
| DELETE | `/api/services/:id` | ✅ | Delete service |
| POST | `/api/bookings` | ✅ | Create booking |
| GET | `/api/bookings/customer` | ✅ | Get customer bookings |
| GET | `/api/bookings/provider` | ✅ | Get provider bookings |
| PUT | `/api/bookings/:id/status` | ✅ | Update booking status |

---

## 🐛 Validation Error Examples

### Weak Password:
```json
{
  "error": "Validation failed",
  "details": [
    {
      "msg": "Password must contain at least one uppercase letter",
      "param": "password"
    }
  ]
}
```

### Invalid Email:
```json
{
  "error": "Validation failed",
  "details": [
    {
      "msg": "Invalid email format",
      "param": "email"
    }
  ]
}
```

### Duplicate Service:
```json
{
  "error": "You already have a service with this name"
}
```

---

## 📞 Support

All errors are logged to console. In production, integrate with error tracking service (Sentry, LogRocket).

**Console logs include:**
- ✅ Successful database connections
- ✅ User registrations/logins
- ✅ Booking creations & updates
- ✅ Service CRUD operations
- ❌ Connection errors
- ❌ Validation errors
- ❌ Authorization failures

---

**Backend is now production-ready! 🎉**
