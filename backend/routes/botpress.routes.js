const express = require("express");
const router = express.Router();
const Expenses = require("../model/expenses.model");
const Income = require("../model/income.model");

// ✅ Test route to verify this file is loaded correctly
router.get("/test", (req, res) => {
  res.send("✅ Botpress route is working!");
});

// ✅ Main route used by Botpress Cloud
router.post("/financial-data", async (req, res) => {
  try {
    const { externalId, intent } = req.body;

    // Check for required fields
    if (!externalId || !intent) {
      return res.status(400).json({ error: "Missing externalId or intent" });
    }

    // Extract actual userId from externalId
    const userId = externalId.replace("wallet_user_", "");

    let response = {};

    // Intent: Get total expenses and breakdown by category
    if (intent === "get_expenses") {
      const expenses = await Expenses.aggregate([
        { $match: { userId } },
        {
          $group: {
            _id: null,
            total: { $sum: "$expenseAmount" },
            byCategory: {
              $push: { category: "$categoryName", amount: "$expenseAmount" }
            }
          }
        }
      ]);
      response = {
        total: expenses[0]?.total || 0,
        byCategory: expenses[0]?.byCategory || []
      };
    }

    // Intent: Get total income and breakdown by source
    else if (intent === "get_income") {
      const income = await Income.aggregate([
        { $match: { userId } },
        {
          $group: {
            _id: null,
            total: { $sum: "$incomeAmount" },
            bySource: {
              $push: { source: "$incomeName", amount: "$incomeAmount" }
            }
          }
        }
      ]);
      response = {
        total: income[0]?.total || 0,
        bySource: income[0]?.bySource || []
      };
    }

    // Intent: Get balance = income - expenses
    else if (intent === "get_balance") {
      const incomeTotal = (await Income.aggregate([
        { $match: { userId } },
        { $group: { _id: null, total: { $sum: "$incomeAmount" } } }
      ]))[0]?.total || 0;

      const expensesTotal = (await Expenses.aggregate([
        { $match: { userId } },
        { $group: { _id: null, total: { $sum: "$expenseAmount" } } }
      ]))[0]?.total || 0;

      response = {
        balance: incomeTotal - expensesTotal,
        income: incomeTotal,
        expenses: expensesTotal
      };
    }

    // Invalid intent
    else {
      response = { error: "Unknown intent" };
    }

    // Respond to Botpress
    res.json(response);

  } catch (err) {
    console.error("❌ Error in /financial-data:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});

module.exports = router;
