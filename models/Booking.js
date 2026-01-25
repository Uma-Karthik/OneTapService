const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema({
    customerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    providerId: { type: mongoose.Schema.Types.ObjectId, ref: 'Provider', required: true },
    serviceId: { type: mongoose.Schema.Types.ObjectId, ref: 'Service', required: true },
    serviceName: { type: String, required: true, trim: true },
    customerName: { type: String, required: true, trim: true },
    providerName: { type: String, required: true, trim: true },
    dateTime: { type: Date, required: true },
    status: {
        type: String,
        enum: ['pending', 'accepted', 'completed', 'cancelled', 'rejected'],
        default: 'pending',
    },
    price: { type: Number, required: true, min: 0 },
    address: { type: String, required: true, trim: true },
    specialInstructions: { type: String, default: '' },
    feedback: {
        rating: { type: Number, min: 1, max: 5 },
        comment: { type: String, default: '', trim: true },
        submittedAt: { type: Date },
    },
    createdAt: { type: Date, default: Date.now },
    updatedAt: { type: Date, default: Date.now },
});

// Index for finding bookings by customer/provider
bookingSchema.index({ customerId: 1, createdAt: -1 });
bookingSchema.index({ providerId: 1, createdAt: -1 });
// Index for finding bookings by status
bookingSchema.index({ status: 1 });

module.exports = mongoose.model('Booking', bookingSchema);
