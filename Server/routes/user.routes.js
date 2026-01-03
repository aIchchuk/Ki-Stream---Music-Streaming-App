const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.controller');

// GET /api/users - Get all users
router.get('/', userController.getAllUsers);

// GET /api/users/:id - Get a user by ID
router.get('/:id', userController.getUserById);

// POST /api/users - Create a new user (Register)
router.post('/', userController.createUser);

// POST /api/users/login - Login user
router.post('/login', userController.loginUser);

// PUT /api/users/:id - Update a user
router.put('/:id', userController.updateUser);

// DELETE /api/users/:id - Delete a user
router.delete('/:id', userController.deleteUser);

module.exports = router;
