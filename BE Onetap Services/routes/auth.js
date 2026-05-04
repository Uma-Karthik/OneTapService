const express = require('express');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Provider = require('../models/Provider');
const { signupValidation, loginValidation } = require('../middleware/validation');

const router = express.Router();

// Signup
router.post('/signup', signupValidation, async (req, res, next) => {
    try {
        const { name, email, phone, address, password, role, companyName } = req.body;

        const normalizedEmail = String(email).trim().toLowerCase();
        const trimmedName = String(name).trim();

        // Check if user exists
        const existingUser = await User.findOne({ email: normalizedEmail });
        if (existingUser) {
            return res.status(400).json({ error: 'Email already registered' });
        }

        // Create user
        const user = new User({
            name: trimmedName,
            email: normalizedEmail,
            phone: String(phone).trim(),
            address: String(address).trim(),
            password,
            role,
        });
        await user.save();

        console.log(`User registered: ${normalizedEmail} (${role})`);

        // If provider, create provider profile
        if (role === 'provider') {
            const provider = new Provider({
                userId: user._id,
                companyName: companyName ? String(companyName).trim() : `${trimmedName}'s Services`,
            });
            await provider.save();
            console.log(`Provider profile created for: ${normalizedEmail}`);
        }

        // Generate token with user info
        const token = jwt.sign(
            {
                id: user._id,
                name: user.name,
                email: user.email,
                role: user.role,
            },
            process.env.JWT_SECRET,
            { expiresIn: '7d' }
        );

        res.status(201).json({
            message: 'Registration successful',
            token,
            user: {
                id: user._id,
                name: user.name,
                email: user.email,
                role: user.role,
                phone: user.phone,
                address: user.address,
            },
        });
    } catch (err) {
        next(err);
    }
});

// Login
router.post('/login', loginValidation, async (req, res, next) => {
    try {
        const { email, password, role } = req.body;
        const normalizedEmail = String(email).trim().toLowerCase();

        // Find user
        const user = await User.findOne({ email: normalizedEmail });
        if (!user) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        // Check role match
        if (user.role !== role) {
            return res.status(401).json({ error: `Invalid role. This account is registered as '${user.role}'` });
        }

        // Compare password
        const isMatch = await user.comparePassword(password);
        if (!isMatch) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        console.log(`User logged in: ${normalizedEmail}`);

        // Generate token with user info
        const token = jwt.sign(
            {
                id: user._id,
                name: user.name,
                email: user.email,
                role: user.role,
            },
            process.env.JWT_SECRET,
            { expiresIn: '7d' }
        );

        res.json({
            message: 'Login successful',
            token,
            user: {
                id: user._id,
                name: user.name,
                email: user.email,
                phone: user.phone,
                address: user.address,
                role: user.role,
            },
        });
    } catch (err) {
        next(err);
    }
});

// Get all users (for admin dashboard)
router.get('/users/all', async (req, res, next) => {
    try {
        const users = await User.find({}, '-password');
        res.json({
            total: users.length,
            users: users
        });
    } catch (err) {
        next(err);
    }
});

// Delete user by ID
router.delete('/users/:userId', async (req, res, next) => {
    try {
        const { userId } = req.params;
        
        const user = await User.findByIdAndDelete(userId);
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        console.log(`User deleted: ${user.email}`);
        
        res.json({
            message: 'User deleted successfully',
            deletedUser: user.email
        });
    } catch (err) {
        next(err);
    }
});

module.exports = router;
