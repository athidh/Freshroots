require('dotenv').config();
const http = require('http');
const { Server } = require('socket.io'); // The real-time engine
const app = require('./src/app');
const connectDB = require('./src/config/db');

const PORT = process.env.PORT || 5000;

// 1. Wrap your Express app in a standard HTTP server
const server = http.createServer(app);

// 2. Attach Socket.io to that server
const io = new Server(server, {
    cors: { origin: "*" } // Allows your Flutter app to connect freely
});

// 3. The Real-Time Map Logic
io.on('connection', (socket) => {
    console.log(`🟢 New device connected for Live Tracking: ${socket.id}`);

    // When the Driver's Flutter app sends a new GPS ping...
    socket.on('driver_location_update', (data) => {
        // data looks like: { tripId: "123", lat: 11.91, lon: 79.81 }
        
        // Instantly broadcast this location to anyone listening (like a dashboard)
        // We broadcast it to a specific "room" named after the tripId
        socket.to(data.tripId).emit('live_map_movement', {
            lat: data.lat,
            lon: data.lon,
            timestamp: new Date()
        });
    });

    // Let devices join a specific trip's "room"
    socket.on('join_trip_tracking', (tripId) => {
        socket.join(tripId);
        console.log(`Device joined tracking for trip: ${tripId}`);
    });

    socket.on('disconnect', () => {
        console.log(`🔴 Device disconnected: ${socket.id}`);
    });
});

// Connect to Database, then start the SERVER (not just the app)
connectDB().then(() => {
    server.listen(PORT, () => {
        console.log(`🚀 FreshRoute API & Live Sockets running on port ${PORT}`);
    });
});