const express = require('express');
const router = express.Router();
const marketController = require('../controllers/marketController');
const { protect } = require('../middleware/authMiddleware');

// Route to instantly generate mock markets (No auth needed for this helper)
router.post('/seed', marketController.seedMarkets);

// Route to get the AI recommendation for a specific trip (Protected!)
router.get('/recommend/:tripId', protect, marketController.recommendMarket);

module.exports = router;