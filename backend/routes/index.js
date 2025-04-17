const userRoute = require("./users.routes");
const categoriesRoute = require("./categories.routes");
const expensesRoute = require("./expenses.routes");
const receiptRoute = require("./receipts.routes");

module.exports = (app) => {
  app.use("/api/users", userRoute);
  app.use("/api/categories", categoriesRoute);
  app.use("/api/expenses", expensesRoute);
  app.use("/api/receipts", receiptRoute);
};