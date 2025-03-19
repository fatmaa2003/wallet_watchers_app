const express = require ('express');
const router = express.Router();
const usersController = require ("../controller/users.controller")

router.post('/addxpense', usersController.addExpense)

module.exports = router;