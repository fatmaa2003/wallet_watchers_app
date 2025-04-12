const express = require("express");
const router = express.Router();
const usersController = require("../controller/users.controller");

router.post("/signup", usersController.signup);
router.post("/login", usersController.login);
router.post("/addexpense", usersController.addExpense);
router.post('/forgot-password', usersController.forgotPassword);

module.exports = router;


