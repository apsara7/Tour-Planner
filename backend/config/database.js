const mongoose = require("mongoose");
require("dotenv").config();
const URL = process.env.MONGODB_URL;

const connectDB = async () => {
  try {
    await mongoose.connect(URL, { useNewUrlParser: true, useUnifiedTopology: true });
    console.log("✅ MongoDB Connected");
  } catch (err) {
    console.error("❌ MongoDB Not Connected: " + err.message);
    setTimeout(connectDB, 5000);
  }
};

mongoose.connection.on("connected", () => console.log("MongoDB connection established."));
mongoose.connection.on("error", (err) => console.error("MongoDB error:", err.message));
mongoose.connection.on("disconnected", () => {
  console.error("MongoDB disconnected. Retrying...");
  connectDB();
});

process.on("SIGINT", async () => {
  await mongoose.connection.close();
  console.log("MongoDB connection closed. App terminating.");
  process.exit(0);
});

module.exports = connectDB;
