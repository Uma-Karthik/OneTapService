const { body, validationResult } = require('express-validator');

// Validation middleware that checks for errors
const handleValidationErrors = (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ error: 'Validation failed', details: errors.array() });
    }
    next();
};

// Helper function to chain validators
const chainValidations = (validations) => {
    return validations.concat([handleValidationErrors]);
};

// Auth validations
const signupValidation = [
    body('name').trim().notEmpty().withMessage('Name is required').isLength({ min: 2 }).withMessage('Name must be at least 2 characters'),
    body('email').isEmail().withMessage('Invalid email format'),
    body('password').isLength({ min: 4 }).withMessage('Password must be at least 4 characters'),
    body('phone').trim().notEmpty().withMessage('Phone is required'),
    body('address').trim().notEmpty().withMessage('Address is required'),
    body('role').isIn(['customer', 'provider']).withMessage('Invalid role'),
];

const loginValidation = [
    body('email').isEmail().withMessage('Invalid email format'),
    body('password').notEmpty().withMessage('Password is required'),
    body('role').isIn(['customer', 'provider']).withMessage('Invalid role'),
];

// Service validations
const serviceValidation = [
    body('name').trim().notEmpty().withMessage('Service name is required'),
    body('description').trim().notEmpty().withMessage('Description is required'),
    body('category').trim().notEmpty().withMessage('Category is required'),
    body('icon').trim().notEmpty().withMessage('Service icon is required'),
    body('price').isFloat({ min: 0 }).withMessage('Price must be a positive number'),
    body('duration').trim().notEmpty().withMessage('Duration is required'),
    body('isAvailable').optional().isBoolean().withMessage('isAvailable must be a boolean'),
];

// Booking validations
const bookingValidation = [
    body('providerId').isMongoId().withMessage('Invalid provider ID'),
    body('serviceId').isMongoId().withMessage('Invalid service ID'),
    body('dateTime').isISO8601().withMessage('Invalid date/time format'),
    body('price').isFloat({ min: 0 }).withMessage('Price must be a positive number'),
    body('address').trim().notEmpty().withMessage('Address is required'),
    body('specialInstructions').optional().isString().withMessage('specialInstructions must be a string'),
];

// Booking status update validation
const bookingStatusValidation = [
    body('status').isIn(['pending', 'accepted', 'completed', 'cancelled', 'rejected']).withMessage('Invalid booking status'),
];

const feedbackValidation = [
    body('rating')
        .isInt({ min: 1, max: 5 })
        .withMessage('Rating must be an integer between 1 and 5'),
    body('comment')
        .optional()
        .isString()
        .withMessage('Comment must be a string')
        .isLength({ max: 500 })
        .withMessage('Comment cannot exceed 500 characters'),
];

// Provider update validation
const providerUpdateValidation = [
    body('companyName').optional().trim().notEmpty().withMessage('Company name cannot be empty'),
    body('description').optional().trim(),
    body('businessHours').optional().trim(),
    body('serviceAreas').optional().isArray().withMessage('Service areas must be an array'),
    body('isAvailable').optional().isBoolean().withMessage('isAvailable must be a boolean'),
];

module.exports = {
    handleValidationErrors,
    chainValidations,
    signupValidation: chainValidations(signupValidation),
    loginValidation: chainValidations(loginValidation),
    serviceValidation: chainValidations(serviceValidation),
    bookingValidation: chainValidations(bookingValidation),
    bookingStatusValidation: chainValidations(bookingStatusValidation),
    feedbackValidation: chainValidations(feedbackValidation),
    providerUpdateValidation: chainValidations(providerUpdateValidation),
};
