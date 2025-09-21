const express = require("express");
const connectDB = require("./config/database");
const routes = require("./routes/index");
const {
  corsMiddleware,
  bodyParserMiddleware,
} = require("./middleware/commonMiddleware");
require("dotenv").config();
const path = require("path");
const cors = require("cors");

const app = express();

// Middleware
app.use(corsMiddleware);
app.use(bodyParserMiddleware);

// Static uploads
// app.use(cors());
app.use(express.json());
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

// DB Connect
connectDB();

// Routes
app.use("/api", routes);

app.get("/", (req, res) => {
  res.send("🚀 TourPlanner Backend Running...");
});

// 404
app.use((req, res) => {
  res.status(404).json({ status: "error", message: "Route not found" });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error("Global error:", err);
  res
    .status(err.status || 500)
    .json({ status: "error", message: err.message || "Internal Server Error" });
});

const PORT = process.env.PORT || 4007;
app.listen(PORT, "0.0.0.0", () =>
  console.log(`✅ Server running on port ${PORT}`)
);
