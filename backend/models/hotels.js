const mongoose = require("mongoose");

const roomPackageSchema = new mongoose.Schema(
  {
    packageName: { type: String, required: true },
    roomType: { type: String, required: true },
    price: { type: Number, required: true },
    capacity: { type: Number, required: true },
    amenities: [String],
    description: String,
    images: [String], // Images for this specific room package
    status: {
      type: String,
      enum: ["active", "booked", "maintenance", "inactive"],
      default: "active",
    },
    availableRooms: { type: Number, required: true },
    totalRooms: { type: Number, required: true },
  },
  { timestamps: true }
);

const hotelSchema = new mongoose.Schema(
  {
    hotelName: { type: String, required: true },
    contactDetails: {
      phone: { type: String, required: true },
      email: { type: String, required: true },
      website: String,
      fax: String,
    },
    address: {
      street: { type: String, required: true },
      city: { type: String, required: true },
      province: { type: String, required: true },
      postalCode: String,
      country: { type: String, default: "Sri Lanka" },
    },
    otherContacts: {
      managerName: String,
      managerPhone: String,
      managerEmail: String,
      emergencyContact: String,
    },
    roomPackages: [roomPackageSchema],
    facilities: [String],
    images: [String],
    description: String,
    rating: { type: Number, min: 1, max: 5, default: 3 },
    isActive: { type: Boolean, default: true },
    checkInTime: { type: String, default: "14:00" },
    checkOutTime: { type: String, default: "11:00" },
    policies: {
      cancellation: String,
      petPolicy: String,
      smokingPolicy: String,
      otherPolicies: String,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Hotel", hotelSchema);
