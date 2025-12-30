const express = require('express');
const router = express.Router();
const songController = require('../controllers/song.controller');

// GET /api/songs - Get all songs
router.get('/', songController.getAllSongs);

// DELETE /api/songs/:id - Delete a song
router.delete('/:id', songController.deleteSong);

module.exports = router;
