import React from "react";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import { UserProvider } from "./context/userContext";
import Login from "./component/Auth/login";
import Dashboard from "./component/layout/Dashboard";
import PrivateRoute from "./component/routing/privateRoute";
import { ToastContainer } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";
import "./index.css";
import Layout from "./component/layout/Layout";

import ManagePlaces from "./component/places/ManagePlaces";
import AddPlace from "./component/places/AddPlaces";
import EditPlace from "./component/places/EditPlaces";
import ManageHotels from "./component/hotels/ManageHotels";
import AddHotel from "./component/hotels/AddHotels";
import EditHotel from "./component/hotels/EditHotels";
import ManageGuides from "./component/guides/ManageGuides";
import AddGuide from "./component/guides/AddGuide";
import EditGuide from "./component/guides/EditGuide";
import ManageVehicles from "./component/vehicles/ManageVehicles";
import AddVehicle from "./component/vehicles/AddVehicle";
import EditVehicle from "./component/vehicles/EditVehicle";
import AddSecurityOption from "./component/security/AddSecurityOption";
import EditSecurityOption from "./component/security/EditSecurityOption";
import ManageSecurityOptions from "./component/security/ManageSecurityOptions";
import AddWeatherAlert from "./component/weather/AddWeatherAlert";
import ManageWeatherAlerts from "./component/weather/ManageWeatherAlerts";
import EditWeatherAlert from "./component/weather/EditWeatherAlert";

function App() {
  return (
    <UserProvider>
      <BrowserRouter>
        <Routes>
          {/* Public Route */}
          <Route path="/" element={<Login />} />
          {/* Protected Routes */}
          <Route
            path="/dashboard"
            element={
              <PrivateRoute>
                <Dashboard />
              </PrivateRoute>
            }
          />
          <Route
            path="/places"
            element={
              <PrivateRoute>
                <Layout title="Manage Places">
                  <ManagePlaces />
                </Layout>
              </PrivateRoute>
            }
          />
          <Route
            path="/places/create"
            element={
              <PrivateRoute>
                <Layout title="Add Place">
                  <AddPlace />
                </Layout>
              </PrivateRoute>
            }
          />
          <Route
            path="/places/edit/:id"
            element={
              <PrivateRoute>
                <Layout title="Edit Place">
                  <EditPlace />
                </Layout>
              </PrivateRoute>
            }
          />
          {/* Hotel Routes */}
          <Route
            path="/hotels"
            element={
              <PrivateRoute>
                <Layout title="Manage Hotels">
                  <ManageHotels />
                </Layout>
              </PrivateRoute>
            }
          />
          <Route
            path="/hotels/create"
            element={
              <PrivateRoute>
                <Layout title="Add Hotel">
                  <AddHotel />
                </Layout>
              </PrivateRoute>
            }
          />
          <Route
            path="/hotels/edit/:id"
            element={
              <PrivateRoute>
                <Layout title="Edit Hotel">
                  <EditHotel />
                </Layout>
              </PrivateRoute>
            }
          />
          {/* guides routes */}
          <Route
            path="/guides"
            element={
              <PrivateRoute>
                <Layout title="Manage Guides">
                  <ManageGuides />
                </Layout>
              </PrivateRoute>
            }
          />
          <Route
            path="/guides/create"
            element={
              <PrivateRoute>
                <Layout title="Add Guide">
                  <AddGuide />
                </Layout>
              </PrivateRoute>
            }
          />
          <Route
            path="/guides/edit/:id"
            element={
              <PrivateRoute>
                <Layout title="Edit Guide">
                  <EditGuide />
                </Layout>
              </PrivateRoute>
            }
          />
          <Route
            path="/vehicles"
            element={
              <PrivateRoute>
                <Layout title="Manage Vehicles">
                  <ManageVehicles />
                </Layout>
              </PrivateRoute>
            }
          />
          <Route
            path="/vehicles/create"
            element={
              <PrivateRoute>
                <Layout title="Add Vehicle">
                  <AddVehicle />
                </Layout>
              </PrivateRoute>
            }
          />
          <Route
            path="/vehicles/edit/:id"
            element={
              <PrivateRoute>
                <Layout title="Edit Vehicle">
                  <EditVehicle />
                </Layout>
              </PrivateRoute>
            }
          />
          <Route
            path="/security-options"
            element={
              <PrivateRoute>
                <Layout title="Security Options">
                  <ManageSecurityOptions />
                </Layout>
              </PrivateRoute>
            }
          />
          <Route
            path="/security-options/create"
            element={
              <PrivateRoute>
                <Layout title="Add Security Option">
                  <AddSecurityOption />
                </Layout>
              </PrivateRoute>
            }
          />
          <Route
            path="/security-options/edit/:id"
            element={
              <PrivateRoute>
                <Layout title="Edit Security Option">
                  <EditSecurityOption />
                </Layout>
              </PrivateRoute>
            }
          />
          <Route
            path="/weather-alerts"
            element={
              <PrivateRoute>
                <Layout title="Weather Alerts">
                  <ManageWeatherAlerts />
                </Layout>
              </PrivateRoute>
            }
          />
          <Route
            path="/weather-alerts/create"
            element={
              <PrivateRoute>
                <Layout title="Add Weather Alert">
                  <AddWeatherAlert />
                </Layout>
              </PrivateRoute>
            }
          />
          <Route
            path="/weather-alerts/edit/:id"
            element={
              <PrivateRoute>
                <Layout title="Edit Weather Alert">
                  <EditWeatherAlert />
                </Layout>
              </PrivateRoute>
            }
          />
        </Routes>
      </BrowserRouter>
      <ToastContainer />
    </UserProvider>
  );
}

export default App;
