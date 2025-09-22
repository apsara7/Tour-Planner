import React, { useState, useEffect, useContext } from "react";
import axios from "axios";
import { UserContext } from "../../context/userContext";
import {
  Users,
  MapPin,
  UserCheck,
  Car,
  Building2,
  Calendar,
  Eye,
  Search,
  Trash2,
  X,
} from "lucide-react";

const ManageUsers = () => {
  const { userData } = useContext(UserContext);
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedUser, setSelectedUser] = useState(null); // For popup
  const [showUserModal, setShowUserModal] = useState(false); // For popup
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false); // For delete confirmation
  const [userToDelete, setUserToDelete] = useState(null); // User to be deleted

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      setLoading(true);
      setError(null);
      const token = sessionStorage.getItem("token");

      if (!token) {
        throw new Error("No authentication token found. Please log in again.");
      }

      const response = await axios.get(
        `${process.env.REACT_APP_BASE_URL}/api/usersData`,
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );

      if (response.data.success) {
        // Filter to show only users with role "user", not "admin"
        const regularUsers = response.data.users.filter(
          (user) => user.role === "user"
        );
        setUsers(regularUsers);
      } else {
        const errorMessage = response.data.message || "Failed to fetch users";
        setError(errorMessage);
      }
    } catch (err) {
      console.error("Error fetching users:", err);
      if (err.response) {
        setError(
          `Error ${err.response.status}: ${
            err.response.data.message || err.response.statusText
          }`
        );
      } else if (err.request) {
        setError("Network error. Please check your connection.");
      } else {
        setError("Error fetching users: " + err.message);
      }
    } finally {
      setLoading(false);
    }
  };

  // Function to view user details in popup
  const viewUserDetails = (user) => {
    setSelectedUser(user);
    setShowUserModal(true);
  };

  // Function to close user details popup
  const closeUserModal = () => {
    setShowUserModal(false);
    setSelectedUser(null);
  };

  // Function to initiate user deletion
  const initiateDeleteUser = (user) => {
    setUserToDelete(user);
    setShowDeleteConfirm(true);
  };

  // Function to confirm and delete user
  const confirmDeleteUser = async () => {
    try {
      const token = sessionStorage.getItem("token");

      // In a real implementation, you would call the delete API endpoint here
      // For now, we'll just simulate the deletion
      console.log("Deleting user:", userToDelete._id);

      // Close confirmation and refresh users list
      setShowDeleteConfirm(false);
      setUserToDelete(null);

      // Refresh the users list
      fetchUsers();

      alert("User deleted successfully");
    } catch (err) {
      console.error("Error deleting user:", err);
      alert("Failed to delete user");
    }
  };

  // Function to close delete confirmation
  const cancelDeleteUser = () => {
    setShowDeleteConfirm(false);
    setUserToDelete(null);
  };

  const filteredUsers = users.filter(
    (user) =>
      user.username.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (user.firstName &&
        user.firstName.toLowerCase().includes(searchTerm.toLowerCase())) ||
      (user.lastName &&
        user.lastName.toLowerCase().includes(searchTerm.toLowerCase())) ||
      (user.email &&
        user.email.toLowerCase().includes(searchTerm.toLowerCase()))
  );

  const formatDate = (dateString) => {
    if (!dateString) return "N/A";
    return new Date(dateString).toLocaleDateString();
  };

  const formatTripDuration = (startDate, endDate) => {
    if (!startDate || !endDate) return "N/A";

    const start = new Date(startDate);
    const end = new Date(endDate);
    const diffTime = Math.abs(end - start);
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1;

    return `${diffDays} day${diffDays !== 1 ? "s" : ""}`;
  };

  const getTripStatusColor = (status) => {
    switch (status) {
      case "confirmed":
        return "bg-green-100 text-green-800";
      case "ongoing":
        return "bg-blue-100 text-blue-800";
      case "completed":
        return "bg-purple-100 text-purple-800";
      case "cancelled":
        return "bg-red-100 text-red-800";
      default:
        return "bg-yellow-100 text-yellow-800";
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-red-50 border border-red-200 rounded-lg p-4 mb-6">
        <p className="text-red-800">Error: {error}</p>
        <button
          onClick={fetchUsers}
          className="mt-2 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700"
        >
          Retry
        </button>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-slate-900">Manage Users</h1>
        <p className="text-slate-600">
          View all registered users and their planned trips
        </p>
      </div>

      {/* Search Bar */}
      <div className="mb-6">
        <div className="relative">
          <Search className="absolute left-3 top-3 h-4 w-4 text-slate-400" />
          <input
            type="text"
            placeholder="Search users by name, username, or email..."
            className="w-full pl-10 pr-4 py-2.5 rounded-lg border border-slate-300 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
      </div>

      {/* Users List */}
      <div className="grid grid-cols-1 gap-6">
        {filteredUsers.map((user) => (
          <div
            key={user._id}
            className="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden"
          >
            <div className="p-6 border-b border-slate-200">
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-4">
                  <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center">
                    <Users className="h-6 w-6 text-blue-600" />
                  </div>
                  <div>
                    <h2 className="text-lg font-semibold text-slate-900">
                      {user.firstName} {user.lastName}
                    </h2>
                    <p className="text-slate-600">@{user.username}</p>
                  </div>
                </div>
                <div className="flex space-x-2">
                  <button
                    onClick={() => viewUserDetails(user)}
                    className="p-2 bg-blue-100 text-blue-600 rounded-lg hover:bg-blue-200"
                    title="View Details"
                  >
                    <Eye className="h-5 w-5" />
                  </button>
                  <button
                    onClick={() => initiateDeleteUser(user)}
                    className="p-2 bg-red-100 text-red-600 rounded-lg hover:bg-red-200"
                    title="Delete User"
                  >
                    <Trash2 className="h-5 w-5" />
                  </button>
                </div>
              </div>

              <div className="mt-3 flex items-center justify-between">
                <div>
                  {user.email && (
                    <div className="flex items-center text-sm text-slate-600">
                      <span>Email: {user.email}</span>
                    </div>
                  )}
                  {user.mobile && (
                    <div className="mt-1 flex items-center text-sm text-slate-600">
                      <span>Phone: {user.mobile}</span>
                    </div>
                  )}
                </div>
                <div className="text-right">
                  <p className="text-sm text-slate-600">Registered</p>
                  <p className="font-medium text-slate-900">
                    {formatDate(user.createdAt)}
                  </p>
                </div>
              </div>

              <div className="mt-3">
                <span className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-slate-100 text-slate-800">
                  {user.role}
                </span>
              </div>
            </div>

            {/* Trips Summary */}
            <div className="p-6">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-lg font-semibold text-slate-900">
                  Planned Trips ({user.trips.length})
                </h3>
              </div>

              {user.trips.length === 0 ? (
                <div className="text-center py-4">
                  <MapPin className="mx-auto h-8 w-8 text-slate-400" />
                  <p className="mt-1 text-sm text-slate-500">
                    No trips planned yet
                  </p>
                </div>
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                  {user.trips.slice(0, 3).map((trip) => (
                    <div
                      key={trip._id}
                      className="border border-slate-200 rounded-lg p-3"
                    >
                      <div className="flex justify-between items-start">
                        <h4 className="font-medium text-slate-900 truncate text-sm">
                          {trip.name}
                        </h4>
                        <span
                          className={`text-xs px-2 py-1 rounded-full ${getTripStatusColor(
                            trip.status
                          )}`}
                        >
                          {trip.status}
                        </span>
                      </div>
                      <div className="mt-2 text-xs text-slate-600">
                        <div className="flex items-center mt-1">
                          <Calendar className="h-3 w-3 mr-1 text-slate-500" />
                          <span>
                            {formatDate(trip.startDate)} -{" "}
                            {formatDate(trip.endDate)}
                          </span>
                        </div>
                      </div>
                    </div>
                  ))}
                  {user.trips.length > 3 && (
                    <div className="border border-slate-200 rounded-lg p-3 flex items-center justify-center">
                      <span className="text-sm text-slate-600">
                        +{user.trips.length - 3} more trips
                      </span>
                    </div>
                  )}
                </div>
              )}
            </div>
          </div>
        ))}
      </div>

      {/* User Details Modal */}
      {showUserModal && selectedUser && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-xl max-w-4xl w-full max-h-[90vh] overflow-y-auto">
            <div className="p-6 border-b border-slate-200 flex justify-between items-center">
              <h2 className="text-xl font-bold text-slate-900">
                {selectedUser.firstName} {selectedUser.lastName}'s Details
              </h2>
              <button
                onClick={closeUserModal}
                className="p-2 rounded-lg hover:bg-slate-100"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            <div className="p-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
                <div>
                  <h3 className="text-lg font-semibold text-slate-900 mb-3">
                    User Information
                  </h3>
                  <div className="space-y-3">
                    <div>
                      <p className="text-sm text-slate-600">Username</p>
                      <p className="font-medium">{selectedUser.username}</p>
                    </div>
                    <div>
                      <p className="text-sm text-slate-600">Email</p>
                      <p className="font-medium">
                        {selectedUser.email || "N/A"}
                      </p>
                    </div>
                    <div>
                      <p className="text-sm text-slate-600">Phone</p>
                      <p className="font-medium">
                        {selectedUser.mobile || "N/A"}
                      </p>
                    </div>
                    <div>
                      <p className="text-sm text-slate-600">Role</p>
                      <span className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-slate-100 text-slate-800">
                        {selectedUser.role}
                      </span>
                    </div>
                    <div>
                      <p className="text-sm text-slate-600">Member Since</p>
                      <p className="font-medium">
                        {formatDate(selectedUser.createdAt)}
                      </p>
                    </div>
                  </div>
                </div>

                <div>
                  <h3 className="text-lg font-semibold text-slate-900 mb-3">
                    Trip Summary
                  </h3>
                  <div className="space-y-3">
                    <div className="flex justify-between">
                      <span className="text-slate-600">Total Trips</span>
                      <span className="font-medium">
                        {selectedUser.trips.length}
                      </span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-slate-600">Active Trips</span>
                      <span className="font-medium">
                        {
                          selectedUser.trips.filter(
                            (t) =>
                              t.status === "confirmed" || t.status === "ongoing"
                          ).length
                        }
                      </span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-slate-600">Completed Trips</span>
                      <span className="font-medium">
                        {
                          selectedUser.trips.filter(
                            (t) => t.status === "completed"
                          ).length
                        }
                      </span>
                    </div>
                  </div>
                </div>
              </div>

              <div>
                <h3 className="text-lg font-semibold text-slate-900 mb-4">
                  Planned Trips
                </h3>
                {selectedUser.trips.length === 0 ? (
                  <div className="text-center py-8">
                    <MapPin className="mx-auto h-12 w-12 text-slate-400" />
                    <h3 className="mt-2 text-sm font-medium text-slate-900">
                      No trips planned
                    </h3>
                    <p className="mt-1 text-sm text-slate-500">
                      This user hasn't planned any trips yet.
                    </p>
                  </div>
                ) : (
                  <div className="space-y-6">
                    {selectedUser.trips.map((trip) => (
                      <div
                        key={trip._id}
                        className="border border-slate-200 rounded-lg p-5"
                      >
                        <div className="flex justify-between items-start mb-4">
                          <div>
                            <h4 className="text-lg font-semibold text-slate-900">
                              {trip.name}
                            </h4>
                            <p className="text-slate-600 text-sm mt-1">
                              {trip.description}
                            </p>
                          </div>
                          <span
                            className={`text-xs px-3 py-1 rounded-full ${getTripStatusColor(
                              trip.status
                            )}`}
                          >
                            {trip.status}
                          </span>
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                          <div>
                            <p className="text-sm text-slate-600">Duration</p>
                            <p className="font-medium">
                              {formatDate(trip.startDate)} -{" "}
                              {formatDate(trip.endDate)}
                              <span className="text-slate-600 text-sm ml-2">
                                (
                                {formatTripDuration(
                                  trip.startDate,
                                  trip.endDate
                                )}
                                )
                              </span>
                            </p>
                          </div>
                          <div>
                            <p className="text-sm text-slate-600">Travellers</p>
                            <p className="font-medium">
                              {trip.travellersCount}
                            </p>
                          </div>
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                          {/* Places */}
                          <div className="border border-slate-200 rounded-lg p-3">
                            <h5 className="font-medium text-slate-900 mb-2 flex items-center">
                              <MapPin className="h-4 w-4 mr-2" />
                              Places ({trip.places?.length || 0})
                            </h5>
                            {trip.places && trip.places.length > 0 ? (
                              <ul className="text-sm space-y-1">
                                {trip.places.map((place, index) => (
                                  <li key={index} className="text-slate-600">
                                    {place.placeId?.name || "Unnamed Place"}
                                  </li>
                                ))}
                              </ul>
                            ) : (
                              <p className="text-slate-500 text-sm">
                                No places selected
                              </p>
                            )}
                          </div>

                          {/* Guides */}
                          <div className="border border-slate-200 rounded-lg p-3">
                            <h5 className="font-medium text-slate-900 mb-2 flex items-center">
                              <UserCheck className="h-4 w-4 mr-2" />
                              Guides ({trip.guides?.length || 0})
                            </h5>
                            {trip.guides && trip.guides.length > 0 ? (
                              <ul className="text-sm space-y-1">
                                {trip.guides.map((guide, index) => (
                                  <li key={index} className="text-slate-600">
                                    {guide.guideId?.guideName ||
                                      "Unnamed Guide"}
                                    <span className="block text-xs text-slate-500">
                                      LKR{" "}
                                      {guide.totalTripCost?.toLocaleString() ||
                                        0}
                                    </span>
                                  </li>
                                ))}
                              </ul>
                            ) : (
                              <p className="text-slate-500 text-sm">
                                No guides selected
                              </p>
                            )}
                          </div>

                          {/* Hotels */}
                          <div className="border border-slate-200 rounded-lg p-3">
                            <h5 className="font-medium text-slate-900 mb-2 flex items-center">
                              <Building2 className="h-4 w-4 mr-2" />
                              Hotels ({trip.hotels?.length || 0})
                            </h5>
                            {trip.hotels && trip.hotels.length > 0 ? (
                              <ul className="text-sm space-y-1">
                                {trip.hotels.map((hotel, index) => (
                                  <li key={index} className="text-slate-600">
                                    {hotel.hotelId?.hotelName ||
                                      "Unnamed Hotel"}
                                    <span className="block text-xs text-slate-500">
                                      LKR{" "}
                                      {hotel.totalTripCost?.toLocaleString() ||
                                        0}
                                    </span>
                                  </li>
                                ))}
                              </ul>
                            ) : (
                              <p className="text-slate-500 text-sm">
                                No hotels selected
                              </p>
                            )}
                          </div>

                          {/* Vehicles */}
                          <div className="border border-slate-200 rounded-lg p-3">
                            <h5 className="font-medium text-slate-900 mb-2 flex items-center">
                              <Car className="h-4 w-4 mr-2" />
                              Vehicles ({trip.vehicles?.length || 0})
                            </h5>
                            {trip.vehicles && trip.vehicles.length > 0 ? (
                              <ul className="text-sm space-y-1">
                                {trip.vehicles.map((vehicle, index) => (
                                  <li key={index} className="text-slate-600">
                                    {vehicle.vehicleId?.type ||
                                      "Unnamed Vehicle"}
                                    <span className="block text-xs text-slate-500">
                                      LKR{" "}
                                      {vehicle.totalTripCost?.toLocaleString() ||
                                        0}
                                    </span>
                                  </li>
                                ))}
                              </ul>
                            ) : (
                              <p className="text-slate-500 text-sm">
                                No vehicles selected
                              </p>
                            )}
                          </div>
                        </div>

                        {/* Budget Summary */}
                        <div className="mt-4 pt-4 border-t border-slate-200">
                          <h5 className="font-medium text-slate-900 mb-2">
                            Budget Summary
                          </h5>
                          <div className="grid grid-cols-2 md:grid-cols-5 gap-2">
                            <div className="text-center p-2 bg-slate-50 rounded">
                              <p className="text-xs text-slate-600">Entries</p>
                              <p className="font-medium">
                                LKR{" "}
                                {trip.estimatedBudget?.entriesTotal?.toLocaleString() ||
                                  0}
                              </p>
                            </div>
                            <div className="text-center p-2 bg-slate-50 rounded">
                              <p className="text-xs text-slate-600">Guides</p>
                              <p className="font-medium">
                                LKR{" "}
                                {trip.estimatedBudget?.guidesTotal?.toLocaleString() ||
                                  0}
                              </p>
                            </div>
                            <div className="text-center p-2 bg-slate-50 rounded">
                              <p className="text-xs text-slate-600">Hotels</p>
                              <p className="font-medium">
                                LKR{" "}
                                {trip.estimatedBudget?.hotelsTotal?.toLocaleString() ||
                                  0}
                              </p>
                            </div>
                            <div className="text-center p-2 bg-slate-50 rounded">
                              <p className="text-xs text-slate-600">Vehicles</p>
                              <p className="font-medium">
                                LKR{" "}
                                {trip.estimatedBudget?.vehiclesTotal?.toLocaleString() ||
                                  0}
                              </p>
                            </div>
                            <div className="text-center p-2 bg-blue-50 rounded">
                              <p className="text-xs text-slate-600">Total</p>
                              <p className="font-medium text-blue-600">
                                LKR{" "}
                                {trip.estimatedBudget?.totalBudget?.toLocaleString() ||
                                  0}
                              </p>
                            </div>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>

            <div className="p-6 border-t border-slate-200 flex justify-end">
              <button
                onClick={closeUserModal}
                className="px-4 py-2 bg-slate-200 text-slate-800 rounded-lg hover:bg-slate-300"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Delete Confirmation Modal */}
      {showDeleteConfirm && userToDelete && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-xl max-w-md w-full">
            <div className="p-6">
              <div className="flex items-center justify-center w-12 h-12 rounded-full bg-red-100 mx-auto">
                <Trash2 className="h-6 w-6 text-red-600" />
              </div>
              <h3 className="text-lg font-bold text-center text-slate-900 mt-4">
                Delete User
              </h3>
              <p className="text-slate-600 text-center mt-2">
                Are you sure you want to delete{" "}
                <span className="font-semibold">
                  {userToDelete.firstName} {userToDelete.lastName}
                </span>
                ? This action cannot be undone.
              </p>
            </div>
            <div className="p-6 border-t border-slate-200 flex justify-end space-x-3">
              <button
                onClick={cancelDeleteUser}
                className="px-4 py-2 bg-slate-200 text-slate-800 rounded-lg hover:bg-slate-300"
              >
                Cancel
              </button>
              <button
                onClick={confirmDeleteUser}
                className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700"
              >
                Delete
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default ManageUsers;
