const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const User = require('./models/User');
const Provider = require('./models/Provider');
const Service = require('./models/Service');

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/home_services';

const seedData = async () => {
    try {
        await mongoose.connect(MONGODB_URI);
        console.log('Connected to MongoDB for seeding...');

        // Clear existing data
        await User.deleteMany({});
        await Provider.deleteMany({});
        await Service.deleteMany({});

        console.log('Cleared existing data.');

        // 1. Create Customer
        const customerPassword = await bcrypt.hash('customer123', 10);
        const customer = await User.create({
            name: 'John Customer',
            email: 'customer@example.com',
            password: customerPassword,
            phone: '1234567890',
            address: '123 Main St, City',
            role: 'customer'
        });

        // 2. Create Provider User
        const providerPassword = await bcrypt.hash('provider123', 10);
        const providerUser = await User.create({
            name: 'Expert Plumber',
            email: 'provider@example.com',
            password: providerPassword,
            phone: '0987654321',
            address: '456 Service Way, City',
            role: 'provider'
        });

        // 3. Create Provider Profile
        const provider = await Provider.create({
            userId: providerUser._id,
            companyName: 'AquaFlow Plumbing',
            description: 'Professional plumbing services with 10 years experience.',
            rating: 4.8,
            reviewCount: 25,
            isAvailable: true,
            serviceAreas: ['New York', 'Brooklyn', 'Queens']
        });

        // 4. Create Services
        await Service.create([
            {
                name: 'Pipe Repair',
                description: 'Fixing all types of pipe leaks and bursts.',
                icon: '🔧',
                price: 80,
                category: 'Plumbing',
                providerId: provider._id,
                durationMinutes: 60,
                rating: 4.9,
                reviews: 12
            },
            {
                name: 'Drain Cleaning',
                description: 'Clearing clogged drains and toilets.',
                icon: '🚿',
                price: 60,
                category: 'Plumbing',
                providerId: provider._id,
                durationMinutes: 45,
                rating: 4.7,
                reviews: 8
            }
        ]);

        console.log('Seed data created successfully!');
        process.exit();
    } catch (err) {
        console.error('Seeding error:', err);
        process.exit(1);
    }
};

seedData();
