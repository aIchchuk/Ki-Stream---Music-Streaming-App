const Playlist = require('../models/playlist.model');

// Create a new playlist
exports.createPlaylist = async (req, res) => {
    try {
        const playlistData = { ...req.body };

        // Handle file upload
        if (req.file) {
            playlistData.imagePath = `playlist-images/${req.file.filename}`;
        }

        // Handle songIds if sent as string (Multipart)
        if (typeof playlistData.songIds === 'string') {
            try {
                playlistData.songIds = JSON.parse(playlistData.songIds);
            } catch (e) {
                playlistData.songIds = playlistData.songIds.split(',').map(id => id.trim()).filter(id => id);
            }
        }

        const playlist = new Playlist(playlistData);
        await playlist.save();
        const playlistResponse = playlist.toObject();
        playlistResponse.id = playlist._id.toString();
        // Ensure songIds are strings
        playlistResponse.songIds = playlist.songIds.map(id => id.toString());
        res.status(201).json(playlistResponse);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

// Get all playlists
exports.getAllPlaylists = async (req, res) => {
    try {
        const playlists = await Playlist.find()
            .sort({ createdAt: -1 });

        const playlistsResponse = playlists.map(p => {
            const playlistObj = p.toObject();
            playlistObj.id = p._id.toString();
            // Ensure songIds are strings if they were somehow populated
            playlistObj.songIds = p.songIds.map(id => id.toString());
            return playlistObj;
        });

        res.status(200).json(playlistsResponse);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

// Get playlist by ID
exports.getPlaylistById = async (req, res) => {
    try {
        const playlist = await Playlist.findById(req.params.id);
        if (!playlist) {
            return res.status(404).json({ message: 'Playlist not found' });
        }
        const playlistResponse = playlist.toObject();
        playlistResponse.id = playlist._id.toString();
        playlistResponse.songIds = playlist.songIds.map(id => id.toString());
        res.status(200).json(playlistResponse);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

// Update playlist
exports.updatePlaylist = async (req, res) => {
    try {
        const playlistData = { ...req.body };

        // Handle file upload
        if (req.file) {
            playlistData.imagePath = `playlist-images/${req.file.filename}`;
        }

        // Handle songIds if sent as string (Multipart)
        if (typeof playlistData.songIds === 'string') {
            try {
                playlistData.songIds = JSON.parse(playlistData.songIds);
            } catch (e) {
                playlistData.songIds = playlistData.songIds.split(',').map(id => id.trim()).filter(id => id);
            }
        }

        const playlist = await Playlist.findByIdAndUpdate(
            req.params.id,
            playlistData,
            { new: true }
        );
        if (!playlist) {
            return res.status(404).json({ message: 'Playlist not found' });
        }
        const playlistResponse = playlist.toObject();
        playlistResponse.id = playlist._id.toString();
        // Ensure songIds are strings
        if (playlistResponse.songIds) {
            playlistResponse.songIds = playlist.songIds.map(id => id.toString());
        }
        res.status(200).json(playlistResponse);
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
