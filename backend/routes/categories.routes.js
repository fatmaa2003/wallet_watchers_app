const express = require("express");
const router = express.Router();
const categoriesController = require("../controller/categories.controller");

router.get("/getAllCategories", categoriesController.getAllCategories);

module.exports = router;
