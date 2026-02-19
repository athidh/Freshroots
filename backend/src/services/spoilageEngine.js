// src/services/spoilageEngine.js

const getFreshness = (decayConstant, currentTemp, harvestTime) => {
    // 1. Calculate how many hours have passed since the trip started
    const now = new Date();
    const hoursSinceHarvest = (now - new Date(harvestTime)) / (1000 * 60 * 60);

    // 2. Arrhenius-inspired logic: 
    // Spoilage rate doubles for every 10°C increase above the baseline (10°C)
    const tempImpact = Math.pow(2, (currentTemp - 10) / 10);
    
    // 3. Calculate the total degradation
    const totalDecay = hoursSinceHarvest * decayConstant * tempImpact;
    
    // 4. Subtract from 100% and ensure it doesn't drop below 0
    let freshness = 100 - totalDecay;
    return Math.max(0, freshness).toFixed(2);
};

// This is the crucial line that was missing! It exports the function so the controller can use it.
module.exports = { getFreshness };