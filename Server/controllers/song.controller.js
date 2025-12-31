const Song = require('../models/song.model');

// Add a new song
exports.createSong = async (req, res) => {
    try {
        const song = new Song(req.body);
        await song.save();
        res.status(201).json(song);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

// Get all songs
exports.getAllSongs = async (req, res) => {
    try {
        const songs = await Song.find().sort({ createdAt: -1 });
        res.status(200).json(songs);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

// Get Song By Id
exports.getSongById = async (req, res) => {
    try {
        const song = await Song.findById(req.params.id);
        if (!song) {
            return res.status(404).json({ message: 'Song not found' });
        }
        res.status(200).json(song);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

// Update Song By ID
exports.updateSongById = async (req, res) => {
    try {
        const song = await Song.findById(req.params.id);
        if (!song) {
            return res.status(404).json({ message: 'Song not found' });
        }
        const newSong = await Song.updateOne({ _id: req.params.id }, { $set: req.body });
        res.status(200).json(newSong);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

// Delete a song
exports.deleteSong = async (req, res) => {
    try {
        const song = await Song.findById(req.params.id);
        if (!song) {
            return res.status(404).json({ message: 'Song not found' });
        }
        await song.deleteOne();
        res.status(200).json({ message: 'Song deleted successfully' });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};
