const mongoose = require("mongoose");

const placeSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    description: String,
    province: String,
    district: String,
    location: String,
    mapUrl: String,
    latitude: String,
    longitude: String,
    visitingHours: String,
    entryFee: String,
    bestTimeToVisit: String,
    transportation: String,
    highlights: [String],
    images: [String], 
  },
  { timestamps: true }
);

module.exports = mongoose.model("Place", placeSchema);
