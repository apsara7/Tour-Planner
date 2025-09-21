import React, { useEffect, useState } from "react";
import axios from "axios";
import { useNavigate } from "react-router-dom";

export default function ManageGuides() {
  const [guides, setGuides] = useState([]);
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("");
  const [ratingFilter, setRatingFilter] = useState("");
  const [provinceFilter, setProvinceFilter] = useState("");
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    fetchGuides();
  }, []);

  const fetchGuides = async () => {
    try {
      setLoading(true);
      const params = new URLSearchParams();

      if (search) params.append("search", search);
      if (statusFilter) params.append("status", statusFilter);
      if (ratingFilter) {
        const [min, max] = ratingFilter.split("-");
        if (min) params.append("minRating", min);
        if (max) params.append("maxRating", max);
      }
      if (provinceFilter) params.append("province", provinceFilter);

      const res = await axios.get(
        `${process.env.REACT_APP_BASE_URL}/api/viewGuides?${params.toString()}`
      );
      setGuides(res.data);
    } catch (error) {
      console.error("Error fetching guides:", error);
      alert("Failed to load guides");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    const timeoutId = setTimeout(() => {
      fetchGuides();
    }, 500); // Debounce search

    return () => clearTimeout(timeoutId);
  }, [search, statusFilter, ratingFilter, provinceFilter]);

  const handleDelete = async (id) => {
    if (!window.confirm("Are you sure to delete this guide?")) return;
    try {
      await axios.delete(
        `${process.env.REACT_APP_BASE_URL}/api/deleteGuide/${id}`
      );
      fetchGuides();
    } catch (error) {
      console.error("Error deleting guide:", error);
      alert("Failed to delete guide");
    }
  };

  const handleStatusChange = async (guideId, newStatus) => {
    try {
      await axios.put(
        `${process.env.REACT_APP_BASE_URL}/api/updateGuideStatus`,
        {
          guideId,
          status: newStatus,
        }
      );
      fetchGuides();
    } catch (error) {
      console.error("Error updating status:", error);
      alert("Failed to update guide status");
    }
  };

  const getStatusBadge = (status) => {
    const statusClasses = {
      active: "bg-green-100 text-green-800",
      inactive: "bg-gray-100 text-gray-800",
      suspended: "bg-red-100 text-red-800",
      pending_verification: "bg-yellow-100 text-yellow-800",
    };

    return (
      <span
        className={`px-2 py-1 rounded-full text-xs font-medium ${
          statusClasses[status] || "bg-gray-100 text-gray-800"
        }`}
      >
        {status.replace("_", " ").toUpperCase()}
      </span>
    );
  };

  const renderStars = (rating) => {
    const stars = [];
    const fullStars = Math.floor(rating);
    const hasHalfStar = rating % 1 !== 0;

    for (let i = 0; i < fullStars; i++) {
      stars.push(
        <span key={i} className="text-yellow-400">
          ★
        </span>
      );
    }

    if (hasHalfStar) {
      stars.push(
        <span key="half" className="text-yellow-400">
          ☆
        </span>
      );
    }

    const emptyStars = 5 - Math.ceil(rating);
    for (let i = 0; i < emptyStars; i++) {
      stars.push(
        <span key={`empty-${i}`} className="text-gray-300">
          ★
        </span>
      );
    }

    return stars;
  };

  if (loading) {
    return (
      <div className="p-6">
        <div className="text-center">Loading guides...</div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-2xl font-bold text-gray-800">Manage Guides</h2>
        <button
          onClick={() => navigate("/guides/create")}
          className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition"
        >
          + Add New Guide
        </button>
      </div>

      {/* Search and Filter Section */}
      <div className="bg-white p-4 rounded-lg shadow mb-6">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4">
          {/* Search */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Search
            </label>
            <input
              type="text"
              placeholder="Search guides..."
              className="border rounded p-2 w-full"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>

          {/* Status Filter */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Status
            </label>
            <select
              className="border rounded p-2 w-full"
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
            >
              <option value="">All Status</option>
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
              <option value="suspended">Suspended</option>
              <option value="pending_verification">Pending Verification</option>
            </select>
          </div>

          {/* Rating Filter */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Rating
            </label>
            <select
              className="border rounded p-2 w-full"
              value={ratingFilter}
              onChange={(e) => setRatingFilter(e.target.value)}
            >
              <option value="">All Ratings</option>
              <option value="4-5">4+ Stars</option>
              <option value="3-4">3-4 Stars</option>
              <option value="2-3">2-3 Stars</option>
              <option value="1-2">1-2 Stars</option>
            </select>
          </div>

          {/* Province Filter */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Province
            </label>
            <select
              className="border rounded p-2 w-full"
              value={provinceFilter}
              onChange={(e) => setProvinceFilter(e.target.value)}
            >
              <option value="">All Provinces</option>
              <option value="Western">Western</option>
              <option value="Central">Central</option>
              <option value="Southern">Southern</option>
              <option value="Northern">Northern</option>
              <option value="Eastern">Eastern</option>
              <option value="North Western">North Western</option>
              <option value="North Central">North Central</option>
              <option value="Uva">Uva</option>
              <option value="Sabaragamuwa">Sabaragamuwa</option>
            </select>
          </div>

          {/* Clear Filters */}
          <div className="flex items-end">
            <button
              onClick={() => {
                setSearch("");
                setStatusFilter("");
                setRatingFilter("");
                setProvinceFilter("");
              }}
              className="bg-gray-500 text-white px-4 py-2 rounded hover:bg-gray-600 transition w-full"
            >
              Clear Filters
            </button>
          </div>
        </div>
      </div>

      {/* Results Count */}
      <div className="mb-4">
        <p className="text-gray-600">
          Showing {guides.length} guide{guides.length !== 1 ? "s" : ""}
        </p>
      </div>

      {/* Guides Table */}
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Guide
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Contact
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Location
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Experience
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Rating
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {guides.map((guide) => (
                <tr key={guide._id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="flex-shrink-0 h-10 w-10">
                        {guide.images && guide.images.length > 0 ? (
                          <img
                            className="h-10 w-10 rounded-full object-cover"
                            src={guide.images[0]}
                            alt={guide.guideName}
                          />
                        ) : (
                          <div className="h-10 w-10 rounded-full bg-gray-300 flex items-center justify-center">
                            <span className="text-gray-600 text-sm font-medium">
                              {guide.guideName.charAt(0).toUpperCase()}
                            </span>
                          </div>
                        )}
                      </div>
                      <div className="ml-4">
                        <div className="text-sm font-medium text-gray-900">
                          {guide.guideName}
                        </div>
                        <div className="text-sm text-gray-500">
                          {guide.license?.licenseType || "N/A"}
                        </div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">
                      {guide.contactDetails?.phone}
                    </div>
                    <div className="text-sm text-gray-500">
                      {guide.contactDetails?.email}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">
                      {guide.address?.city}
                    </div>
                    <div className="text-sm text-gray-500">
                      {guide.address?.province}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">
                      {guide.experience?.yearsOfExperience || 0} years
                    </div>
                    <div className="text-sm text-gray-500">
                      {guide.experience?.languages?.slice(0, 2).join(", ") ||
                        "N/A"}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="flex">
                        {renderStars(guide.ratings?.averageRating || 0)}
                      </div>
                      <div className="ml-2 text-sm text-gray-500">
                        ({guide.ratings?.totalRatings || 0})
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    {getStatusBadge(guide.status)}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <div className="flex space-x-2">
                      <button
                        onClick={() => navigate(`/guides/edit/${guide._id}`)}
                        className="text-blue-600 hover:text-blue-900"
                      >
                        Edit
                      </button>
                      <select
                        value={guide.status}
                        onChange={(e) =>
                          handleStatusChange(guide._id, e.target.value)
                        }
                        className="text-xs border rounded px-1 py-1"
                      >
                        <option value="active">Active</option>
                        <option value="inactive">Inactive</option>
                        <option value="suspended">Suspended</option>
                        <option value="pending_verification">Pending</option>
                      </select>
                      <button
                        onClick={() => handleDelete(guide._id)}
                        className="text-red-600 hover:text-red-900"
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

        {guides.length === 0 && (
          <div className="text-center py-8 text-gray-500">
            No guides found matching your criteria.
          </div>
        )}
      </div>
    </div>
  );
}
