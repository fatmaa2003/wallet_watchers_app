const express = require("express");
require("./config/db");

const app = express();
app.use(express.json());

// Routes
const userRoute = require('./routes/user.routes');
const categoriesRoute = require('./routes/categories.routes');
const expensesRoute = require('./routes/expenses.routes');
const receiptRoute = require('./routes/receipt.routes');
const goalRoutes = require('./routes/goals.routes');
const botpressRoutes = require('./routes/botpress.routes');
const collaborativeGoalRoutes = require('./routes/collaborativeGoal.routes');

// Register Routes
app.use("/api/users", userRoute);
app.use("/api/getAllCategories", categoriesRoute);
app.use("/api/expenses", expensesRoute);
app.use("/api/receipts", receiptRoute);
app.use("/api/goals", goalRoutes);
app.use("/api/botpress", botpressRoutes);
app.use("/api/collaborative-goals", collaborativeGoalRoutes);

module.exports = app;
