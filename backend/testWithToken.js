// Simple test to check if the endpoint works with a token
const axios = require("axios");

async function testEndpoint() {
  try {
    // This is a placeholder - you'll need to get a real token from your application
    const token =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY1NzY4N2FjZjQwZjQwZjQwZjQwZjQwIiwidXNlcm5hbWUiOiJhZG1pbiIsInJvbGUiOiJhZG1pbiIsImlhdCI6MTcwMDAwMDAwMCwiZXhwIjoxODAwMDAwMDAwfQ.INVALID_TOKEN_FOR_TESTING";

    console.log("Testing endpoint with token...");

    const response = await axios.get("http://localhost:4066/api/usersData", {
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
      },
    });

    console.log("Success! Status:", response.status);
    console.log("Data:", JSON.stringify(response.data, null, 2));
  } catch (error) {
    console.log("Error details:");
    console.log("Status:", error.response?.status);
    console.log("Data:", error.response?.data);
    console.log("Message:", error.message);
  }
}

testEndpoint();
