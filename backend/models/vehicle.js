const mongoose = require("mongoose");

const vehicleSchema = new mongoose.Schema({
  type: { type: String, required: true }, // e.g. Car, Van, Bus
  passengerAmount: { type: Number, required: true },
  owner: {
    name: String,
    phone: String,
    email: String,
  },
  rentPrice: Number, // Rent price per day
  driverCost: { type: Number, default: 0 }, // Driver cost per day
  images: [String],
  status: { type: String, default: "available" },
});

module.exports = mongoose.model("Vehicle", vehicleSchema);
