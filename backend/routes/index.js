const express = require("express");
const router = express.Router();
const multer = require("multer");
const path = require("path");

const {
  loginUser,
  getDashboardData,
} = require("../controllers/loginController");
const {
  initialRunning,
  getInitialData,
} = require("../controllers/initialSetup");
const {
  registerUser,
  checkUsernameAvailability,
  checkPhoneAvailability,
  checkEmailAvailability,
  loginAppUser,
  getUserProfile,
  updateUserProfile,
} = require("../controllers/userRegistrationController");

const {
  createPlace,
  getAllPlaces,
  getPlaceById,
  updatePlace,
  deletePlace,
} = require("../controllers/placesController");
const {
  createHotel,
  getAllHotels,
  getHotelById,
  updateHotel,
  deleteHotel,
  updateRoomPackageStatus,
} = require("../controllers/hotelsController");
const {
  createGuide,
  getAllGuides,
  getGuideById,
  updateGuide,
  deleteGuide,
  addTouristRating,
  updateGuideStatus,
  getGuideStatistics,
} = require("../controllers/guidesController");
const {
  createVehicle,
  getAllVehicles,
  getVehicleById,
  updateVehicle,
  deleteVehicle,
} = require("../controllers/vehiclesController");
const {
  createAlert,
  getAlertById,
  getAllAlerts,
  updateAlert,
  deleteAlert,
} = require("../controllers/weatherController");
const {
  createOption,
  getAllOptions,
  getOptionById,
  updateOption,
  deleteOption,
} = require("../controllers/securityController");
const {
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
  confirmTrip,
} = require("../controllers/tripsController");

const {
  getAllUsersWithTrips,
  getUserWithTrips,
  deleteUser,
} = require("../controllers/usersController");

const { authenticateToken } = require("../middleware/authMiddleware");
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, "uploads"),
  filename: (req, file, cb) =>
    cb(null, Date.now() + path.extname(file.originalname)),
});
const upload = multer({ storage });
const uploadAny = multer({
  storage,
  fileFilter: (req, file, cb) => {
    // Accept any field name for hotel routes
    cb(null, true);
  },
});

//app routers
// User Registration
router.post("/register", registerUser);
router.get("/check-username/:username", checkUsernameAvailability);
router.get("/check-phone/:phone", checkPhoneAvailability);
router.get("/check-email/:email", checkEmailAvailability);

//app login
router.post("/login_user", loginAppUser);

// User profile routes
router.get("/user/profile", authenticateToken, getUserProfile);
router.put("/user/profile", authenticateToken, updateUserProfile);
router.put(
  "/user/profile/picture",
  authenticateToken,
  upload.single("profileImage"),
  updateUserProfile
);

//admin routers
// router.post("/login", loginUser);
router.post("/initial-setup", initialRunning);
router.get("/initial-data", authenticateToken, getInitialData);

//login
router.post("/login", loginUser);
router.get("/dashboard", authenticateToken, getDashboardData);

//places
router.post("/createPlaces", upload.array("images"), createPlace);
router.get("/viewPlaces", getAllPlaces);
router.get("/viewPlaceByID/:id", getPlaceById);
router.put("/editPlace/:id", upload.array("images"), updatePlace);
router.delete("/deletePlace/:id", deletePlace);

//hotels
router.post("/createHotels", uploadAny.any(), createHotel);
router.get("/viewHotels", getAllHotels);
router.get("/viewHotelByID/:id", getHotelById);
router.put("/editHotel/:id", uploadAny.any(), updateHotel);
router.delete("/deleteHotel/:id", deleteHotel);
router.put("/updateRoomPackageStatus", updateRoomPackageStatus);

//guides
router.post("/createGuides", uploadAny.any(), createGuide);
router.get("/viewGuides", getAllGuides);
router.get("/viewGuideByID/:id", getGuideById);
router.put("/editGuide/:id", uploadAny.any(), updateGuide);
router.delete("/deleteGuide/:id", deleteGuide);
router.post("/addTouristRating", addTouristRating);
router.put("/updateGuideStatus", updateGuideStatus);
router.get("/guideStatistics", getGuideStatistics);

//vehicles
router.post("/vehicles", upload.array("images"), createVehicle);
router.get("/vehicles", getAllVehicles);
router.get("/vehicles/:id", getVehicleById);
router.put("/vehicles/:id", upload.array("images"), updateVehicle);
router.delete("/vehicles/:id", deleteVehicle);

// weather alerts
router.post("/weather-alerts", createAlert);
router.get("/weather-alerts", getAllAlerts);
router.get("/weather-alerts/:id", getAlertById);
router.put("/weather-alerts/:id", updateAlert);
router.delete("/weather-alerts/:id", deleteAlert);

// security options
router.post("/security-options", createOption);
router.get("/security-options", getAllOptions);
router.get("/security-options/:id", getOptionById);
router.put("/security-options/:id", updateOption);
router.delete("/security-options/:id", deleteOption);

// trips
router.post("/trips", createTrip);
router.get("/user/:userId/trips", getUserTrips);
router.get("/trips/:id", getTripById);
router.post("/trips/add-place", addPlaceToTrip);
router.post("/trips/remove-place", removePlaceFromTrip);
router.post("/trips/add-guide", addGuideToTrip);
router.post("/trips/remove-guide", removeGuideFromTrip);
router.put("/trips/update-guide", updateGuideInTrip);
router.post("/trips/add-hotel", addHotelToTrip);
router.post("/trips/remove-hotel", removeHotelFromTrip);
router.put("/trips/update-hotel", updateHotelInTrip);
router.post("/trips/add-vehicle", addVehicleToTrip);
router.post("/trips/remove-vehicle", removeVehicleFromTrip);
router.put("/trips/update-vehicle", updateVehicleInTrip);
router.post("/trips/confirm", confirmTrip);
router.put("/trips/:id", updateTrip);
router.delete("/trips/:id", deleteTrip);
router.get("/user/:userId/default-trip", getOrCreateDefaultTrip);

// users data
router.get("/usersData", authenticateToken, getAllUsersWithTrips);
router.get("/usersData/:userId", authenticateToken, getUserWithTrips);
router.delete("/usersData/:userId", authenticateToken, deleteUser);

module.exports = router;
