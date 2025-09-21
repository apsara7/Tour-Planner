const Trip = require("../models/trip");
const Place = require("../models/places");
const Guide = require("../models/guides");
const Hotel = require("../models/hotels");
const Vehicle = require("../models/vehicle");

// Helper function to recalculate trip budget
const recalculateTripBudget = async (trip) => {
  try {
    let entriesTotal = 0;
    let guidesTotal = 0;
    let hotelsTotal = 0;
    let vehiclesTotal = 0;

    // Calculate total entry fees for all places
    for (const placeItem of trip.places) {
      const place = await Place.findById(placeItem.placeId);
      if (place && place.entryFee) {
        // Extract numeric value from entry fee string
        const feeMatch = place.entryFee.match(/([0-9,]+(?:\.[0-9]+)?)/);
        if (feeMatch) {
          const fee = parseFloat(feeMatch[1].replace(/,/g, "")) || 0;
          entriesTotal += fee * trip.travellersCount;
        }
      }
    }

    // Calculate total cost for all guides for the entire trip duration
    const tripDays =
      trip.startDate && trip.endDate
        ? Math.max(
            1,
            Math.floor(
              (trip.endDate - trip.startDate) / (1000 * 60 * 60 * 24)
            ) + 1
          )
        : 1;

    for (const guideItem of trip.guides) {
      const guide = await Guide.findById(guideItem.guideId);
      if (guide && guide.pricing) {
        // Use the guide's daily rate for the entire trip duration
        const dailyRate = guide.pricing.dailyRate || 0;
        const totalGuideTrip = dailyRate * tripDays;

        // Store the daily rate and total trip cost in the guide item
        guideItem.dailyCost = dailyRate;
        guideItem.totalTripCost = totalGuideTrip;
        // Add total trip cost to guides total
        guidesTotal += totalGuideTrip;
      }
    }

    // Calculate total cost for all hotels
    for (const hotelItem of trip.hotels) {
      // Add the total price from the booking details
      hotelsTotal += hotelItem.bookingDetails.totalPrice || 0;
    }

    // Calculate total cost for all vehicles
    for (const vehicleItem of trip.vehicles) {
      const vehicle = await Vehicle.findById(vehicleItem.vehicleId);
      if (vehicle && vehicle.rentPrice) {
        // Calculate total cost based on trip duration
        const tripDays =
          trip.startDate && trip.endDate
            ? Math.max(
                1,
                Math.floor(
                  (trip.endDate - trip.startDate) / (1000 * 60 * 60 * 24)
                ) + 1
              )
            : 1;

        // Calculate vehicle rent cost
        const vehicleRentCost = vehicle.rentPrice * tripDays;

        // Calculate driver cost if needed
        const driverCost =
          vehicleItem.withDriver && vehicle.driverCost
            ? vehicle.driverCost * tripDays
            : 0;

        // Total vehicle cost
        const totalVehicleTrip = vehicleRentCost + driverCost;

        // Store the daily costs and total trip cost in the vehicle item
        vehicleItem.dailyCost =
          vehicle.rentPrice +
          (vehicleItem.withDriver ? vehicle.driverCost || 0 : 0);
        vehicleItem.totalTripCost = totalVehicleTrip;
        // Add total trip cost to vehicles total
        vehiclesTotal += totalVehicleTrip;
      }
    }

    trip.estimatedBudget.entriesTotal = entriesTotal;
    trip.estimatedBudget.guidesTotal = guidesTotal;
    trip.estimatedBudget.hotelsTotal = hotelsTotal;
    trip.estimatedBudget.vehiclesTotal = vehiclesTotal;
    trip.estimatedBudget.totalBudget =
      entriesTotal +
      guidesTotal +
      hotelsTotal +
      vehiclesTotal +
      trip.estimatedBudget.otherExpenses;

    return trip;
  } catch (error) {
    console.error("Error recalculating budget:", error);
    return trip;
  }
};

// ✅ Create a new trip
const createTrip = async (req, res) => {
  try {
    const { name, description, startDate, endDate } = req.body;
    const userId = req.user?.id || req.body.userId; // Get from auth middleware or body

    if (!name) {
      return res.status(400).json({ message: "Trip name is required" });
    }

    if (!userId) {
      return res.status(400).json({ message: "User ID is required" });
    }

    const newTrip = new Trip({
      name,
      description,
      userId,
      startDate: startDate ? new Date(startDate) : null,
      endDate: endDate ? new Date(endDate) : null,
      places: [],
    });

    await newTrip.save();
    res.status(201).json({ status: "Success", trip: newTrip });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

// ✅ Get all trips for a user
const getUserTrips = async (req, res) => {
  try {
    const userId = req.user?.id || req.params.userId;

    if (!userId) {
      return res.status(400).json({ message: "User ID is required" });
    }

    const trips = await Trip.find({
      userId,
      isActive: true,
    })
      .populate("places.placeId")
      .populate("guides.guideId")
      .sort({ updatedAt: -1 });

    res.json({ status: "Success", trips });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

// ✅ Get trip by ID
const getTripById = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user?.id || req.query.userId;

    const trip = await Trip.findOne({
      _id: id,
      userId,
      isActive: true,
    })
      .populate("places.placeId")
      .populate("guides.guideId");

    if (!trip) {
      return res.status(404).json({ message: "Trip not found" });
    }

    res.json({ status: "Success", trip });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

// ✅ Add place to trip
const addPlaceToTrip = async (req, res) => {
  try {
    const { tripId, placeId, notes } = req.body;
    const userId = req.user?.id || req.body.userId;

    if (!tripId || !placeId) {
      return res
        .status(400)
        .json({ message: "Trip ID and Place ID are required" });
    }

    // Verify place exists
    const place = await Place.findById(placeId);
    if (!place) {
      return res.status(404).json({ message: "Place not found" });
    }

    // Find trip and verify ownership
    const trip = await Trip.findOne({
      _id: tripId,
      userId,
      isActive: true,
    });

    if (!trip) {
      return res
        .status(404)
        .json({ message: "Trip not found or access denied" });
    }

    // Check if place is already in trip
    const placeExists = trip.places.some(
      (p) => p.placeId.toString() === placeId
    );
    if (placeExists) {
      return res
        .status(400)
        .json({ message: "Place already added to this trip" });
    }

    // Add place to trip
    trip.places.push({
      placeId,
      notes: notes || "",
      addedAt: new Date(),
    });

    // Recalculate budget after adding place
    await recalculateTripBudget(trip);
    await trip.save();

    // Return updated trip with populated places
    const updatedTrip = await Trip.findById(tripId)
      .populate("places.placeId")
      .populate("guides.guideId");
    res.json({
      status: "Success",
      trip: updatedTrip,
      message: "Place added to trip successfully",
    });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

// ✅ Remove place from trip
const removePlaceFromTrip = async (req, res) => {
  try {
    const { tripId, placeId } = req.body;
    const userId = req.user?.id || req.body.userId;

    if (!tripId || !placeId) {
      return res
        .status(400)
        .json({ message: "Trip ID and Place ID are required" });
    }

    // Find trip and verify ownership
    const trip = await Trip.findOne({
      _id: tripId,
      userId,
      isActive: true,
    });

    if (!trip) {
      return res
        .status(404)
        .json({ message: "Trip not found or access denied" });
    }

    // Remove place from trip
    trip.places = trip.places.filter((p) => p.placeId.toString() !== placeId);

    // Recalculate budget after removing place
    await recalculateTripBudget(trip);
    await trip.save();

    // Return updated trip with populated places
    const updatedTrip = await Trip.findById(tripId)
      .populate("places.placeId")
      .populate("guides.guideId");
    res.json({
      status: "Success",
      trip: updatedTrip,
      message: "Place removed from trip successfully",
    });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

// ✅ Update trip details
const updateTrip = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      name,
      description,
      startDate,
      endDate,
      status,
      travellersCount,
      otherExpenses,
    } = req.body;
    const userId = req.user?.id || req.body.userId;

    const trip = await Trip.findOne({
      _id: id,
      userId,
      isActive: true,
    });

    if (!trip) {
      return res
        .status(404)
        .json({ message: "Trip not found or access denied" });
    }

    // Update fields
    if (name !== undefined) trip.name = name;
    if (description !== undefined) trip.description = description;
    if (startDate !== undefined)
      trip.startDate = startDate ? new Date(startDate) : null;
    if (endDate !== undefined)
      trip.endDate = endDate ? new Date(endDate) : null;
    if (status !== undefined) trip.status = status;
    if (travellersCount !== undefined) {
      trip.travellersCount = Math.max(
        1,
        Math.min(50, parseInt(travellersCount))
      );
    }
    if (otherExpenses !== undefined) {
      trip.estimatedBudget.otherExpenses = Math.max(
        0,
        parseFloat(otherExpenses)
      );
    }

    // Recalculate budget if places or travellers count changed
    await recalculateTripBudget(trip);

    await trip.save();

    const updatedTrip = await Trip.findById(id)
      .populate("places.placeId")
      .populate("guides.guideId");
    res.json({ status: "Success", trip: updatedTrip });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

// ✅ Delete trip (soft delete)
const deleteTrip = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user?.id || req.body.userId;

    const trip = await Trip.findOne({
      _id: id,
      userId,
      isActive: true,
    });

    if (!trip) {
      return res
        .status(404)
        .json({ message: "Trip not found or access denied" });
    }

    trip.isActive = false;
    await trip.save();

    res.json({ status: "Success", message: "Trip deleted successfully" });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

// ✅ Get or create default trip for a user
const getOrCreateDefaultTrip = async (req, res) => {
  try {
    const userId = req.user?.id || req.params.userId || req.body.userId;

    if (!userId) {
      return res.status(400).json({ message: "User ID is required" });
    }

    // Try to find an existing default trip
    let trip = await Trip.findOne({
      userId,
      isActive: true,
      name: "My Sri Lanka Trip",
    })
      .populate("places.placeId")
      .populate("guides.guideId");

    // If no default trip exists, create one
    if (!trip) {
      trip = new Trip({
        name: "My Sri Lanka Trip",
        description: "Places I want to visit in Sri Lanka",
        userId,
        places: [],
      });
      await trip.save();

      // Populate the newly created trip
      trip = await Trip.findById(trip._id)
        .populate("places.placeId")
        .populate("guides.guideId");
    }

    res.json({ status: "Success", trip });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

// ✅ Add guide to trip
const addGuideToTrip = async (req, res) => {
  try {
    const { tripId, guideId, notes, workingHours } = req.body;
    const userId = req.user?.id || req.body.userId;

    if (!tripId || !guideId) {
      return res
        .status(400)
        .json({ message: "Trip ID and Guide ID are required" });
    }

    // Verify guide exists
    const guide = await Guide.findById(guideId);
    if (!guide) {
      return res.status(404).json({ message: "Guide not found" });
    }

    // Find trip and verify ownership
    const trip = await Trip.findOne({
      _id: tripId,
      userId,
      isActive: true,
    });

    if (!trip) {
      return res
        .status(404)
        .json({ message: "Trip not found or access denied" });
    }

    // Check if guide is already in trip
    const guideExists = trip.guides.some(
      (g) => g.guideId.toString() === guideId
    );
    if (guideExists) {
      return res
        .status(400)
        .json({ message: "Guide already added to this trip" });
    }

    // Prepare working hours with defaults from guide's availability (for display only)
    const guideWorkingHours = {
      start:
        workingHours?.start ||
        guide.availability?.workingHours?.start ||
        "09:00",
      end:
        workingHours?.end || guide.availability?.workingHours?.end || "18:00",
      hoursPerDay: 8, // Fixed value for display - not used in calculations
    };

    // Use guide's daily rate and calculate total trip cost
    const dailyRate = guide.pricing?.dailyRate || 0;
    const tripDays =
      trip.startDate && trip.endDate
        ? Math.max(
            1,
            Math.floor(
              (trip.endDate - trip.startDate) / (1000 * 60 * 60 * 24)
            ) + 1
          )
        : 1;
    const totalTripCost = dailyRate * tripDays;

    // Add guide to trip
    trip.guides.push({
      guideId,
      notes: notes || "",
      addedAt: new Date(),
      workingHours: guideWorkingHours,
      dailyCost: dailyRate,
      totalTripCost: totalTripCost,
    });

    // Recalculate budget after adding guide
    await recalculateTripBudget(trip);
    await trip.save();

    // Return updated trip with populated guides
    const updatedTrip = await Trip.findById(tripId)
      .populate("places.placeId")
      .populate("guides.guideId");
    res.json({
      status: "Success",
      trip: updatedTrip,
      message: "Guide added to trip successfully",
    });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

// ✅ Remove guide from trip
const removeGuideFromTrip = async (req, res) => {
  try {
    const { tripId, guideId } = req.body;
    const userId = req.user?.id || req.body.userId;

    if (!tripId || !guideId) {
      return res
        .status(400)
        .json({ message: "Trip ID and Guide ID are required" });
    }

    // Find trip and verify ownership
    const trip = await Trip.findOne({
      _id: tripId,
      userId,
      isActive: true,
    });

    if (!trip) {
      return res
        .status(404)
        .json({ message: "Trip not found or access denied" });
    }

    // Remove guide from trip
    trip.guides = trip.guides.filter((g) => g.guideId.toString() !== guideId);

    // Recalculate budget after removing guide
    await recalculateTripBudget(trip);
    await trip.save();

    // Return updated trip with populated guides
    const updatedTrip = await Trip.findById(tripId)
      .populate("places.placeId")
      .populate("guides.guideId");
    res.json({
      status: "Success",
      trip: updatedTrip,
      message: "Guide removed from trip successfully",
    });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

// ✅ Update guide working hours in trip
const updateGuideInTrip = async (req, res) => {
  try {
    const { tripId, guideId, workingHours, notes } = req.body;
    const userId = req.user?.id || req.body.userId;

    if (!tripId || !guideId) {
      return res
        .status(400)
        .json({ message: "Trip ID and Guide ID are required" });
    }

    // Find trip and verify ownership
    const trip = await Trip.findOne({
      _id: tripId,
      userId,
      isActive: true,
    });

    if (!trip) {
      return res
        .status(404)
        .json({ message: "Trip not found or access denied" });
    }

    // Find the guide in the trip
    const guideIndex = trip.guides.findIndex(
      (g) => g.guideId.toString() === guideId
    );

    if (guideIndex === -1) {
      return res.status(404).json({ message: "Guide not found in this trip" });
    }

    // Get guide details for pricing
    const guide = await Guide.findById(guideId);
    if (!guide) {
      return res.status(404).json({ message: "Guide not found" });
    }

    // Update working hours and notes
    if (workingHours) {
      trip.guides[guideIndex].workingHours = {
        ...trip.guides[guideIndex].workingHours,
        ...workingHours,
      };

      // Use guide's daily rate directly
      const dailyRate = guide.pricing?.dailyRate || 0;
      trip.guides[guideIndex].dailyCost = dailyRate;
    }

    if (notes !== undefined) {
      trip.guides[guideIndex].notes = notes;
    }

    // Recalculate budget after updating guide
    await recalculateTripBudget(trip);
    await trip.save();

    // Return updated trip with populated guides
    const updatedTrip = await Trip.findById(tripId)
      .populate("places.placeId")
      .populate("guides.guideId");
    res.json({
      status: "Success",
      trip: updatedTrip,
      message: "Guide updated in trip successfully",
    });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

// ✅ Add hotel to trip
const addHotelToTrip = async (req, res) => {
  try {
    const { tripId, hotelId, packageId, bookingDetails, notes } = req.body;
    const userId = req.user?.id || req.body.userId;

    if (!tripId || !hotelId || !packageId || !bookingDetails) {
      return res.status(400).json({
        message:
          "Trip ID, Hotel ID, Package ID, and booking details are required",
      });
    }

    // Verify hotel exists
    const hotel = await Hotel.findById(hotelId);
    if (!hotel) {
      return res.status(404).json({ message: "Hotel not found" });
    }

    // Verify package exists in hotel
    const packageExists = hotel.roomPackages.some(
      (pkg) => pkg._id.toString() === packageId
    );
    if (!packageExists) {
      return res.status(404).json({ message: "Package not found in hotel" });
    }

    // Find trip and verify ownership
    const trip = await Trip.findOne({
      _id: tripId,
      userId,
      isActive: true,
    });

    if (!trip) {
      return res
        .status(404)
        .json({ message: "Trip not found or access denied" });
    }

    // Check if hotel is already in trip
    const hotelExists = trip.hotels.some(
      (h) => h.hotelId.toString() === hotelId
    );
    if (hotelExists) {
      return res
        .status(400)
        .json({ message: "Hotel already added to this trip" });
    }

    // Calculate daily cost based on total price and number of nights
    const checkInDate = new Date(bookingDetails.checkInDate);
    const checkOutDate = new Date(bookingDetails.checkOutDate);
    const nights = Math.max(
      1,
      Math.floor((checkOutDate - checkInDate) / (1000 * 60 * 60 * 24))
    );
    const dailyCost =
      nights > 0 ? (bookingDetails.totalPrice || 0) / nights : 0;

    // Add hotel to trip
    trip.hotels.push({
      hotelId,
      packageId,
      notes: notes || "",
      addedAt: new Date(),
      bookingDetails: {
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        roomsBooked: bookingDetails.roomsBooked || 1,
        guestCount: bookingDetails.guestCount || 2,
        totalPrice: bookingDetails.totalPrice || 0,
      },
      dailyCost: dailyCost,
      totalTripCost: bookingDetails.totalPrice || 0,
    });

    // Recalculate budget after adding hotel
    await recalculateTripBudget(trip);
    await trip.save();

    // Return updated trip with populated hotels (when hotel model is created)
    const updatedTrip = await Trip.findById(tripId)
      .populate("places.placeId")
      .populate("guides.guideId");
    res.json({
      status: "Success",
      trip: updatedTrip,
      message: "Hotel added to trip successfully",
    });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

// ✅ Remove hotel from trip
const removeHotelFromTrip = async (req, res) => {
  try {
    const { tripId, hotelId } = req.body;
    const userId = req.user?.id || req.body.userId;

    if (!tripId || !hotelId) {
      return res
        .status(400)
        .json({ message: "Trip ID and Hotel ID are required" });
    }

    // Find trip and verify ownership
    const trip = await Trip.findOne({
      _id: tripId,
      userId,
      isActive: true,
    });

    if (!trip) {
      return res
        .status(404)
        .json({ message: "Trip not found or access denied" });
    }

    // Remove hotel from trip
    trip.hotels = trip.hotels.filter((h) => h.hotelId.toString() !== hotelId);

    // Recalculate budget after removing hotel
    await recalculateTripBudget(trip);
    await trip.save();

    // Return updated trip
    const updatedTrip = await Trip.findById(tripId)
      .populate("places.placeId")
      .populate("guides.guideId");
    res.json({
      status: "Success",
      trip: updatedTrip,
      message: "Hotel removed from trip successfully",
    });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

// ✅ Update hotel in trip
const updateHotelInTrip = async (req, res) => {
  try {
    const { tripId, hotelId, bookingDetails, notes } = req.body;
    const userId = req.user?.id || req.body.userId;

    if (!tripId || !hotelId) {
      return res
        .status(400)
        .json({ message: "Trip ID and Hotel ID are required" });
    }

    // Find trip and verify ownership
    const trip = await Trip.findOne({
      _id: tripId,
      userId,
      isActive: true,
    });

    if (!trip) {
      return res
        .status(404)
        .json({ message: "Trip not found or access denied" });
    }

    // Find hotel in trip
    const hotelIndex = trip.hotels.findIndex(
      (h) => h.hotelId.toString() === hotelId
    );

    if (hotelIndex === -1) {
      return res.status(404).json({ message: "Hotel not found in trip" });
    }

    // Update hotel details
    if (bookingDetails) {
      // Update booking details
      trip.hotels[hotelIndex].bookingDetails = {
        ...trip.hotels[hotelIndex].bookingDetails,
        ...bookingDetails,
      };

      // Recalculate costs
      const checkInDate = new Date(bookingDetails.checkInDate);
      const checkOutDate = new Date(bookingDetails.checkOutDate);
      const nights = Math.max(
        1,
        Math.floor((checkOutDate - checkInDate) / (1000 * 60 * 60 * 24))
      );
      const dailyCost =
        nights > 0 ? (bookingDetails.totalPrice || 0) / nights : 0;

      trip.hotels[hotelIndex].dailyCost = dailyCost;
      trip.hotels[hotelIndex].totalTripCost = bookingDetails.totalPrice || 0;
    }

    if (notes !== undefined) {
      trip.hotels[hotelIndex].notes = notes;
    }

    // Recalculate budget after updating hotel
    await recalculateTripBudget(trip);
    await trip.save();

    // Return updated trip
    const updatedTrip = await Trip.findById(tripId)
      .populate("places.placeId")
      .populate("guides.guideId");
    res.json({
      status: "Success",
      trip: updatedTrip,
      message: "Hotel updated in trip successfully",
    });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

// ✅ Add vehicle to trip
const addVehicleToTrip = async (req, res) => {
  try {
    const { tripId, vehicleId, travellersCount, notes, withDriver } = req.body;
    const userId = req.user?.id || req.body.userId;

    if (!tripId || !vehicleId) {
      return res
        .status(400)
        .json({ message: "Trip ID and Vehicle ID are required" });
    }

    // Verify vehicle exists
    const vehicle = await Vehicle.findById(vehicleId);
    if (!vehicle) {
      return res.status(404).json({ message: "Vehicle not found" });
    }

    // Check if vehicle is available
    if (vehicle.status !== "available") {
      return res.status(400).json({ message: "Vehicle is not available" });
    }

    // Check if travellersCount is valid
    if (travellersCount && travellersCount > vehicle.passengerAmount) {
      return res.status(400).json({
        message: `Vehicle can only accommodate ${vehicle.passengerAmount} passengers`,
      });
    }

    // Find trip and verify ownership
    const trip = await Trip.findOne({
      _id: tripId,
      userId,
      isActive: true,
    });

    if (!trip) {
      return res
        .status(404)
        .json({ message: "Trip not found or access denied" });
    }

    // Check if vehicle is already in trip
    const vehicleExists = trip.vehicles.some(
      (v) => v.vehicleId.toString() === vehicleId
    );
    if (vehicleExists) {
      return res
        .status(400)
        .json({ message: "Vehicle already added to this trip" });
    }

    // Add vehicle to trip
    trip.vehicles.push({
      vehicleId,
      travellersCount: travellersCount || 1,
      notes: notes || "",
      withDriver: withDriver || false, // Store driver option
      addedAt: new Date(),
    });

    // Recalculate budget after adding vehicle
    await recalculateTripBudget(trip);
    await trip.save();

    // Return updated trip
    const updatedTrip = await Trip.findById(tripId)
      .populate("places.placeId")
      .populate("guides.guideId");
    res.json({
      status: "Success",
      trip: updatedTrip,
      message: "Vehicle added to trip successfully",
    });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

// ✅ Remove vehicle from trip
const removeVehicleFromTrip = async (req, res) => {
  try {
    const { tripId, vehicleId } = req.body;
    const userId = req.user?.id || req.body.userId;

    if (!tripId || !vehicleId) {
      return res
        .status(400)
        .json({ message: "Trip ID and Vehicle ID are required" });
    }

    // Find trip and verify ownership
    const trip = await Trip.findOne({
      _id: tripId,
      userId,
      isActive: true,
    });

    if (!trip) {
      return res
        .status(404)
        .json({ message: "Trip not found or access denied" });
    }

    // Remove vehicle from trip
    trip.vehicles = trip.vehicles.filter(
      (v) => v.vehicleId.toString() !== vehicleId
    );

    // Recalculate budget after removing vehicle
    await recalculateTripBudget(trip);
    await trip.save();

    // Return updated trip
    const updatedTrip = await Trip.findById(tripId)
      .populate("places.placeId")
      .populate("guides.guideId");
    res.json({
      status: "Success",
      trip: updatedTrip,
      message: "Vehicle removed from trip successfully",
    });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

// ✅ Update vehicle in trip
const updateVehicleInTrip = async (req, res) => {
  try {
    const { tripId, vehicleId, travellersCount, notes, withDriver } = req.body;
    const userId = req.user?.id || req.body.userId;

    if (!tripId || !vehicleId) {
      return res
        .status(400)
        .json({ message: "Trip ID and Vehicle ID are required" });
    }

    // Find trip and verify ownership
    const trip = await Trip.findOne({
      _id: tripId,
      userId,
      isActive: true,
    });

    if (!trip) {
      return res
        .status(404)
        .json({ message: "Trip not found or access denied" });
    }

    // Find vehicle in trip
    const vehicleIndex = trip.vehicles.findIndex(
      (v) => v.vehicleId.toString() === vehicleId
    );

    if (vehicleIndex === -1) {
      return res.status(404).json({ message: "Vehicle not found in trip" });
    }

    // Update vehicle details
    if (travellersCount !== undefined) {
      // Verify vehicle exists and can accommodate the travellers
      const vehicle = await Vehicle.findById(vehicleId);
      if (vehicle && travellersCount > vehicle.passengerAmount) {
        return res.status(400).json({
          message: `Vehicle can only accommodate ${vehicle.passengerAmount} passengers`,
        });
      }

      trip.vehicles[vehicleIndex].travellersCount = travellersCount;
    }

    if (notes !== undefined) {
      trip.vehicles[vehicleIndex].notes = notes;
    }

    if (withDriver !== undefined) {
      trip.vehicles[vehicleIndex].withDriver = withDriver;
    }

    // Recalculate budget after updating vehicle
    await recalculateTripBudget(trip);
    await trip.save();

    // Return updated trip
    const updatedTrip = await Trip.findById(tripId)
      .populate("places.placeId")
      .populate("guides.guideId");
    res.json({
      status: "Success",
      trip: updatedTrip,
      message: "Vehicle updated in trip successfully",
    });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

module.exports = {
  createTrip,
  getUserTrips,
  getTripById,
  addPlaceToTrip,
  removePlaceFromTrip,
  updateTrip,
  deleteTrip,
  getOrCreateDefaultTrip,
  addGuideToTrip,
  removeGuideFromTrip,
  updateGuideInTrip,
  addHotelToTrip,
  removeHotelFromTrip,
  updateHotelInTrip,
  addVehicleToTrip,
  removeVehicleFromTrip,
  updateVehicleInTrip,
};
