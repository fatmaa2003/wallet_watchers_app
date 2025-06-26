const express = require("express");
require("./config/db");

const app = express();
app.use(express.json());

require("./routes")(app);

module.exports = (app) => {
app.use("/api/users", userRoute),
app.use("/api/getAllCategories", categoriesRoute);
app.use("/api/expenses", expensesRoute);
app.use("/api/receipts", receiptRoute);
app.use("/api/goals", goalRoutes);
app.use("/api/botpress", botpressRoutes);
app.use("/api/cards", cardsRoute);

};


module.exports = app;   