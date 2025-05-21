const express = require("express");
const router = express.Router();
const expensesController = require("../controller/expenses.controller");

// POST routes
router.post("/postAllExpenses", expensesController.postAllExpenses);
router.post("/postExpenses", expensesController.postExpenses);

// GET route
router.get("/getExpensesByDate", expensesController.getExpensesByDate);

// DELETE route
router.delete("/deleteExpense", expensesController.deleteExpense);

module.exports = router;
