import React, { useEffect, useState } from "react";
import axios from "axios";
import { useNavigate } from "react-router-dom";

export default function ManageWeatherAlerts() {
  const [alerts, setAlerts] = useState([]);
  const [search, setSearch] = useState("");
  const navigate = useNavigate();

  useEffect(() => {
    fetchAlerts();
  }, []);

  const fetchAlerts = async () => {
    try {
      const res = await axios.get(`${process.env.REACT_APP_BASE_URL}/api/weather-alerts`);
      setAlerts(res.data);
    } catch (err) {
      console.error(err);
      alert("Failed to load weather alerts");
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm("Are you sure to delete this alert?")) return;
    try {
      await axios.delete(`${process.env.REACT_APP_BASE_URL}/api/weather-alerts/${id}`);
      fetchAlerts();
    } catch (err) {
      console.error(err);
      alert("Delete failed");
    }
  };

  const filtered = alerts.filter((a) =>
    a.message?.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-xl font-bold">Manage Weather Alerts</h2>
        <button
          onClick={() => navigate("/weather-alerts/create")}
          className="bg-blue-600 text-white px-4 py-2 rounded"
        >
          + Create Alert
        </button>
      </div>

      <input
        type="text"
        placeholder="Search alerts..."
        className="border p-2 rounded w-full mb-4"
        value={search}
        onChange={(e) => setSearch(e.target.value)}
      />

      <table className="w-full border rounded">
        <thead className="bg-gray-100">
          <tr>
            <th className="p-2 border">Region</th>
            <th className="p-2 border">Severity</th>
            <th className="p-2 border">Message</th>
            <th className="p-2 border">Issued At</th>
            <th className="p-2 border">Actions</th>
          </tr>
        </thead>
        <tbody>
          {filtered.map((alert) => (
            <tr key={alert._id} className="text-center">
              <td className="border p-2">{alert.region}</td>
              <td className="border p-2">{alert.severity}</td>
              <td className="border p-2">{alert.message}</td>
              <td className="border p-2">
                {alert.issuedAt ? new Date(alert.issuedAt).toLocaleString() : ""}
              </td>
              <td className="border p-2 space-x-2">
                <button
                  onClick={() => navigate(`/weather-alerts/edit/${alert._id}`)}
                  className="bg-yellow-500 text-white px-3 py-1 rounded"
                >
                  Edit
                </button>
                <button
                  onClick={() => handleDelete(alert._id)}
                  className="bg-red-600 text-white px-3 py-1 rounded"
                >
                  Delete
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
