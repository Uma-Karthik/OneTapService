const mongoose = require('mongoose');

const providerSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, unique: true },
    companyName: { type: String, required: true, trim: true },
    description: { type: String, trim: true },
    serviceIds: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Service' }],
    rating: { type: Number, default: 5.0, min: 0, max: 5 },
    reviewCount: { type: Number, default: 0, min: 0 },
    isAvailable: { type: Boolean, default: true },
    businessHours: { type: String },
    serviceAreas: [{ type: String }],
    feedbacks: [
        {
            bookingId: { type: mongoose.Schema.Types.ObjectId, ref: 'Booking', required: true },
            customerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
            customerName: { type: String, required: true, trim: true },
            serviceId: { type: mongoose.Schema.Types.ObjectId, ref: 'Service', required: true },
            serviceName: { type: String, required: true, trim: true },
            rating: { type: Number, required: true, min: 1, max: 5 },
            comment: { type: String, default: '', trim: true },
            createdAt: { type: Date, default: Date.now },
        },
    ],
    createdAt: { type: Date, default: Date.now },
    updatedAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Provider', providerSchema);
