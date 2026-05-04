const express = require('express');
const router = express.Router();
const Booking = require('../models/Booking');
const Provider = require('../models/Provider');
const Service = require('../models/Service');
const User = require('../models/User');
const authMiddleware = require('../middleware/authMiddleware');
const {
    bookingValidation,
    bookingStatusValidation,
    feedbackValidation,
} = require('../middleware/validation');

// Get Bookings for Current User (Customer)
router.get('/customer', authMiddleware, async (req, res, next) => {
    try {
        const bookings = await Booking.find({ customerId: req.user.id })
            .populate('providerId', 'companyName isAvailable')
            .populate('serviceId', 'name category price')
            .sort({ createdAt: -1 });

        res.json({
            count: bookings.length,
            bookings,
        });
    } catch (err) {
        next(err);
    }
});

// Get Bookings for Current Provider
router.get('/provider', authMiddleware, async (req, res, next) => {
    try {
        const provider = await Provider.findOne({ userId: req.user.id });
        if (!provider) {
            return res.status(404).json({ error: 'Provider profile not found' });
        }

        const bookings = await Booking.find({ providerId: provider._id })
            .populate('customerId', 'name phone address')
            .populate('serviceId', 'name category price')
            .sort({ createdAt: -1 });

        res.json({
            count: bookings.length,
            bookings,
        });
    } catch (err) {
        next(err);
    }
});

// Create Booking
router.post('/', authMiddleware, bookingValidation, async (req, res, next) => {
    try {
        const {
            providerId,
            serviceId,
            dateTime,
            price,
            address,
            specialInstructions,
        } = req.body;

        console.log('BOOKING create request', {
            userId: req.user?.id,
            role: req.user?.role,
            providerId,
            serviceId,
            dateTime,
            hasAddress: Boolean(address),
            hasToken: Boolean(req.header('Authorization')),
        });

        if (req.user.role !== 'customer') {
            return res
                .status(403)
                .json({ error: 'Only customers can create bookings' });
        }

        // Verify provider exists
        const provider = await Provider.findById(providerId);
        if (!provider) {
            return res.status(400).json({ error: 'Provider not found' });
        }

        // Verify service exists and belongs to provider
        const service = await Service.findById(serviceId);
        if (!service || service.providerId.toString() !== provider._id.toString()) {
            return res.status(400).json({
                error: 'Service not found or does not belong to this provider',
            });
        }

        // Verify customer exists
        const customer = await User.findById(req.user.id);
        if (!customer) {
            return res.status(400).json({ error: 'Customer not found' });
        }

        // Verify booking date is in the future
        const bookingDate = new Date(dateTime);
        if (Number.isNaN(bookingDate.getTime())) {
            return res.status(400).json({ error: 'Invalid booking date' });
        }
        if (bookingDate < new Date()) {
            return res
                .status(400)
                .json({ error: 'Booking date must be in the future' });
        }

        const booking = new Booking({
            customerId: req.user.id,
            customerName: customer.name,
            providerId: provider._id,
            serviceId: service._id,
            serviceName: service.name,
            providerName: provider.companyName,
            dateTime: bookingDate,
            price,
            address,
            specialInstructions: specialInstructions || '',
        });

        await booking.save();

        console.log(
            `BOOKING created ${booking._id} customer=${req.user.id} provider=${provider._id} service=${service._id}`,
        );

        // Emit real-time event to provider rooms
        const io = req.app.get('io');
        io.to(provider._id.toString()).emit('new_booking', {
            message: 'New booking received',
            booking,
        });
        io.to(provider.userId.toString()).emit('new_booking', {
            message: 'New booking received',
            booking,
        });

        res.status(201).json({
            message: 'Booking created successfully',
            booking,
        });
    } catch (err) {
        next(err);
    }
});

// Get Single Booking
router.get('/:id', authMiddleware, async (req, res, next) => {
    try {
        const booking = await Booking.findById(req.params.id)
            .populate('providerId', 'companyName')
            .populate('serviceId')
            .populate('customerId', 'name phone');

        if (!booking) {
            return res.status(404).json({ error: 'Booking not found' });
        }

        // Verify authorization
        const provider = await Provider.findOne({ userId: req.user.id });
        const isProvider =
            provider && booking.providerId._id.toString() === provider._id.toString();
        const isCustomer = booking.customerId._id.toString() === req.user.id;

        if (!isProvider && !isCustomer) {
            return res.status(403).json({ error: 'Unauthorized' });
        }

        res.json(booking);
    } catch (err) {
        next(err);
    }
});

// Update Booking Status
router.put(
    '/:id/status',
    authMiddleware,
    bookingStatusValidation,
    async (req, res, next) => {
        try {
            const { status } = req.body;
            const booking = await Booking.findById(req.params.id);

            if (!booking) {
                return res.status(404).json({ error: 'Booking not found' });
            }

            // Get provider info
            const provider = await Provider.findOne({ userId: req.user.id });
            const isProvider =
                provider && booking.providerId.toString() === provider._id.toString();
            const isCustomer = booking.customerId.toString() === req.user.id;

            // Role-based authorization
            if (!isProvider && !isCustomer) {
                return res.status(403).json({ error: 'Unauthorized' });
            }

            // Status transition rules
            const validTransitions = {
                pending: ['accepted', 'rejected', 'cancelled'],
                accepted: ['completed', 'cancelled'],
                completed: [],
                rejected: [],
                cancelled: [],
            };

            if (!validTransitions[booking.status]?.includes(status)) {
                return res.status(400).json({
                    error: `Invalid status change from '${booking.status}' to '${status}'`,
                    validStatuses: validTransitions[booking.status] || [],
                });
            }

            // Only providers can accept/reject, only customers can cancel
            if ((status === 'accepted' || status === 'rejected') && !isProvider) {
                return res.status(403).json({
                    error: 'Only providers can accept or reject bookings',
                });
            }

            if (status === 'cancelled' && !isCustomer) {
                return res
                    .status(403)
                    .json({ error: 'Only customers can cancel bookings' });
            }

            booking.status = status;
            await booking.save();

            console.log(`BOOKING ${booking._id} status updated to ${status}`);

            // Emit real-time event to both parties
            const io = req.app.get('io');
            const bookingProvider = await Provider.findById(booking.providerId).select(
                'userId',
            );

            io.to(booking.customerId.toString()).emit('booking_updated', {
                message: `Booking ${status}`,
                booking,
            });
            io.to(booking.providerId.toString()).emit('booking_updated', {
                message: `Booking ${status}`,
                booking,
            });
            if (bookingProvider?.userId) {
                io.to(bookingProvider.userId.toString()).emit('booking_updated', {
                    message: `Booking ${status}`,
                    booking,
                });
            }

            res.json({
                message: `Booking ${status} successfully`,
                booking,
            });
        } catch (err) {
            next(err);
        }
    },
);

// Submit Feedback for Completed Booking (Customer Only)
router.post(
    '/:id/feedback',
    authMiddleware,
    feedbackValidation,
    async (req, res, next) => {
        try {
            const { rating, comment } = req.body;
            const booking = await Booking.findById(req.params.id);

            if (!booking) {
                return res.status(404).json({ error: 'Booking not found' });
            }

            const isCustomer = booking.customerId.toString() === req.user.id;
            if (!isCustomer) {
                return res
                    .status(403)
                    .json({ error: 'Only the customer can submit feedback' });
            }

            if (booking.status !== 'completed') {
                return res.status(400).json({
                    error: 'Feedback can only be submitted for completed bookings',
                });
            }

            if (booking.feedback?.rating) {
                return res.status(400).json({
                    error: 'Feedback already submitted for this booking',
                });
            }

            booking.feedback = {
                rating,
                comment: (comment || '').trim(),
                submittedAt: new Date(),
            };
            booking.updatedAt = new Date();
            await booking.save();

            const provider = await Provider.findById(booking.providerId);
            if (provider) {
                const nextFeedbacks = provider.feedbacks || [];
                nextFeedbacks.push({
                    bookingId: booking._id,
                    customerId: booking.customerId,
                    customerName: booking.customerName,
                    serviceId: booking.serviceId,
                    serviceName: booking.serviceName,
                    rating,
                    comment: (comment || '').trim(),
                    createdAt: new Date(),
                });
                provider.feedbacks = nextFeedbacks;

                const currentReviewCount = provider.reviewCount || 0;
                const currentRating = provider.rating || 0;
                const updatedReviewCount = currentReviewCount + 1;
                const updatedRating =
                    (currentRating * currentReviewCount + Number(rating)) /
                    updatedReviewCount;

                provider.reviewCount = updatedReviewCount;
                provider.rating = Number(updatedRating.toFixed(2));
                provider.updatedAt = new Date();

                await provider.save();
            }

            const io = req.app.get('io');
            io.to(booking.customerId.toString()).emit('booking_updated', {
                message: 'Feedback submitted',
                booking,
            });
            io.to(booking.providerId.toString()).emit('booking_updated', {
                message: 'New customer feedback',
                booking,
            });

            res.status(201).json({
                message: 'Feedback submitted successfully',
                booking,
            });
        } catch (err) {
            next(err);
        }
    },
);

module.exports = router;
