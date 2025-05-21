const express = require("express");
const router = express.Router();
const expensesController = require("../controller/expenses.controller");

router.post("/postAllExpenses", expensesController.postAllExpenses);
router.post("/postExpenses", expensesController.postExpenses);
router.get("/getExpensesByDate", expensesController.getExpensesByDate);
router.delete("/deleteExpense", expensesController.deleteExpense);

module.exports = router;
