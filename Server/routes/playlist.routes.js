const express = require('express');
const router = express.Router();
const playlistController = require('../controllers/playlist.controller');
const upload = require('../middleware/upload.middleware');

// GET /api/playlists - Get all playlists
router.get('/', playlistController.getAllPlaylists);

// GET /api/playlists/:id - Get a playlist by ID
router.get('/:id', playlistController.getPlaylistById);

// POST /api/playlists - Create a new playlist
router.post('/', upload.single('imagePath'), playlistController.createPlaylist);

// PUT /api/playlists/:id - Update a playlist
router.put('/:id', upload.single('imagePath'), playlistController.updatePlaylist);

// DELETE /api/playlists/:id - Delete a playlist
router.delete('/:id', playlistController.deletePlaylist);

module.exports = router;
