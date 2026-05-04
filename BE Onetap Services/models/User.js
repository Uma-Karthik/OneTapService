const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
    name: { type: String, required: true, trim: true },
    email: { type: String, required: true, unique: true, lowercase: true, trim: true },
    password: { type: String, required: true },
    phone: { type: String, required: true },
    address: { type: String, required: true, trim: true },
    role: { type: String, enum: ['customer', 'provider'], required: true },
    createdAt: { type: Date, default: Date.now },
    updatedAt: { type: Date, default: Date.now },
});

// Hash password before saving
userSchema.pre('save', async function () {
    this.updatedAt = new Date();

    if (!this.isModified('password')) {
        return;
    }

    // Mongoose v9 async middleware should throw/return instead of calling next()
    const password = this.password;
    if (typeof password !== 'string' || password.length < 4) {
        throw new Error('Password must be at least 4 characters');
    }

    this.password = await bcrypt.hash(password, 10);
});

// Compare password
userSchema.methods.comparePassword = async function (candidatePassword) {
    if (typeof candidatePassword !== 'string' || !candidatePassword) {
        return false;
    }
    return await bcrypt.compare(candidatePassword, this.password);
};

// Remove password from JSON responses
userSchema.methods.toJSON = function () {
    const obj = this.toObject();
    delete obj.password;
    return obj;
};

module.exports = mongoose.model('User', userSchema);
