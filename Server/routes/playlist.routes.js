const express = require('express');
const router = express.Router();
const playlistController = require('../controllers/playlist.controller');

// GET /api/playlists - Get all playlists
router.get('/', playlistController.getAllPlaylists);

// GET /api/playlists/:id - Get a playlist by ID
router.get('/:id', playlistController.getPlaylistById);

// POST /api/playlists - Create a new playlist
router.post('/', playlistController.createPlaylist);

// PUT /api/playlists/:id - Update a playlist
router.put('/:id', playlistController.updatePlaylist);

// DELETE /api/playlists/:id - Delete a playlist
router.delete('/:id', playlistController.deletePlaylist);

module.exports = router;
