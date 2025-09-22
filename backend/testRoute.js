const express = require("express");
const routes = require("./routes/index");

// Create a simple express app to test routes
const app = express();
app.use("/api", routes);

// Get all registered routes
const expressListRoutes = require("express-list-routes");
expressListRoutes(app, { prefix: "" });

console.log("Routes registered successfully");
