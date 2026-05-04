const express = require('express');
const router = express.Router();
const Provider = require('../models/Provider');
const User = require('../models/User');
const Service = require('../models/Service');
const authMiddleware = require('../middleware/authMiddleware');
const { providerUpdateValidation } = require('../middleware/validation');

// Get All Providers
router.get('/', async (req, res, next) => {
    try {
        const providers = await Provider.find()
            .populate('userId', 'name email phone')
            .populate('serviceIds')
            .sort({ createdAt: -1 });
        
        res.json({
            count: providers.length,
            providers
        });
    } catch (err) {
        next(err);
    }
});

// Get Current User's Provider Profile (must be before /:id)
router.get('/profile/me', authMiddleware, async (req, res, next) => {
    try {
        if (req.user.role !== 'provider') {
            return res.status(403).json({ error: 'Only providers can access this endpoint' });
        }

        const provider = await Provider.findOne({ userId: req.user.id })
            .populate('userId', 'name email phone')
            .populate('serviceIds');

        if (!provider) {
            return res.status(404).json({ error: 'Provider profile not found' });
        }

        res.json(provider);
    } catch (err) {
        next(err);
    }
});

// Get Provider by User ID (must be before /:id)
router.get('/user/:userId', async (req, res, next) => {
    try {
        // Verify user exists
        const user = await User.findById(req.params.userId);
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        const provider = await Provider.findOne({ userId: req.params.userId })
            .populate('userId', 'name email phone')
            .populate('serviceIds');

        if (!provider) {
            return res.status(404).json({ error: 'Provider profile not found' });
        }

        res.json(provider);
    } catch (err) {
        next(err);
    }
});

// Get Provider by ID
router.get('/:id', async (req, res, next) => {
    try {
        const provider = await Provider.findById(req.params.id)
            .populate('userId', 'name email phone address')
            .populate('serviceIds');
        
        if (!provider) {
            return res.status(404).json({ error: 'Provider not found' });
        }

        res.json(provider);
    } catch (err) {
        next(err);
    }
});

// Update Provider Profile
router.put('/:id', authMiddleware, providerUpdateValidation, async (req, res, next) => {
    try {
        // Verify authorization
        const provider = await Provider.findById(req.params.id);
        if (!provider) {
            return res.status(404).json({ error: 'Provider not found' });
        }

        if (provider.userId.toString() !== req.user.id) {
            return res.status(403).json({ error: 'Unauthorized. You can only update your own profile.' });
        }

        const updatedProvider = await Provider.findByIdAndUpdate(
            req.params.id,
            { ...req.body, updatedAt: new Date() },
            { new: true, runValidators: true }
        ).populate('userId', 'name email phone')
         .populate('serviceIds');

        console.log(`✅ Provider ${req.params.id} updated`);

        res.json({
            message: 'Provider profile updated successfully',
            provider: updatedProvider
        });
    } catch (err) {
        next(err);
    }
});

// Get Provider Statistics
router.get('/stats/:id', authMiddleware, async (req, res, next) => {
    try {
        const provider = await Provider.findById(req.params.id);
        if (!provider) {
            return res.status(404).json({ error: 'Provider not found' });
        }

        if (provider.userId.toString() !== req.user.id) {
            return res.status(403).json({ error: 'Unauthorized' });
        }

        const services = await Service.countDocuments({ providerId: req.params.id });
        const bookings = await require('../models/Booking').countDocuments({ providerId: req.params.id });

        res.json({
            providerId: provider._id,
            companyName: provider.companyName,
            totalServices: services,
            totalBookings: bookings,
            rating: provider.rating,
            reviewCount: provider.reviewCount,
            isAvailable: provider.isAvailable,
            joinedDate: provider.createdAt
        });
    } catch (err) {
        next(err);
    }
});

module.exports = router;
