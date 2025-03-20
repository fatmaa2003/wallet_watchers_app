const express = require('express');
const router = express.Router();
const usersController = require("../controller/users.controller");

router.post('/signup', usersController.signup);

router.post('/addexpense', usersController.addExpense);

module.exports = router;
