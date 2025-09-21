const mongoose = require("mongoose");

const userSchema = new mongoose.Schema(
  {
    firstName: { type: String },
    lastName: { type: String },
    email: { type: String, unique: true, sparse: true }, // sparse allows multiple null values
    mobile: { type: String, unique: true, sparse: true }, // sparse allows multiple null values
    username: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    role: { type: String, ref: "RolePermissions", default: "user" },
    profileImage: { type: String },
  },
  {
    timestamps: true, // Adds createdAt and updatedAt fields
  }
);

module.exports = mongoose.model("User", userSchema);
