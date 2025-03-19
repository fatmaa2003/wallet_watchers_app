const express = require('express');
const db = require('./config/db');

const User = require("./model/user.model");
const Category = require("./model/categories.model");

const app = express();
app.use(express.json());

const port = 3000;

// Basic route
app.get('/', (req, res) => {
    res.send("Hello world!");
});

// POST route to create categories
app.post('/api/categories', async (req, res) => {
    try {
        const category = await Category.create(req.body);
        res.status(200).json(category);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

//app.get bta3t drop down bta3t el categories, yecall api betget el categories kolaha.

//api.post('/addexpense) , haygely feha object user id number wel expense number category id number,bel user id da hadwr fel users table 3la el user, then fel list of expenses, ha add el expense de: el list gowaha el category id wel amount wel category name.
app.listen(port, () => {
    console.log(`Server listening on http://localhost:${port}`);
});
