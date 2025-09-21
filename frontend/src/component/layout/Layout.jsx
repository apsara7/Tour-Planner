// src/component/layout/Layout.jsx
import React, { useState, useContext } from "react";
import Sidebar from "./Sidebar";
import Header from "./Header";
import { UserContext } from "../../context/userContext";

const Layout = ({ children, title }) => {
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const { userData, clearUserData } = useContext(UserContext);

  const handleLogout = () => {
    if (window.confirm("Are you sure you want to logout?")) {
      clearUserData();
      window.location.href = "/"; // redirect to login
    }
  };

  return (
    <div className="flex min-h-screen bg-slate-50">
      {/* Sidebar */}
      <div
        className={`${
          sidebarOpen ? "translate-x-0" : "-translate-x-full"
        } fixed lg:relative lg:translate-x-0 transition-transform duration-300 ease-in-out z-30 lg:z-auto`}
      >
        <Sidebar handleLogout={handleLogout} />
      </div>

      {/* Overlay for mobile */}
      {sidebarOpen && (
        <div
          className="fixed inset-0 bg-black bg-opacity-50 z-20 lg:hidden"
          onClick={() => setSidebarOpen(false)}
        />
      )}

      {/* Main Content */}
      <div className="flex-1 flex flex-col overflow-hidden">
        <Header
          title={title || "Dashboard"}
          username={userData?.name || "Admin"}
          onMenuToggle={() => setSidebarOpen(!sidebarOpen)}
        />

        <main className="flex-1 overflow-auto p-6">{children}</main>
      </div>
    </div>
  );
};

export default Layout;
