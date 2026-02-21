const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/authRoutes');
const tripRoutes = require('./routes/tripRoutes');
const marketRoutes = require('./routes/marketRoutes');

const app = express();


app.use(cors());


app.use(express.json());


app.use('/api/auth', authRoutes);
app.use('/api/trips', tripRoutes);
app.use('/api/markets', marketRoutes);

// Serve produce data (so Flutter gets the same list as the backend)
const produceData = require('./config/produceData.json');
app.get('/api/produce', (req, res) => {
    res.json(produceData);
});

// Weather endpoint — fetch weather for any lat/lon
const axios = require('axios');
app.get('/api/weather', async (req, res) => {
    try {
        const { lat, lon } = req.query;
        if (!lat || !lon) return res.status(400).json({ error: 'lat and lon required' });
        const apiKey = process.env.WEATHER_API_KEY;
        const url = `${process.env.WEATHER_BASE_URL}?lat=${lat}&lon=${lon}&appid=${apiKey}&units=metric`;
        const response = await axios.get(url);
        const d = response.data;
        res.json({
            temp: `${d.main.temp.toFixed(1)}°C`,
            description: d.weather[0].description,
            icon: d.weather[0].icon,
            humidity: d.main.humidity,
            wind: `${d.wind.speed} m/s`,
            city: d.name,
        });
    } catch (e) {
        res.status(500).json({ error: 'Weather fetch failed', details: e.message });
    }
});

app.get('/', (req, res) => {
    res.send('FreshRoute API is running...');
});

module.exports = app;