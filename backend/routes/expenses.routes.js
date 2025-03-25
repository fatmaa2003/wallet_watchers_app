const express = require("express");
const router = express.Router();
const expensesController = require ('../controller/expenses.controller');

router.get("/getAllExpenses" , expensesController.getAllExpenses);
router.post("/postExpenses" , expensesController.postExpenses );

module.exports = router;
