const mongoose = require("mongoose");
require("dotenv").config();

// Import models
const User = require("./models/userModel");
const Hotel = require("./models/hotels");
const Vehicle = require("./models/vehicle");
const Place = require("./models/places");
const Guide = require("./models/guides");
const WeatherAlert = require("./models/weatherAlert");
const Trip = require("./models/trip");

const URL = process.env.MONGODB_URL;

const testDashboardStats = async () => {
  try {
    console.log("Connecting to MongoDB...");
    await mongoose.connect(URL, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log("✅ MongoDB Connected");

    console.log("Fetching dashboard statistics...");

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

    console.log("Statistics:", statistics);

    await mongoose.connection.close();
    console.log("Disconnected from MongoDB");
  } catch (error) {
    console.error("Error:", error);
  }
};

testDashboardStats();
