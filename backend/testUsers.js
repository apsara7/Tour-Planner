const mongoose = require("mongoose");
require("dotenv").config();

// Import models
const User = require("./models/userModel");
const Trip = require("./models/trip");

const URL = process.env.MONGODB_URL;

const testUsersWithTrips = async () => {
  try {
    console.log("Connecting to MongoDB...");
    await mongoose.connect(URL, { useNewUrlParser: true, useUnifiedTopology: true });
    console.log("✅ MongoDB Connected");

    console.log("Fetching all users...");
    const users = await User.find({}, "-password").sort({ createdAt: -1 });
    console.log(`Found ${users.length} users`);
    
    console.log("Fetching trips for each user...");
    const usersWithTrips = await Promise.all(
      users.map(async (user) => {
        const trips = await Trip.find({ userId: user._id, isActive: true })
          .populate("places.placeId", "name")
          .populate("guides.guideId", "guideName")
          .populate("hotels.hotelId", "hotelName")
          .populate("vehicles.vehicleId", "type")
          .sort({ createdAt: -1 });
        
        console.log(`User ${user.username} has ${trips.length} trips`);
        
        return {
          ...user.toObject(),
          trips
        };
      })
    );
    
    console.log("Users with trips:", JSON.stringify(usersWithTrips, null, 2));
    
    await mongoose.connection.close();
    console.log("Disconnected from MongoDB");
  } catch (error) {
    console.error("Error:", error);
  }
};

testUsersWithTrips();