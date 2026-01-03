const express = require('express');
const router = express.Router();
const songController = require('../controllers/song.controller');
const upload = require('../middleware/upload.middleware');

// GET /api/songs - Get all songs
router.get('/', songController.getAllSongs);

// GET /api/songs/:id - Get a song by ID
router.get('/:id', songController.getSongById);

// POST /api/songs - Create a new song
router.post('/', upload.fields([
    { name: 'songImage', maxCount: 1 },
    { name: 'audioFile', maxCount: 1 }
]), songController.createSong);

// PUT /api/songs/:id - Update a song
router.put('/:id', upload.fields([
    { name: 'songImage', maxCount: 1 },
    { name: 'audioFile', maxCount: 1 }
]), songController.updateSongById);

// DELETE /api/songs/:id - Delete a song
router.delete('/:id', songController.deleteSong);

module.exports = router;
