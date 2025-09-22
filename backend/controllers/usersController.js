const User = require("../models/userModel");
const Trip = require("../models/trip");

// Get all users with their trips
const getAllUsersWithTrips = async (req, res) => {
  try {
    // Get all users
    const users = await User.find({})
      .select("-password")
      .sort({ createdAt: -1 });

    // Populate trips for each user
    const usersWithTrips = await Promise.all(
      users.map(async (user) => {
        const trips = await Trip.find({ userId: user._id }).select(
          "name description status startDate endDate travellersCount estimatedBudget places guides hotels vehicles createdAt updatedAt"
        );
        return {
          ...user.toObject(),
          trips,
        };
      })
    );

    res.status(200).json({
      success: true,
      message: "Users retrieved successfully",
      users: usersWithTrips,
    });
  } catch (error) {
    console.error("Error fetching users with trips:", error);
    res.status(500).json({
      success: false,
      message: "Error fetching users data",
      error: error.message,
    });
  }
};

// Get a specific user with their trips
const getUserWithTrips = async (req, res) => {
  try {
    const { userId } = req.params;

    // Get user by ID
    const user = await User.findById(userId).select("-password");

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    // Get user's trips
    const trips = await Trip.find({ userId: user._id }).select(
      "name description status startDate endDate travellersCount estimatedBudget places guides hotels vehicles createdAt updatedAt"
    );

    res.status(200).json({
      success: true,
      message: "User retrieved successfully",
      user: {
        ...user.toObject(),
        trips,
      },
    });
  } catch (error) {
    console.error("Error fetching user with trips:", error);
    res.status(500).json({
      success: false,
      message: "Error fetching user data",
      error: error.message,
    });
  }
};

// Delete a user (soft delete by setting isActive to false)
const deleteUser = async (req, res) => {
  try {
    const { userId } = req.params;

    // Find user by ID
    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    // Soft delete user by setting isActive to false
    user.isActive = false;
    await user.save();

    // Also soft delete user's trips
    await Trip.updateMany({ userId: user._id }, { isActive: false });

    res.status(200).json({
      success: true,
      message: "User deleted successfully",
    });
  } catch (error) {
    console.error("Error deleting user:", error);
    res.status(500).json({
      success: false,
      message: "Error deleting user",
      error: error.message,
    });
  }
};

module.exports = {
  getAllUsersWithTrips,
  getUserWithTrips,
  deleteUser,
};
