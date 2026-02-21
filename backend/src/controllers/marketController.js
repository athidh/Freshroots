const Market = require('../models/Market');
const Trip = require('../models/Trip');
const spoilageEngine = require('../services/spoilageEngine');

// 1. SEED MARKETS (Hackathon Cheat Code)
// Run this once to populate your database with fake markets
exports.seedMarkets = async (req, res) => {
    try {
        await Market.deleteMany(); // Clear out old data
        const markets = [
            {
                name: "Koyambedu Market, Chennai",
                distance_km: 12,
                prices: { "Tomato": 35, "Apple": 180, "Banana": 45, "Mango": 120, "Grapes": 90, "Spinach": 40, "Broccoli": 80, "Carrot": 50, "Potato": 30, "Strawberry": 250 },
                demand_level: "High",
                lat: 13.0694,
                lon: 80.1948
            },
            {
                name: "Madurai Mango Market",
                distance_km: 45,
                prices: { "Tomato": 30, "Apple": 160, "Banana": 40, "Mango": 150, "Grapes": 85, "Spinach": 35, "Broccoli": 70, "Carrot": 45, "Potato": 25, "Strawberry": 220 },
                demand_level: "Medium",
                lat: 9.9252,
                lon: 78.1198
            },
            {
                name: "Ernakulam Market, Kochi",
                distance_km: 30,
                prices: { "Tomato": 38, "Apple": 190, "Banana": 50, "Mango": 130, "Grapes": 95, "Spinach": 45, "Broccoli": 85, "Carrot": 55, "Potato": 32, "Strawberry": 280 },
                demand_level: "High",
                lat: 9.9816,
                lon: 76.2999
            },
            {
                name: "Mysore APMC Yard",
                distance_km: 55,
                prices: { "Tomato": 28, "Apple": 170, "Banana": 38, "Mango": 110, "Grapes": 80, "Spinach": 30, "Broccoli": 65, "Carrot": 42, "Potato": 22, "Strawberry": 200 },
                demand_level: "Low",
                lat: 12.2958,
                lon: 76.6394
            },
            {
                name: "Visakhapatnam Rythu Bazaar",
                distance_km: 70,
                prices: { "Tomato": 42, "Apple": 200, "Banana": 55, "Mango": 140, "Grapes": 100, "Spinach": 50, "Broccoli": 90, "Carrot": 60, "Potato": 35, "Strawberry": 300 },
                demand_level: "High",
                lat: 17.6868,
                lon: 83.2185
            }
        ];
        await Market.insertMany(markets);
        res.status(201).json({ message: `${markets.length} South Indian markets seeded successfully!` });
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
                market_price_per_unit: `₹${marketPrice}`,
                demand: market.demand_level,
                expected_revenue: `₹${expectedRevenue}`
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