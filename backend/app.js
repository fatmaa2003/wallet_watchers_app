const express = require('express');
require("./config/db");

const app = express();
app.use(express.json());

require("./routes")(app);

module.exports = (app) =>
    {
        app.use('/api/users', userRoute),
        app.use('/api/getAllCategories', categoriesRoute)
    }

module.exports = app;


