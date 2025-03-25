const express = require('express');
require("./config/db");

const app = express();
app.use(express.json());

require("./routes")(app);

module.exports = (app) =>
    {
        app.use('/api/users', userRoute),
        app.use('/api/getAllCategories', categoriesRoute)
        // app.use('/api/postExpenses', expensesRoute); 
        app.use("/api/expenses", expensesRoute);

    }

module.exports = app;


