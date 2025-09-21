const mongoose = require("mongoose");

const weatherAlertSchema = new mongoose.Schema({
  title: String,
  description: String,
  region: String, 
  severity: { type: String, enum: ["Low", "Medium", "High", "Critical"] },
  issuedAt: { type: Date, default: Date.now },
  validUntil: Date,
});

module.exports = mongoose.model("WeatherAlert", weatherAlertSchema);