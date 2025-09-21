import React, { useState, useContext } from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";
import CryptoJS from "crypto-js";
import { UserContext } from "../../context/userContext";
import { jwtDecode } from "jwt-decode";
import { toast } from "react-toastify";

const Login = () => {
  const { setUserData, clearUserData } = useContext(UserContext);
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError("");

    try {
      const encryptedUsername = CryptoJS.AES.encrypt(
        username.toLowerCase(),
        process.env.REACT_APP_USER_KEY
      ).toString();

      const encryptedPassword = CryptoJS.AES.encrypt(
        password,
        process.env.REACT_APP_SECRET_KEY
      ).toString();

      const res = await axios.post(
        `${process.env.REACT_APP_BASE_URL}/api/login`,
        {
          encryptedUsername,
          encryptedPassword,
        }
      );

      if (res.data.success) {
        const { token, encryptedToken } = res.data;

        sessionStorage.setItem("token", token);
        sessionStorage.setItem("encryptedToken", encryptedToken);

        // decode expiration
        const decoded = jwtDecode(token);
        sessionStorage.setItem("expirationTime", decoded.exp);

        await setUserData(token);

        toast.success("Login successful!");
        navigate("/dashboard"); // ✅ Always redirect to dashboard
      } else {
        setError("Invalid credentials");
      }
    } catch (err) {
      console.error(err);
      setError("Login failed. Check username or password.");
      clearUserData();
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex h-screen items-center justify-center bg-gray-100">
      <form
        onSubmit={handleSubmit}
        className="bg-white shadow-md rounded px-8 pt-6 pb-8 w-96"
      >
        <h2 className="text-xl font-bold mb-4 text-center">Admin Login</h2>
        {error && <p className="text-red-600 mb-2">{error}</p>}
        <input
          type="text"
          placeholder="Username"
          className="border rounded w-full py-2 px-3 mb-3"
          value={username}
          onChange={(e) => setUsername(e.target.value)}
        />
        <input
          type="password"
          placeholder="Password"
          className="border rounded w-full py-2 px-3 mb-3"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
        />
        <button
          type="submit"
          className="bg-indigo-600 hover:bg-indigo-500 text-white w-full py-2 rounded"
          disabled={loading}
        >
          {loading ? "Signing in..." : "Login"}
        </button>
      </form>
    </div>
  );
};

export default Login;
