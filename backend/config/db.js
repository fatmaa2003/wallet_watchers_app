const mongoose = require("mongoose");
require("dotenv").config();

mongoose
  .connect(process.env.MONGO_URI)
  .then(async () => {
    console.log("connected to db");
  })
  .catch(() => {
    console.log("connection failed");
  });
