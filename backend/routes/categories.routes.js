const express = require("express");
const router = express.Router();
const categoriesController = require("../controller/categories.controller");

router.get("/getAllCategories", categoriesController.getAllCategories);
router.post("/postCategory", categoriesController.postCategory);

module.exports = router;
