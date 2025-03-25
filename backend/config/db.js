const mongoose = require("mongoose");
require("dotenv").config();

console.log("string",process.env.MONGO_URI)

mongoose
  .connect(process.env.MONGO_URI)
  .then(async () => {
    console.log("connected to db");
  })
  .catch((error) => {
    console.log("connection failed", error);
  });
