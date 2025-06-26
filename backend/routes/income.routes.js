const express = require("express");
const router = express.Router();
const incomeController = require("../controller/income.controller");

router.get("/getIncome", incomeController.getIncome);
router.post("/postIncome", incomeController.postIncome);
router.patch("/updateIncome", incomeController.updateIncome);
router.delete("/deleteIncome", incomeController.deleteIncome);

module.exports = router;
