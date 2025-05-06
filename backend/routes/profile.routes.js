const express = require('express');
const router = express.Router();
const profileController = require('../controller/profile.controller');

router.get('/getProfile', profileController.getProfile);

module.exports = router;