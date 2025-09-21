import React, { useEffect, useState } from "react";
import axios from "axios";
import { useNavigate, useParams } from "react-router-dom";

export default function EditPlace() {
  const { id } = useParams();
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
  const [existingImages, setExistingImages] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchPlace = async () => {
      try {
        const response = await axios.get(
          `${process.env.REACT_APP_BASE_URL}/api/viewPlaceByID/${id}`
        );

        if (response.data.status === "Success") {
          const place = response.data.place;

          // Set form data
          setForm({
            name: place.name || "",
            description: place.description || "",
            province: place.province || "",
            district: place.district || "",
            location: place.location || "",
            mapUrl: place.mapUrl || "",
            latitude: place.latitude || "",
            longitude: place.longitude || "",
            visitingHours: place.visitingHours || "",
            entryFee: place.entryFee || "",
            bestTimeToVisit: place.bestTimeToVisit || "",
            transportation: place.transportation || "",
            highlights: place.highlights || "",
          });

          // Set existing images
          setExistingImages(place.images || []);
        }
      } catch (err) {
        console.error("Error fetching place:", err);
        alert("Failed to load place data");
        navigate("/places");
      } finally {
        setLoading(false);
      }
    };

    if (id) {
      fetchPlace();
    }
  }, [id, navigate]);

  const handleChange = (e) =>
    setForm({ ...form, [e.target.name]: e.target.value });

  // Convert FileList to array when selecting new images
  const handleFileChange = (e) => {
    const filesArray = Array.from(e.target.files);
    setImages((prev) => [...prev, ...filesArray]);
  };

  // Remove new image by index
  const handleRemoveNewImage = (index) => {
    setImages((prev) => prev.filter((_, i) => i !== index));
  };

  // Remove existing image by index
  const handleRemoveExistingImage = (index) => {
    setExistingImages((prev) => prev.filter((_, i) => i !== index));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!form.name) {
      alert("Place name is required");
      return;
    }

    const formData = new FormData();

    // Add text fields
    Object.keys(form).forEach((key) => formData.append(key, form[key]));

    // Add new images
    for (let i = 0; i < images.length; i++) {
      formData.append("images", images[i]);
    }

    try {
      await axios.put(
        `${process.env.REACT_APP_BASE_URL}/api/editPlace/${id}`,
        formData,
        { headers: { "Content-Type": "multipart/form-data" } }
      );
      alert("Place updated successfully");
      navigate("/places");
    } catch (err) {
      console.error(err);
      alert("Failed to update place");
    }
  };

  if (loading) {
    return (
      <div className="max-w mx-auto p-16 bg-white shadow-lg rounded">
        <div className="text-center">Loading...</div>
      </div>
    );
  }

  return (
    <form
      onSubmit={handleSubmit}
      className="max-w mx-auto p-16 bg-white shadow-lg rounded space-y-6"
    >
      <h2 className="text-2xl font-bold text-blue-700 border-b pb-2">
        Edit Place
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

      {/* Existing Images */}
      {existingImages.length > 0 && (
        <div>
          <h3 className="text-lg font-semibold mb-2">Current Images:</h3>
          <div className="flex flex-wrap gap-4 mb-4">
            {existingImages.map((imageUrl, index) => (
              <div key={index} className="relative w-24 h-24">
                <img
                  src={imageUrl}
                  alt={`existing ${index}`}
                  className="w-full h-full object-cover rounded border"
                />
                <button
                  type="button"
                  onClick={() => handleRemoveExistingImage(index)}
                  className="absolute top-0 right-0 bg-red-600 text-white text-xs px-1 rounded-full hover:bg-red-700"
                >
                  X
                </button>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Add New Images */}
      <div>
        <h3 className="text-lg font-semibold mb-2">Add New Images:</h3>
        <input
          type="file"
          multiple
          accept="image/*"
          onChange={handleFileChange}
          className="w-full border p-2"
        />

        <div className="flex flex-wrap gap-4 mt-2">
          {images.map((file, index) => (
            <div key={index} className="relative w-24 h-24">
              <img
                src={URL.createObjectURL(file)}
                alt={`preview ${index}`}
                onLoad={(e) => URL.revokeObjectURL(e.target.src)}
                className="w-full h-full object-cover rounded border"
              />
              <button
                type="button"
                onClick={() => handleRemoveNewImage(index)}
                className="absolute top-0 right-0 bg-red-600 text-white text-xs px-1 rounded-full hover:bg-red-700"
              >
                X
              </button>
            </div>
          ))}
        </div>
      </div>

      <p className="text-sm text-gray-500">
        Upload high-quality images to replace or add to existing ones
      </p>

      <button
        type="submit"
        className="w-full bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg shadow transition"
      >
        Update Place
      </button>
    </form>
  );
}
