import React, { useEffect, useState } from "react";
import axios from "axios";
import { useNavigate, useParams } from "react-router-dom";

export default function EditWeatherAlert() {
  const { id } = useParams(); // if id exists -> edit, else create
  const navigate = useNavigate();

  const [form, setForm] = useState({
    region: "",
    severity: "",
    message: "",
    issuedAt: "",
  });
  const [loading, setLoading] = useState(!!id);

  useEffect(() => {
    if (id) {
      const fetchAlert = async () => {
        try {
          const res = await axios.get(
            `${process.env.REACT_APP_BASE_URL}/api/weather-alerts/${id}`
          );
          setForm({
            region: res.data.region || "",
            severity: res.data.severity || "",
            message: res.data.message || "",
            issuedAt: res.data.issuedAt
              ? new Date(res.data.issuedAt).toISOString().slice(0, 16)
              : "",
          });
        } catch (err) {
          console.error(err);
          alert("Failed to load alert");
          navigate("/weather-alerts");
        } finally {
          setLoading(false);
        }
      };
      fetchAlert();
    }
  }, [id, navigate]);

  const handleChange = (e) =>
    setForm({ ...form, [e.target.name]: e.target.value });

  const handleSubmit = async (e) => {
    e.preventDefault();

    try {
      if (id) {
        await axios.put(
          `${process.env.REACT_APP_BASE_URL}/api/weather-alerts/${id}`,
          { ...form, issuedAt: form.issuedAt ? new Date(form.issuedAt) : null }
        );
        alert("Alert updated successfully");
      } else {
        await axios.post(`${process.env.REACT_APP_BASE_URL}/api/weather-alerts`, {
          ...form,
          issuedAt: form.issuedAt ? new Date(form.issuedAt) : new Date(),
        });
        alert("Alert created successfully");
      }
      navigate("/weather-alerts");
    } catch (err) {
      console.error(err);
      alert("Save failed");
    }
  };

  if (loading) return <div className="p-6">Loading...</div>;

  return (
    <form
      onSubmit={handleSubmit}
      className="max-w-xl mx-auto p-6 bg-white shadow rounded space-y-6"
    >
      <h2 className="text-2xl font-bold text-blue-700 border-b pb-2">
        {id ? "Edit Weather Alert" : "Create Weather Alert"}
      </h2>

      <input
        type="text"
        name="region"
        placeholder="Region"
        value={form.region}
        onChange={handleChange}
        className="w-full border rounded p-2"
        required
      />

      <select
        name="severity"
        value={form.severity}
        onChange={handleChange}
        className="w-full border rounded p-2"
      >
        <option value="">Select Severity</option>
        <option value="Low">Low</option>
        <option value="Moderate">Moderate</option>
        <option value="High">High</option>
        <option value="Extreme">Extreme</option>
      </select>

      <textarea
        name="message"
        placeholder="Message"
        value={form.message}
        onChange={handleChange}
        className="w-full border rounded p-2"
        rows="3"
        required
      />

      <label className="block text-sm text-gray-600">
        Issued At:
        <input
          type="datetime-local"
          name="issuedAt"
          value={form.issuedAt}
          onChange={handleChange}
          className="w-full border rounded p-2"
        />
      </label>

      <button
        type="submit"
        className="w-full bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg shadow transition"
      >
        {id ? "Update Alert" : "Create Alert"}
      </button>
    </form>
  );
}
