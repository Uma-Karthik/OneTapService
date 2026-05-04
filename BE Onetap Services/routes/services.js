const express = require('express');
const router = express.Router();
const Service = require('../models/Service');
const Provider = require('../models/Provider');
const authMiddleware = require('../middleware/authMiddleware');
const { serviceValidation } = require('../middleware/validation');

// Get All Services
router.get('/', async (req, res, next) => {
    try {
        const { category, minPrice, maxPrice, providerId, q } = req.query;
        let filter = {};

        if (category) filter.category = category;
        if (providerId) filter.providerId = providerId;
        if (minPrice || maxPrice) {
            filter.price = {};
            if (minPrice) filter.price.$gte = parseFloat(minPrice);
            if (maxPrice) filter.price.$lte = parseFloat(maxPrice);
        }
        if (q && String(q).trim()) {
            const escaped = String(q).trim().replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
            const searchRegex = new RegExp(escaped, 'i');
            filter.$or = [
                { name: searchRegex },
                { category: searchRegex },
                { description: searchRegex },
            ];
        }

        const services = await Service.find(filter)
            .populate('providerId', 'companyName userId isAvailable rating reviewCount')
            .sort({ createdAt: -1 });
        
        res.json({
            count: services.length,
            services
        });
    } catch (err) {
        next(err);
    }
});

// Get Services by Provider
router.get('/provider/:providerId', async (req, res, next) => {
    try {
        const services = await Service.find({ providerId: req.params.providerId })
            .populate('providerId', 'companyName userId isAvailable rating reviewCount')
            .sort({ createdAt: -1 });
        
        if (!services.length) {
            return res.json({
                message: 'No services found for this provider',
                services: []
            });
        }

        res.json({
            count: services.length,
            services
        });
    } catch (err) {
        next(err);
    }
});

// Create Service (Provider Only)
router.post('/', authMiddleware, serviceValidation, async (req, res, next) => {
    try {
        if (req.user.role !== 'provider') {
            return res.status(403).json({ error: 'Only providers can create services' });
        }

        const provider = await Provider.findOne({ userId: req.user.id });
        if (!provider) {
            return res.status(404).json({ error: 'Provider profile not found. Please complete your provider registration.' });
        }

        // Check for duplicate service name per provider
        const existingService = await Service.findOne({
            providerId: provider._id,
            name: req.body.name
        });

        if (existingService) {
            return res.status(400).json({ error: 'You already have a service with this name' });
        }

        const service = new Service({
            ...req.body,
            providerId: provider._id,
        });
        
        await service.save();

        // Link service to provider
        provider.serviceIds.push(service._id);
        await provider.save();

        console.log(`✅ Service created: ${service._id} by provider ${provider._id}`);

        res.status(201).json({
            message: 'Service created successfully',
            service
        });
    } catch (err) {
        next(err);
    }
});

// Get Single Service
router.get('/:id', async (req, res, next) => {
    try {
        const service = await Service.findById(req.params.id)
            .populate('providerId', 'companyName userId description rating');

        if (!service) {
            return res.status(404).json({ error: 'Service not found' });
        }

        res.json(service);
    } catch (err) {
        next(err);
    }
});

 // Update Service
router.put('/:id', authMiddleware, serviceValidation, async (req, res, next) => {
    try {
        const service = await Service.findById(req.params.id);
        if (!service) {
            return res.status(404).json({ error: 'Service not found' });
        }

        const provider = await Provider.findOne({ userId: req.user.id });
        if (!provider || service.providerId.toString() !== provider._id.toString()) {
            return res.status(403).json({ error: 'Unauthorized. You can only edit your own services.' });
        }

        // Check for duplicate service name if name is being changed
        if (req.body.name && req.body.name !== service.name) {
            const existingService = await Service.findOne({
                providerId: provider._id,
                name: req.body.name,
                _id: { $ne: service._id }
            });

            if (existingService) {
                return res.status(400).json({ error: 'You already have a service with this name' });
            }
        }

        Object.assign(service, req.body);
        await service.save();

        console.log(`✅ Service updated: ${service._id}`);

        res.json({
            message: 'Service updated successfully',
            service
        });
    } catch (err) {
        next(err);
    }
});

// Delete Service
router.delete('/:id', authMiddleware, async (req, res, next) => {
    try {
        const service = await Service.findById(req.params.id);
        if (!service) {
            return res.status(404).json({ error: 'Service not found' });
        }

        const provider = await Provider.findOne({ userId: req.user.id });
        if (!provider || service.providerId.toString() !== provider._id.toString()) {
            return res.status(403).json({ error: 'Unauthorized. You can only delete your own services.' });
        }

        await Service.findByIdAndDelete(req.params.id);

        // Remove from provider's list
        provider.serviceIds = provider.serviceIds.filter(id => id.toString() !== req.params.id);
        await provider.save();

        console.log(`✅ Service deleted: ${req.params.id}`);

        res.json({ message: 'Service deleted successfully' });
    } catch (err) {
        next(err);
    }
});

module.exports = router;
