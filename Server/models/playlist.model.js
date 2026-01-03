const mongoose = require('mongoose');

const playlistSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true,
        trim: true
    },
    mood: {
        type: String,
        required: true,
        trim: true
    },
    songIds: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Song'
    }],
    imagePath: {
        type: String,
        default: ''
    },
    creatorId: {
        type: String
    },
    creatorName: {
        type: String,
        trim: true
    }
}, {
    timestamps: true
});

const Playlist = mongoose.model('Playlist', playlistSchema);

module.exports = Playlist;
