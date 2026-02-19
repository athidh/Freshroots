const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');
const tripController = require('../controllers/tripController');

// This route is now SECURE. Only logged-in users with a token can start a trip.
router.post('/start', protect, tripController.startTrip);

// This route is also protected.
router.get('/status/:id', protect, tripController.getTripStatus);

module.exports = router;