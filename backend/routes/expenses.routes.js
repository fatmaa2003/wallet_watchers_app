const express = require("express");
const router = express.Router();
const expensesController = require ('../controller/expenses.controller');


router.post("/postAllExpenses" , expensesController.postAllExpenses);
router.post("/postExpenses" , expensesController.postExpenses );
router.post("/postExpenses", expensesController.postExpenses);
router.get("/getExpensesByDate", expensesController.getExpensesByDate);

module.exports = router;