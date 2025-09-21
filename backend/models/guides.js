const mongoose = require("mongoose");

const guideSchema = new mongoose.Schema(
  {
    guideName: { type: String, required: true },
    description: String,

    // Contact Information
    contactDetails: {
      phone: { type: String, required: true },
      email: { type: String, required: true },
      website: String,
      emergencyContact: String,
    },

    // Address Information
    address: {
      street: { type: String, required: true },
      city: { type: String, required: true },
      province: { type: String, required: true },
      postalCode: String,
      country: { type: String, default: "Sri Lanka" },
    },

    // Professional Information
    experience: {
      yearsOfExperience: { type: Number, required: true, min: 0 },
      specializations: [String], // e.g., ["Historical Tours", "Nature Tours", "Cultural Tours"]
      languages: [String], // e.g., ["English", "Sinhala", "Tamil"]
      certifications: [String],
    },

    // License Information
    license: {
      licenseNumber: { type: String, required: true, unique: true },
      licenseType: { type: String, required: true }, // e.g., "Tourist Guide", "Nature Guide"
      issuedDate: { type: Date, required: true },
      expiryDate: { type: Date, required: true },
      issuingAuthority: { type: String, required: true },
      licenseImage: String, // Path to license document image
    },

    // Rating System
    ratings: {
      averageRating: { type: Number, default: 0, min: 0, max: 5 },
      totalRatings: { type: Number, default: 0 },
      ratingBreakdown: {
        fiveStar: { type: Number, default: 0 },
        fourStar: { type: Number, default: 0 },
        threeStar: { type: Number, default: 0 },
        twoStar: { type: Number, default: 0 },
        oneStar: { type: Number, default: 0 },
      },
      touristRatings: [
        {
          touristId: { type: String, required: true },
          touristName: String,
          rating: { type: Number, required: true, min: 1, max: 5 },
          review: String,
          date: { type: Date, default: Date.now },
        },
      ],
    },

    // Additional Information
    availability: {
      isAvailable: { type: Boolean, default: true },
      workingDays: [String], // e.g., ["Monday", "Tuesday", "Wednesday"]
      workingHours: {
        start: { type: String, default: "09:00" },
        end: { type: String, default: "18:00" },
      },
    },

    // Pricing
    pricing: {
      hourlyRate: { type: Number, required: true },
      dailyRate: { type: Number, required: true },
      currency: { type: String, default: "LKR" },
    },

    // Images
    images: [String], // Profile and professional photos

    // Status
    status: {
      type: String,
      enum: ["active", "inactive", "suspended", "pending_verification"],
      default: "pending_verification",
    },

    // Additional Details
    bio: String,
    achievements: [String],
    socialMedia: {
      facebook: String,
      instagram: String,
      linkedin: String,
      twitter: String,
    },
  },
  { timestamps: true }
);

// Index for search functionality
guideSchema.index({
  guideName: "text",
  description: "text",
  "address.city": "text",
  "address.province": "text",
});

module.exports = mongoose.model("Guide", guideSchema);
