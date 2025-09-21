// src/pages/admin/ManageSecurityOptions.jsx
import React, { useEffect, useState } from "react";
import axios from "axios";
import { useNavigate } from "react-router-dom";

export default function ManageSecurityOptions() {
  const [options, setOptions] = useState([]);
  const [search, setSearch] = useState("");
  const navigate = useNavigate();

  useEffect(() => {
    fetchOptions();
  }, []);

  const fetchOptions = async () => {
    try {
      const res = await axios.get(`${process.env.REACT_APP_BASE_URL}/api/security-options`);
      setOptions(res.data);
    } catch (err) {
      console.error(err);
      alert("Failed to load security options");
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm("Are you sure to delete this option?")) return;
    try {
      await axios.delete(`${process.env.REACT_APP_BASE_URL}/api/security-options/${id}`);
      fetchOptions();
    } catch (err) {
      console.error(err);
      alert("Delete failed");
    }
  };

  const filtered = options.filter((o) =>
    o.name?.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-xl font-bold">Manage Security Options</h2>
        <button
          onClick={() => navigate("/security-options/create")}
          className="bg-blue-600 text-white px-4 py-2 rounded"
        >
          + Create Option
        </button>
      </div>

      <input
        type="text"
        placeholder="Search options..."
        className="border p-2 rounded w-full mb-4"
        value={search}
        onChange={(e) => setSearch(e.target.value)}
      />

      <table className="w-full border rounded">
        <thead className="bg-gray-100">
          <tr>
            <th className="p-2 border">Name</th>
            <th className="p-2 border">Type</th>
            <th className="p-2 border">Region</th>
            <th className="p-2 border">Actions</th>
          </tr>
        </thead>
        <tbody>
          {filtered.map((opt) => (
            <tr key={opt._id} className="text-center">
              <td className="border p-2">{opt.name}</td>
              <td className="border p-2">{opt.type}</td>
              <td className="border p-2">{opt.region}</td>
              <td className="border p-2 space-x-2">
                <button
                  onClick={() => navigate(`/security-options/edit/${opt._id}`)}
                  className="bg-yellow-500 text-white px-3 py-1 rounded"
                >
                  Edit
                </button>
                <button
                  onClick={() => handleDelete(opt._id)}
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