const express = require('express');
const router = express.Router();
const songController = require('../controllers/song.controller');

// GET /api/songs - Get all songs
router.get('/', songController.getAllSongs);

// GET /api/songs/:id - Get a song by ID
router.get('/:id', songController.getSongById);

// POST /api/songs - Create a new song
router.post('/', songController.createSong);

// PUT /api/songs/:id - Update a song
router.put('/:id', songController.updateSongById);

// DELETE /api/songs/:id - Delete a song
router.delete('/:id', songController.deleteSong);

module.exports = router;
