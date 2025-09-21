import React, { useState } from "react";
import axios from "axios";
import { useNavigate } from "react-router-dom";

export default function AddPlace() {
  const navigate = useNavigate();

  const [form, setForm] = useState({
    name: "",
    description: "",
    province: "",
    district: "",
    location: "",
    mapUrl: "",
    latitude: "",
    longitude: "",
    visitingHours: "",
    entryFee: "",
    bestTimeToVisit: "",
    transportation: "",
    highlights: "",
  });
  const [images, setImages] = useState([]);

  const handleChange = (e) =>
    setForm({ ...form, [e.target.name]: e.target.value });

  // Convert FileList to array when selecting
  const handleFileChange = (e) => {
    const filesArray = Array.from(e.target.files);
    setImages((prev) => [...prev, ...filesArray]);
  };

  // Remove image by index
  const handleRemoveImage = (index) => {
    setImages((prev) => prev.filter((_, i) => i !== index));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const formData = new FormData();

    // Add text fields
    Object.keys(form).forEach((key) => formData.append(key, form[key]));

    // Add multiple images
    for (let i = 0; i < images.length; i++) {
      formData.append("images", images[i]);
    }

    try {
      await axios.post(
        `${process.env.REACT_APP_BASE_URL}/api/createPlaces`,
        formData,
        { headers: { "Content-Type": "multipart/form-data" } }
      );
      alert("Place created successfully");
      navigate("/places");
    } catch (err) {
      console.error(err);
      alert("Failed to create place");
    }
  };

  return (
    <form
      onSubmit={handleSubmit}
      className="max-w mx-auto p-16 bg-white shadow-lg rounded space-y-6"
    >
      <h2 className="text-2xl font-bold text-blue-700 border-b pb-2">
        Add New Place
      </h2>

      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <input
          type="text"
          name="name"
          placeholder="Name"
          value={form.name}
          onChange={handleChange}
          className="w-full border rounded p-2"
          required
        />
        <input
          type="text"
          name="province"
          placeholder="Province"
          value={form.province}
          onChange={handleChange}
          className="w-full border rounded p-2"
          required
        />
        <input
          type="text"
          name="district"
          placeholder="District"
          value={form.district}
          onChange={handleChange}
          className="w-full border rounded p-2"
        />
        <input
          type="text"
          name="location"
          placeholder="Location (City / Area)"
          value={form.location}
          onChange={handleChange}
          className="w-full border rounded p-2"
          required
        />
      </div>

      <textarea
        name="description"
        placeholder="Description"
        value={form.description}
        onChange={handleChange}
        className="w-full border rounded p-2"
        rows="4"
        required
      />

      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <input
          type="text"
          name="mapUrl"
          placeholder="Google Map URL"
          value={form.mapUrl}
          onChange={handleChange}
          className="w-full border rounded p-2"
        />
        <input
          type="number"
          step="any"
          name="latitude"
          placeholder="Latitude"
          value={form.latitude}
          onChange={handleChange}
          className="w-full border rounded p-2"
        />
        <input
          type="number"
          step="any"
          name="longitude"
          placeholder="Longitude"
          value={form.longitude}
          onChange={handleChange}
          className="w-full border rounded p-2"
        />
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <input
          type="text"
          name="visitingHours"
          placeholder="Visiting Hours"
          value={form.visitingHours}
          onChange={handleChange}
          className="w-full border rounded p-2"
        />
        <input
          type="number"
          name="entryFee"
          placeholder="Entry Fee"
          value={form.entryFee}
          onChange={handleChange}
          className="w-full border rounded p-2"
        />
        <input
          type="text"
          name="bestTimeToVisit"
          placeholder="Best Time to Visit"
          value={form.bestTimeToVisit}
          onChange={handleChange}
          className="w-full border rounded p-2"
        />
      </div>
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <input
          type="text"
          name="transportation"
          placeholder="How to Travel (Bus, Train, etc.)"
          value={form.transportation}
          onChange={handleChange}
          className="w-full border rounded p-2"
        />

        <textarea
          name="highlights"
          placeholder="Highlights (comma separated)"
          value={form.highlights}
          onChange={handleChange}
          className="w-full border rounded p-2 sm:col-span-2"
          rows="2"
        />
      </div>

      <input
        type="file"
        multiple
        accept="image/*"
        onChange={handleFileChange}
        className="w-full border p-2"
      />

      <div className="flex flex-wrap gap-4 mt-2">
        {(images || []).map((file, index) => (
          <div key={index} className="relative w-24 h-24">
            <img
              src={URL.createObjectURL(file)}
              alt={`preview ${index}`}
              onLoad={(e) => URL.revokeObjectURL(e.target.src)}
              className="w-full h-full object-cover rounded border"
            />
            <button
              type="button"
              onClick={() => handleRemoveImage(index)}
              className="absolute top-0 right-0 bg-red-600 text-white text-xs px-1 rounded-full hover:bg-red-700"
            >
              X
            </button>
          </div>
        ))}
      </div>

      <p className="text-sm text-gray-500">
        Upload at least 5 high-quality images
      </p>

      <button
        type="submit"
        className="w-full bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg shadow transition"
      >
        Save Place
      </button>
    </form>
  );
}
