const userRoute = require("./users.routes");
const categoriesRoute = require("./categories.routes");
const expensesRoute = require("./expenses.routes");
const receiptRoute = require("./receipts.routes");
const goalRoutes = require("./goals.routes");
const profileRoutes = require("./profile.routes");
const incomeRoutes = require("./income.routes");
const botpressRoutes = require("./botpress.routes");
const aiRoutes = require("./ai.routes");

module.exports = (app) => {
  app.use("/api/users", userRoute);
  app.use("/api/categories", categoriesRoute);
  app.use("/api/expenses", expensesRoute);
  app.use("/api/receipts", receiptRoute);
  app.use("/api/goals", goalRoutes);
  app.use("/api/profile", profileRoutes);
  app.use("/api/income", incomeRoutes);
  app.use("/api/botpress", botpressRoutes);
  app.use("/api/ai", aiRoutes);
};
