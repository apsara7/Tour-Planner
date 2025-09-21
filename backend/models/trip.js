const mongoose = require("mongoose");

const tripSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },
    description: {
      type: String,
      trim: true,
    },
    userId: {
      type: String,
      required: true,
      index: true,
    },
    startDate: {
      type: Date,
      default: null,
    },
    endDate: {
      type: Date,
      default: null,
    },
    travellersCount: {
      type: Number,
      default: 1,
      min: 1,
      max: 50,
    },
    estimatedBudget: {
      entriesTotal: {
        type: Number,
        default: 0,
      },
      guidesTotal: {
        type: Number,
        default: 0,
      },
      hotelsTotal: {
        type: Number,
        default: 0,
      },
      vehiclesTotal: {
        type: Number,
        default: 0,
      },
      otherExpenses: {
        type: Number,
        default: 0,
      },
      totalBudget: {
        type: Number,
        default: 0,
      },
    },
    places: [
      {
        placeId: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "Place",
          required: true,
        },
        addedAt: {
          type: Date,
          default: Date.now,
        },
        notes: {
          type: String,
          default: "",
        },
      },
    ],
    guides: [
      {
        guideId: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "Guide",
          required: true,
        },
        addedAt: {
          type: Date,
          default: Date.now,
        },
        notes: {
          type: String,
          default: "",
        },
        workingHours: {
          start: {
            type: String,
            default: "09:00",
          },
          end: {
            type: String,
            default: "18:00",
          },
          hoursPerDay: {
            type: Number,
            default: 8,
          },
        },
        dailyCost: {
          type: Number,
          default: 0,
        },
        totalTripCost: {
          type: Number,
          default: 0,
        },
      },
    ],
    hotels: [
      {
        hotelId: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "Hotel",
          required: true,
        },
        packageId: {
          type: mongoose.Schema.Types.ObjectId,
          required: true,
        },
        addedAt: {
          type: Date,
          default: Date.now,
        },
        notes: {
          type: String,
          default: "",
        },
        bookingDetails: {
          checkInDate: {
            type: Date,
            required: true,
          },
          checkOutDate: {
            type: Date,
            required: true,
          },
          roomsBooked: {
            type: Number,
            default: 1,
          },
          guestCount: {
            type: Number,
            default: 2,
          },
          totalPrice: {
            type: Number,
            default: 0,
          },
        },
        dailyCost: {
          type: Number,
          default: 0,
        },
        totalTripCost: {
          type: Number,
          default: 0,
        },
      },
    ],
    vehicles: [
      {
        vehicleId: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "Vehicle",
          required: true,
        },
        addedAt: {
          type: Date,
          default: Date.now,
        },
        notes: {
          type: String,
          default: "",
        },
        travellersCount: {
          type: Number,
          default: 1,
          min: 1,
        },
        dailyCost: {
          type: Number,
          default: 0,
        },
        totalTripCost: {
          type: Number,
          default: 0,
        },
      },
    ],
    status: {
      type: String,
      enum: ["planning", "confirmed", "ongoing", "completed", "cancelled"],
      default: "planning",
    },
    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

// Index for better query performance
tripSchema.index({ userId: 1, isActive: 1 });
tripSchema.index({ userId: 1, status: 1 });

module.exports = mongoose.model("Trip", tripSchema);
