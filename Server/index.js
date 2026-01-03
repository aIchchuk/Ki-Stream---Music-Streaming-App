const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const songRoutes = require('./routes/song.routes');
const playlistRoutes = require('./routes/playlist.routes');
const userRoutes = require('./routes/user.routes');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Basic Route
app.get('/', (req, res) => {
    res.send('Ki Stream Server is running...');
});

// Health check endpoint
app.get('/api/health', (req, res) => {
    res.status(200).json({ status: 'ok' });
});

// Static Files
app.use('/public', express.static(path.join(__dirname, 'public')));

// Routes
app.use('/api/songs', songRoutes);
app.use('/api/playlists', playlistRoutes);
app.use('/api/users', userRoutes);

// Database Connection
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/ki_stream_db';

mongoose.connect(MONGODB_URI)
    .then(() => {
        console.log('Connected to MongoDB');
        app.listen(PORT, () => {
            console.log(`Server is running on port ${PORT}`);
        });
    })
    .catch((err) => {
        console.error('Error connecting to MongoDB:', err.message);
    });
