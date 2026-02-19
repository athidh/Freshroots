const mongoose = require('mongoose');

const tripSchema = new mongoose.Schema({
    user_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    produce_name: { type: String, required: true },
    quantity: { type: Number, required: true }, // e.g., weight in kg
    respiration_rate: { type: Number, required: true }, // The "Biological Constant"
    start_location: { type: String, default: "Unknown" }, // Simplified for Hackathon
    harvest_timestamp: { type: Date, required: true },
    initial_freshness: { type: Number, default: 100 },
    status: { type: String, default: 'IN_TRANSIT' }, // IN_TRANSIT, DELIVERED
    created_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Trip', tripSchema);