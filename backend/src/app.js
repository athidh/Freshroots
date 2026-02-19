const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/authRoutes');
const tripRoutes = require('./routes/tripRoutes'); 
const marketRoutes = require('./routes/marketRoutes');

const app = express();


app.use(cors());


app.use(express.json()); 


app.use('/api/auth', authRoutes);
app.use('/api/trips',tripRoutes);
app.use('/api/markets', marketRoutes);


app.get('/', (req, res) => {
    res.send('FreshRoute API is running...');
});

module.exports = app;