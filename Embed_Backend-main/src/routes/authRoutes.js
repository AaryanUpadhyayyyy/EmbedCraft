const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

router.post('/login', authController.login);
router.post('/change-password', require('../middleware/authMiddleware'), authController.changePassword);
router.get('/environment', require('../middleware/authMiddleware'), authController.getEnvironment);
// router.post('/register', authController.register); // Internal use only

module.exports = router;
