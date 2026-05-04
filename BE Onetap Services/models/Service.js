const mongoose = require('mongoose');

const serviceSchema = new mongoose.Schema({
    name: { type: String, required: true, trim: true },
    description: { type: String, required: true, trim: true },
    category: { type: String, required: true, trim: true },
    icon: { type: String, required: true, trim: true },
    price: { type: Number, required: true, min: 0 },
    duration: { type: String, required: true, trim: true },
    providerId: { type: mongoose.Schema.Types.ObjectId, ref: 'Provider', required: true },
    isAvailable: { type: Boolean, default: true },
    imageUrl: { type: String },
    rating: { type: Number, default: 5.0, min: 0, max: 5 },
    reviewCount: { type: Number, default: 0, min: 0 },
    createdAt: { type: Date, default: Date.now },
    updatedAt: { type: Date, default: Date.now },
});

// Index for finding services by provider
serviceSchema.index({ providerId: 1 });
// Index for category filtering
serviceSchema.index({ category: 1 });
// Text index for service-level search
serviceSchema.index({ name: 'text', category: 'text', description: 'text' });

module.exports = mongoose.model('Service', serviceSchema);
