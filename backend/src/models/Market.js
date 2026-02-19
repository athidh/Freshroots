const mongoose = require('mongoose');

const marketSchema = new mongoose.Schema({
    name: { type: String, required: true },
    distance_km: { type: Number, required: true }, // Keep it simple for the hackathon
    prices: {
        type: Map,
        of: Number // Store prices like { "Tomato": 45, "Apple": 120 }
    },
    demand_level: { type: String, enum: ['High', 'Medium', 'Low'], default: 'Medium' }
});

module.exports = mongoose.model('Market', marketSchema);