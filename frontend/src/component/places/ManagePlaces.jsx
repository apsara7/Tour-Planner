import React, { useEffect, useState } from "react";
import axios from "axios";
import { useNavigate } from "react-router-dom";

export default function ManagePlaces() {
  const [places, setPlaces] = useState([]);
  const [search, setSearch] = useState("");
  const navigate = useNavigate();

  useEffect(() => {
    fetchPlaces();
  }, []);

  const fetchPlaces = async () => {
    const res = await axios.get(
      `${process.env.REACT_APP_BASE_URL}/api/viewPlaces`
    );
    setPlaces(res.data);
  };

  const handleDelete = async (id) => {
    if (!window.confirm("Are you sure to delete this place?")) return;
    await axios.delete(
      `${process.env.REACT_APP_BASE_URL}/api/deletePlace/${id}`
    );
    fetchPlaces();
  };

  const filteredPlaces = places.filter((p) =>
    p.name.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-xl font-bold">Manage Places</h2>
        <button
          onClick={() => navigate("/places/create")}
          className="bg-blue-600 text-white px-4 py-2 rounded"
        >
          + Create Place
        </button>
      </div>

      <input
        type="text"
        placeholder="Search places..."
        className="border p-2 rounded w-full mb-4"
        value={search}
        onChange={(e) => setSearch(e.target.value)}
      />

      <table className="w-full border rounded">
        <thead className="bg-gray-100">
          <tr>
            <th className="p-2 border">Name</th>
            <th className="p-2 border">Province</th>
            <th className="p-2 border">Location</th>
            <th className="p-2 border">Entry Fee</th>
            <th className="p-2 border">Actions</th>
          </tr>
        </thead>
        <tbody>
          {filteredPlaces.map((place) => (
            <tr key={place._id} className="text-center">
              <td className="border p-2">{place.name}</td>
              <td className="border p-2">{place.province}</td>
              <td className="border p-2">{place.location}</td>
              <td className="border p-2">{place.entryFee}</td>
              <td className="border p-2 space-x-2">
                <button
                  onClick={() => navigate(`/places/edit/${place._id}`)}
                  className="bg-yellow-500 text-white px-3 py-1 rounded"
                >
                  Edit
                </button>
                <button
                  onClick={() => handleDelete(place._id)}
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
