import React, { useEffect, useState } from "react";
import axios from "axios";
import { useNavigate } from "react-router-dom";

export default function ManageVehicles() {
  const [vehicles, setVehicles] = useState([]);
  const [search, setSearch] = useState("");
  const [filterType, setFilterType] = useState("");
  const [filterStatus, setFilterStatus] = useState("");
  const navigate = useNavigate();

  useEffect(() => {
    fetchVehicles();
    // eslint-disable-next-line
  }, [filterType, filterStatus]);

  const fetchVehicles = async () => {
    try {
      const params = {};
      if (filterType) params.type = filterType;
      if (filterStatus) params.status = filterStatus;

      const res = await axios.get(
        `${process.env.REACT_APP_BASE_URL}/api/vehicles`,
        { params }
      );
      setVehicles(res.data);
    } catch (err) {
      console.error("Error fetching vehicles:", err);
      alert("Failed to load vehicles");
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm("Are you sure you want to delete this vehicle?"))
      return;
    try {
      await axios.delete(
        `${process.env.REACT_APP_BASE_URL}/api/vehicles/${id}`
      );
      fetchVehicles();
      alert("Vehicle deleted successfully");
    } catch (err) {
      console.error("Error deleting vehicle:", err);
      alert("Failed to delete vehicle");
    }
  };

  const filteredVehicles = vehicles.filter(
    (v) =>
      v.type.toLowerCase().includes(search.toLowerCase()) ||
      (v.owner?.name || "").toLowerCase().includes(search.toLowerCase())
  );

  const statusColors = {
    available: "bg-green-100 text-green-800",
    rented: "bg-blue-100 text-blue-800",
    maintenance: "bg-yellow-100 text-yellow-800",
  };

  return (
    <div className="p-6 max-w-7xl mx-auto">
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-2xl font-bold text-gray-800">Manage Vehicles</h2>
        <button
          onClick={() => navigate("/vehicles/create")}
          className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg shadow transition"
        >
          + Add Vehicle
        </button>
      </div>

      {/* Filters and Search */}
      <div className="bg-white p-4 rounded-lg shadow mb-6">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-4">
          <div>
            <label className="block text-sm font-medium mb-1">Search</label>
            <input
              type="text"
              placeholder="Search by type or owner..."
              className="w-full border rounded p-2"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">
              Vehicle Type
            </label>
            <input
              type="text"
              placeholder="e.g. Car, Van"
              className="w-full border rounded p-2"
              value={filterType}
              onChange={(e) => setFilterType(e.target.value)}
            />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">Status</label>
            <select
              className="w-full border rounded p-2"
              value={filterStatus}
              onChange={(e) => setFilterStatus(e.target.value)}
            >
              <option value="">All</option>
              <option value="available">Available</option>
              <option value="rented">Rented</option>
              <option value="maintenance">Maintenance</option>
            </select>
          </div>
          <div className="flex items-end">
            <button
              className="bg-gray-200 px-4 py-2 rounded"
              onClick={() => {
                setSearch("");
                setFilterType("");
                setFilterStatus("");
                fetchVehicles();
              }}
            >
              Reset
            </button>
          </div>
        </div>
      </div>

      {/* Vehicles Table */}
      <div className="bg-white rounded-lg shadow">
        <table className="min-w-full divide-y divide-gray-200">
          <thead>
            <tr>
              <th className="px-4 py-2 text-left text-xs font-medium text-gray-500">
                Type
              </th>
              <th className="px-4 py-2 text-left text-xs font-medium text-gray-500">
                Passengers
              </th>
              <th className="px-4 py-2 text-left text-xs font-medium text-gray-500">
                Owner
              </th>
              <th className="px-4 py-2 text-left text-xs font-medium text-gray-500">
                Status
              </th>
              <th className="px-4 py-2 text-left text-xs font-medium text-gray-500">
                Actions
              </th>
            </tr>
          </thead>
          <tbody>
            {filteredVehicles.length === 0 ? (
              <tr>
                <td colSpan={5} className="text-center py-6 text-gray-400">
                  No vehicles found.
                </td>
              </tr>
            ) : (
              filteredVehicles.map((v) => (
                <tr key={v._id} className="hover:bg-gray-50">
                  <td className="px-4 py-2">{v.type}</td>
                  <td className="px-4 py-2">{v.passengerAmount}</td>
                  <td className="px-4 py-2">{v.owner?.name || "-"}</td>
                  <td className="px-4 py-2">
                    <span
                      className={`px-2 py-1 rounded text-xs font-semibold ${
                        statusColors[v.status] || "bg-gray-100 text-gray-800"
                      }`}
                    >
                      {v.status}
                    </span>
                  </td>
                  <td className="px-4 py-2 space-x-2">
                    <button
                      className="bg-yellow-500 hover:bg-yellow-600 text-white px-2 py-1 rounded text-xs"
                      onClick={() => navigate(`/vehicles/edit/${v._id}`)}
                    >
                      Edit
                    </button>
                    <button
                      className="bg-red-500 hover:bg-red-600 text-white px-2 py-1 rounded text-xs"
                      onClick={() => handleDelete(v._id)}
                    >
                      Delete
                    </button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
