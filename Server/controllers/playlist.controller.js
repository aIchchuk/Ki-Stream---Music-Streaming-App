const Playlist = require('../models/playlist.model');

// Create a new playlist
exports.createPlaylist = async (req, res) => {
    try {
        const playlist = new Playlist(req.body);
        await playlist.save();
        res.status(201).json(playlist);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

// Get all playlists
exports.getAllPlaylists = async (req, res) => {
    try {
        const playlists = await Playlist.find()
            .populate('songIds')
            .sort({ createdAt: -1 });
        res.status(200).json(playlists);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

// Get playlist by ID
exports.getPlaylistById = async (req, res) => {
    try {
        const playlist = await Playlist.findById(req.params.id)
            .populate('songIds');
        if (!playlist) {
            return res.status(404).json({ message: 'Playlist not found' });
        }
        res.status(200).json(playlist);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

// Update playlist
exports.updatePlaylist = async (req, res) => {
    try {
        const playlist = await Playlist.findByIdAndUpdate(
            req.params.id,
            req.body,
            { new: true }
        );
        if (!playlist) {
            return res.status(404).json({ message: 'Playlist not found' });
        }
        res.status(200).json(playlist);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

// Delete playlist
exports.deletePlaylist = async (req, res) => {
    try {
        const playlist = await Playlist.findByIdAndDelete(req.params.id);
        if (!playlist) {
            return res.status(404).json({ message: 'Playlist not found' });
        }
        res.status(200).json({ message: 'Playlist deleted successfully' });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};
