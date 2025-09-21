import React, { createContext, useState } from "react";
import axios from "axios";
import { encryptData, decryptData } from "../utils/encryption";

export const UserContext = createContext();

export const UserProvider = ({ children }) => {
  const [userData, setUserDataState] = useState(() => {
    const stored = sessionStorage.getItem("user");
    return stored ? decryptData(stored) : null;
  });

  const setUserData = async (token) => {
    try {
      const res = await axios.get(
        `${process.env.REACT_APP_BASE_URL}/api/dashboard`,
        {
          headers: { Authorization: `Bearer ${token}` },
        }
      );

      const encryptedUser = encryptData(res.data);
      sessionStorage.setItem("user", encryptedUser);
      setUserDataState(res.data);
    } catch (err) {
      console.error("Failed to fetch user:", err);
      clearUserData();
    }
  };

  const clearUserData = () => {
    sessionStorage.removeItem("user");
    sessionStorage.removeItem("token");
    setUserDataState(null);
  };

  return (
    <UserContext.Provider value={{ userData, setUserData, clearUserData }}>
      {children}
    </UserContext.Provider>
  );
};
