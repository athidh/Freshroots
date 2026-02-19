const Market = require('../models/Market');
const Trip = require('../models/Trip');
const spoilageEngine = require('../services/spoilageEngine');

// 1. SEED MARKETS (Hackathon Cheat Code)
// Run this once to populate your database with fake markets
exports.seedMarkets = async (req, res) => {
    try {
        await Market.deleteMany(); // Clear out old data
        const markets = [
            { name: "Central City Mandi", distance_km: 15, prices: { "Tomato": 40, "Apple": 120 }, demand_level: "Medium" },
            { name: "Northway Wholesale", distance_km: 60, prices: { "Tomato": 65, "Apple": 150 }, demand_level: "High" },
            { name: "Local Village Market", distance_km: 5, prices: { "Tomato": 30, "Apple": 90 }, demand_level: "Low" }
        ];
        await Market.insertMany(markets);
        res.status(201).json({ message: "3 Mock markets created successfully!" });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// 2. RECOMMEND BEST MARKET (The Algorithm)
exports.recommendMarket = async (req, res) => {
    try {
        const tripId = req.params.tripId;
        const trip = await Trip.findById(tripId);

        if (!trip) return res.status(404).json({ message: "Trip not found" });

        const markets = await Market.find();
        const currentTemp = 28; // Mock temperature
        
        // Get exact freshness right now
        const currentFreshness = spoilageEngine.getFreshness(trip.respiration_rate, currentTemp, trip.harvest_timestamp);

        // Calculate profitability for each market
        let recommendations = markets.map(market => {
            // Assume the truck drives at 40 km/h
            const travelTimeHours = market.distance_km / 40;

            // Predict freshness upon arrival (Drops 1% per hour of travel as a hackathon baseline)
            let projectedFreshness = currentFreshness - (travelTimeHours * 1);
            projectedFreshness = Math.max(0, projectedFreshness).toFixed(2);

            // Calculate money: Quantity * Price * (Freshness Percentage)
            const marketPrice = market.prices.get(trip.produce_name) || 0; 
            const expectedRevenue = (trip.quantity * marketPrice * (projectedFreshness / 100)).toFixed(2);

            return {
                market_name: market.name,
                distance: `${market.distance_km} km`,
                projected_freshness: `${projectedFreshness}%`,
                market_price_per_unit: `$${marketPrice}`,
                demand: market.demand_level,
                expected_revenue: `$${expectedRevenue}`
            };
        });

        // Sort the array so the highest revenue market is at the very top
        recommendations.sort((a, b) => 
            parseFloat(b.expected_revenue.replace('$', '')) - parseFloat(a.expected_revenue.replace('$', ''))
        );

        res.json({
            trip_id: tripId,
            produce: trip.produce_name,
            current_freshness: `${currentFreshness}%`,
            top_recommendation: recommendations[0], // The winner!
            all_options: recommendations
        });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};