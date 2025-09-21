// src/pages/admin/AddWeatherAlert.jsx
import React, { useState, useEffect } from "react";
import axios from "axios";
import { useNavigate, useParams } from "react-router-dom";

export default function AddWeatherAlert() {
  const navigate = useNavigate();
  const { id } = useParams(); // if editing
  const [form, setForm] = useState({
    title: "",
    region: "",
    severity: "",
    description: "",
    issuedAt: "",
  });

  // Load existing alert if editing
  useEffect(() => {
    if (id) {
      axios.get(`/api/weather-alerts/${id}`).then((res) => {
        setForm(res.data);
      });
    }
  }, [id]);

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      if (id) {
        await axios.put(`/api/weather-alerts/${id}`, form);
      } else {
        await axios.post("/api/weather-alerts", form);
      }
      navigate("/admin/weather-alerts");
    } catch (err) {
      console.error(err);
      alert("Error saving alert");
    }
  };

  return (
    <div className="max-w-xl mx-auto p-6 bg-white rounded shadow">
      <h2 className="text-xl font-bold mb-4">
        {id ? "Edit Weather Alert" : "Create Weather Alert"}
      </h2>
      <form onSubmit={handleSubmit} className="space-y-4">
        <input
          name="title"
          value={form.title}
          onChange={handleChange}
          placeholder="Title"
          className="w-full p-2 border rounded"
          required
        />
        <input
          name="region"
          value={form.region}
          onChange={handleChange}
          placeholder="Region"
          className="w-full p-2 border rounded"
          required
        />
        <select
          name="severity"
          value={form.severity}
          onChange={handleChange}
          className="w-full p-2 border rounded"
          required
        >
          <option value="">Select severity</option>
          <option value="Low">Low</option>
          <option value="Moderate">Moderate</option>
          <option value="High">High</option>
          <option value="Extreme">Extreme</option>
        </select>
        <textarea
          name="description"
          value={form.description}
          onChange={handleChange}
          placeholder="Description"
          className="w-full p-2 border rounded"
          rows={4}
          required
        />
        <input
          type="datetime-local"
          name="issuedAt"
          value={form.issuedAt}
          onChange={handleChange}
          className="w-full p-2 border rounded"
        />
        <button
          type="submit"
          className="bg-blue-600 text-white px-4 py-2 rounded"
        >
          {id ? "Update Alert" : "Create Alert"}
        </button>
      </form>
    </div>
  );
}
