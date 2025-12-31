const mongoose = require('mongoose');

const songSchema = new mongoose.Schema({
    songName: {
        type: String,
        required: true,
        trim: true
    },
    artistName: {
        type: String,
        required: true,
        trim: true
    },
    audioFile: {
        type: String,
        required: true
    },
    songImage: {
        type: String,
        default: ''
    },
    albumName: {
        type: String,
        default: ''
    },
    isManual: {
        type: Boolean,
        default: false
    },
    isFavorite: {
        type: Boolean,
        default: false
    },
    color: {
        type: String,
        default: '#000000'
    },
    duration: {
        type: String,
        default: '0:00'
    }
}, {
    timestamps: true
});

const Song = mongoose.model('Song', songSchema);

module.exports = Song;
