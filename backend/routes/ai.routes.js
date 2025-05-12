const express = require("express");
const router = express.Router();
const axios = require("axios");
const Budget = require("../model/budget.model");

router.post("/generateBudget", async (req, res) => {
  const { userId } = req.body;

  try {
    const response = await axios.post("http://localhost:8000/predict_budget", { userId });
    const budget = response.data;

    // Save to DB
    await Budget.create({ userId, ...budget, createdAt: new Date() });

    res.status(200).json(budget);
  } catch (err) {
    console.error("Error generating budget:", err.message);
    res.status(500).json({ error: "AI budget prediction failed" });
  }
});

module.exports = router;
