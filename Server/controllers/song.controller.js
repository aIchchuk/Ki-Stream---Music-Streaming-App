const Song = require('../models/song.model');

// Add a new song
exports.createSong = async (req, res) => {
    try {
        const songData = { ...req.body };

        // Handle file uploads
        if (req.files) {
            if (req.files['songImage']) {
                songData.songImage = `song-images/${req.files['songImage'][0].filename}`;
            }
            if (req.files['audioFile']) {
                songData.audioFile = `songs/${req.files['audioFile'][0].filename}`;
            }
        }

        const song = new Song(songData);
        await song.save();
        const songResponse = song.toObject();
        songResponse.id = song._id.toString();
        res.status(201).json(songResponse);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

// Get all songs
exports.getAllSongs = async (req, res) => {
    try {
        const songs = await Song.find().sort({ createdAt: -1 });
        const songsResponse = songs.map(s => {
            const songObj = s.toObject();
            songObj.id = s._id.toString();
            return songObj;
        });
        res.status(200).json(songsResponse);
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
        const songResponse = song.toObject();
        songResponse.id = song._id.toString();
        res.status(200).json(songResponse);
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

        const songData = { ...req.body };

        // Handle file uploads
        if (req.files) {
            if (req.files['songImage']) {
                songData.songImage = `song-images/${req.files['songImage'][0].filename}`;
            }
            if (req.files['audioFile']) {
                songData.audioFile = `songs/${req.files['audioFile'][0].filename}`;
            }
        }

        await Song.updateOne({ _id: req.params.id }, { $set: songData });
        const updatedSong = await Song.findById(req.params.id);
        const songResponse = updatedSong.toObject();
        songResponse.id = updatedSong._id.toString();
        res.status(200).json(songResponse);
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
