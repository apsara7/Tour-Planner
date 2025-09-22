// Test script to check the usersData endpoint from the frontend perspective
const axios = require("axios");
require("dotenv").config();

async function testUsersDataEndpoint() {
  try {
    console.log("Testing usersData endpoint...");
    console.log("Base URL:", process.env.REACT_APP_BASE_URL);

    // Test 1: Check if the server is reachable
    console.log("\n1. Testing server connectivity...");
    try {
      const serverResponse = await axios.get(
        `${process.env.REACT_APP_BASE_URL}/`
      );
      console.log("Server response:", serverResponse.data);
    } catch (error) {
      console.error("Server connectivity test failed:", error.message);
      return;
    }

    // Test 2: Check if the API endpoint is accessible without token
    console.log("\n2. Testing API endpoint without token...");
    try {
      const apiResponse = await axios.get(
        `${process.env.REACT_APP_BASE_URL}/api/usersData`
      );
      console.log("API response (no token):", apiResponse.data);
    } catch (error) {
      console.log("API endpoint accessible, but requires authentication");
      console.log("Status:", error.response?.status);
      console.log("Message:", error.response?.data?.message);
    }

    // Test 3: Test with an invalid token
    console.log("\n3. Testing API endpoint with invalid token...");
    try {
      const apiResponse = await axios.get(
        `${process.env.REACT_APP_BASE_URL}/api/usersData`,
        {
          headers: {
            Authorization: "Bearer invalid_token_here",
          },
        }
      );
      console.log("API response (invalid token):", apiResponse.data);
    } catch (error) {
      console.log("Status:", error.response?.status);
      console.log("Message:", error.response?.data?.message);
    }

    console.log(
      "\nTest completed. If you want to test with a valid token, you need to provide one."
    );
  } catch (error) {
    console.error("Unexpected error:", error.message);
  }
}

testUsersDataEndpoint();
