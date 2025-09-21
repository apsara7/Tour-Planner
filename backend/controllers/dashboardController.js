const User = require("../models/userModel");
const Hotel = require("../models/hotels");
const Vehicle = require("../models/vehicle");
const Place = require("../models/places");
const Guide = require("../models/guides");
const WeatherAlert = require("../models/weatherAlert");
const Trip = require("../models/trip");

// Fetch all dashboard statistics
const getDashboardStatistics = async (req, res) => {
  try {
    console.log("Dashboard statistics endpoint hit");
    console.log("Request headers:", req.headers);
    console.log("User from token:", req.user);

    // Get counts for all required entities
    const totalUsers = await User.countDocuments();
    console.log("Total users:", totalUsers);

    const totalHotels = await Hotel.countDocuments();
    console.log("Total hotels:", totalHotels);

    const totalVehicles = await Vehicle.countDocuments();
    console.log("Total vehicles:", totalVehicles);

    const totalPlaces = await Place.countDocuments();
    console.log("Total places:", totalPlaces);

    const activeGuides = await Guide.countDocuments({ status: "active" });
    console.log("Active guides:", activeGuides);

    const totalWeatherAlerts = await WeatherAlert.countDocuments();
    console.log("Total weather alerts:", totalWeatherAlerts);

    const totalTrips = await Trip.countDocuments();
    console.log("Total trips:", totalTrips);

    const statistics = {
      totalUsers,
      totalHotels,
      totalVehicles,
      totalPlaces,
      activeGuides,
      totalWeatherAlerts,
      totalTrips,
    };

    console.log("Sending statistics response:", statistics);

    res.json({
      success: true,
      statistics,
    });
  } catch (error) {
    console.error("Error fetching dashboard statistics:", error);
    res.status(500).json({
      success: false,
      message: "Error fetching dashboard statistics",
      error: error.message,
    });
  }
};

module.exports = { getDashboardStatistics };
