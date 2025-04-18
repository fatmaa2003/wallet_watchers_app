const express = require("express");
const router = express.Router();
const usersController = require("../controller/users.controller");

router.post("/signup", usersController.signup);
router.post("/postLogin", usersController.login);
router.post("/addexpense", usersController.addExpense);

module.exports = router;
