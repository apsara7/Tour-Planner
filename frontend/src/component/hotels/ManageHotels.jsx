import React, { useEffect, useState } from "react";
import axios from "axios";
import { useNavigate } from "react-router-dom";

export default function ManageHotels() {
  const [hotels, setHotels] = useState([]);
  const [search, setSearch] = useState("");
  const navigate = useNavigate();

  useEffect(() => {
    fetchHotels();
  }, []);

  const fetchHotels = async () => {
    try {
      const res = await axios.get(
        `${process.env.REACT_APP_BASE_URL}/api/viewHotels`
      );
      setHotels(res.data);
    } catch (err) {
      console.error("Error fetching hotels:", err);
      alert("Failed to fetch hotels");
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm("Are you sure to delete this hotel?")) return;
    try {
      await axios.delete(
        `${process.env.REACT_APP_BASE_URL}/api/deleteHotel/${id}`
      );
      alert("Hotel deleted successfully");
      fetchHotels();
    } catch (err) {
      console.error("Error deleting hotel:", err);
      alert("Failed to delete hotel");
    }
  };

  const handleStatusChange = async (hotelId, packageId, newStatus) => {
    try {
      await axios.put(
        `${process.env.REACT_APP_BASE_URL}/api/updateRoomPackageStatus`,
        { hotelId, packageId, status: newStatus }
      );
      alert("Room package status updated successfully");
      fetchHotels();
    } catch (err) {
      console.error("Error updating status:", err);
      alert("Failed to update room package status");
    }
  };

  const filteredHotels = hotels.filter(
    (hotel) =>
      hotel.hotelName.toLowerCase().includes(search.toLowerCase()) ||
      hotel.address?.city?.toLowerCase().includes(search.toLowerCase()) ||
      hotel.contactDetails?.email?.toLowerCase().includes(search.toLowerCase())
  );

  const getStatusColor = (status) => {
    switch (status) {
      case "active":
        return "bg-green-100 text-green-800";
      case "booked":
        return "bg-red-100 text-red-800";
      case "maintenance":
        return "bg-yellow-100 text-yellow-800";
      case "inactive":
        return "bg-gray-100 text-gray-800";
      default:
        return "bg-gray-100 text-gray-800";
    }
  };

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-xl font-bold">Manage Hotels</h2>
        <button
          onClick={() => navigate("/hotels/create")}
          className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
        >
          + Create Hotel
        </button>
      </div>

      <input
        type="text"
        placeholder="Search hotels by name, city, or email..."
        className="border p-2 rounded w-full mb-4"
        value={search}
        onChange={(e) => setSearch(e.target.value)}
      />

      <div className="overflow-x-auto">
        <table className="w-full border rounded">
          <thead className="bg-gray-100">
            <tr>
              <th className="p-2 border text-left">Hotel Name</th>
              <th className="p-2 border text-left">Contact</th>
              <th className="p-2 border text-left">Address</th>
              <th className="p-2 border text-left">Rating</th>
              <th className="p-2 border text-left">Room Packages</th>
              <th className="p-2 border text-left">Actions</th>
            </tr>
          </thead>
          <tbody>
            {filteredHotels.map((hotel) => (
              <tr key={hotel._id} className="hover:bg-gray-50">
                <td className="border p-2">
                  <div className="font-semibold">{hotel.hotelName}</div>
                  <div className="text-sm text-gray-600">
                    {hotel.isActive ? (
                      <span className="text-green-600">Active</span>
                    ) : (
                      <span className="text-red-600">Inactive</span>
                    )}
                  </div>
                </td>
                <td className="border p-2">
                  <div className="text-sm">
                    <div>{hotel.contactDetails?.phone}</div>
                    <div className="text-gray-600">
                      {hotel.contactDetails?.email}
                    </div>
                  </div>
                </td>
                <td className="border p-2">
                  <div className="text-sm">
                    <div>{hotel.address?.street}</div>
                    <div className="text-gray-600">
                      {hotel.address?.city}, {hotel.address?.province}
                    </div>
                  </div>
                </td>
                <td className="border p-2">
                  <div className="flex items-center">
                    <span className="text-yellow-500">★</span>
                    <span className="ml-1">{hotel.rating || "N/A"}</span>
                  </div>
                </td>
                <td className="border p-2">
                  <div className="space-y-1">
                    {hotel.roomPackages?.slice(0, 2).map((pkg, index) => (
                      <div key={index} className="text-sm">
                        <div className="font-medium">{pkg.packageName}</div>

                        {/* Package Images */}
                        {pkg.images && pkg.images.length > 0 && (
                          <div className="flex gap-1 mt-1 mb-1">
                            {pkg.images
                              .slice(0, 3)
                              .map((imageUrl, imgIndex) => (
                                <img
                                  key={imgIndex}
                                  src={imageUrl}
                                  alt={`${pkg.packageName} ${imgIndex + 1}`}
                                  className="w-8 h-8 object-cover rounded border"
                                />
                              ))}
                            {pkg.images.length > 3 && (
                              <div className="w-8 h-8 bg-gray-200 rounded border flex items-center justify-center text-xs text-gray-600">
                                +{pkg.images.length - 3}
                              </div>
                            )}
                          </div>
                        )}

                        <div className="flex items-center space-x-2">
                          <span
                            className={`px-2 py-1 rounded-full text-xs ${getStatusColor(
                              pkg.status
                            )}`}
                          >
                            {pkg.status}
                          </span>
                          <select
                            value={pkg.status}
                            onChange={(e) =>
                              handleStatusChange(
                                hotel._id,
                                pkg._id,
                                e.target.value
                              )
                            }
                            className="text-xs border rounded px-1 py-0.5"
                          >
                            <option value="active">Active</option>
                            <option value="booked">Booked</option>
                            <option value="maintenance">Maintenance</option>
                            <option value="inactive">Inactive</option>
                          </select>
                        </div>
                      </div>
                    ))}
                    {hotel.roomPackages?.length > 2 && (
                      <div className="text-xs text-gray-500">
                        +{hotel.roomPackages.length - 2} more packages
                      </div>
                    )}
                  </div>
                </td>
                <td className="border p-2">
                  <div className="flex space-x-2">
                    <button
                      onClick={() => navigate(`/hotels/edit/${hotel._id}`)}
                      className="bg-yellow-500 text-white px-3 py-1 rounded text-sm hover:bg-yellow-600"
                    >
                      Edit
                    </button>

                    <button
                      onClick={() => handleDelete(hotel._id)}
                      className="bg-red-600 text-white px-3 py-1 rounded text-sm hover:bg-red-700"
                    >
                      Delete
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {filteredHotels.length === 0 && (
        <div className="text-center py-8 text-gray-500">
          No hotels found. Create your first hotel to get started.
        </div>
      )}
    </div>
  );
}
