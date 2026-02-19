const Trip = require('../models/Trip');
const spoilageEngine = require('../services/spoilageEngine');
const produceData = require('../config/produceData.json');
const weatherService = require('../services/weatherService');

// 1. START TRIP (Layer 1 Input)
// This is triggered when the farmer/driver creates a new shipment.
exports.startTrip = async (req, res) => {
    try {
        const { produce_name, quantity, start_location } = req.body;
        
        // Find the biological constants for this specific produce
        // We look in both 'fruits' and 'vegetables' arrays
        const produceInfo = produceData.fruits.find(p => p.name === produce_name) || 
                            produceData.vegetables.find(p => p.name === produce_name);

        if (!produceInfo) {
            return res.status(400).json({ message: "Produce type not supported in system." });
        }

        const newTrip = new Trip({
            user_id: req.user.id, // Securely pulled from your Auth Middleware
            produce_name: produceInfo.name,
            quantity : quantity,
            respiration_rate: produceInfo.decay_constant,
            start_location,
            harvest_timestamp: new Date(), // The "Biological Clock" starts NOW
            initial_freshness: 100
        });

        await newTrip.save();
        
        
        
        res.status(201).json({ 
            message: "Trip started. Freshness timer initialized.",
            tripId: newTrip._id 
        });

    } catch (err) {
        res.status(500).json({ error: "Failed to start trip", details: err.message });
    }
};

// 2. GET TRIP STATUS (Layer 3 & 4: The Intelligence Output)
// Flutter calls this every 30 seconds to update the "Freshness Gauge"
exports.getTripStatus = async (req, res) => {
    try {
        const tripId = req.params.id;
        const trip = await Trip.findById(tripId);

        if (!trip) return res.status(404).json({ message: "Trip not found." });

        // 1. Get GPS coordinates from the request URL, or default to a fixed location 
        // (e.g., defaulting to Puducherry coordinates: 11.91, 79.81)
        const lat = req.query.lat || 11.9139;
        const lon = req.query.lon || 79.8145;

        // 2. Fetch the REAL-WORLD temperature!
        const liveTemp = await weatherService.getCurrentTemperature(lat, lon);

        // 3. Plug the real temperature into your Spoilage Engine
        const freshnessScore = spoilageEngine.getFreshness(
            trip.respiration_rate, 
            liveTemp, 
            trip.harvest_timestamp
        );

        let spoilageRisk = "Low";
        if (freshnessScore < 70) spoilageRisk = "Medium";
        if (freshnessScore < 40) spoilageRisk = "High (REROUTE SUGGESTED)";

        res.json({
            trip_id: trip._id,
            produce: trip.produce_name,
            live_status: {
                ambient_temperature: `${liveTemp}°C`, // Real temperature!
                freshness_percentage: `${freshnessScore}%`,
                spoilage_risk: spoilageRisk,
                location_tracked: `[${lat}, ${lon}]`
            }
        });

    } catch (err) {
        res.status(500).json({ error: "Failed to fetch status", details: err.message });
    }
};