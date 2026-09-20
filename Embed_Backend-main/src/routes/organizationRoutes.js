const express = require('express');
const router = express.Router();
const organizationController = require('../controllers/organizationController');
const authMiddleware = require('../middleware/authMiddleware');

// Protect all organization routes
router.use(authMiddleware);

router.get('/settings', organizationController.getSettings);
router.put('/settings', organizationController.updateSettings);

module.exports = router;
