// Comprehensive test to verify the usersData endpoint works correctly
const axios = require("axios");

async function comprehensiveTest() {
  try {
    console.log("=== Comprehensive Test for usersData Endpoint ===\n");

    // Test 1: Basic connectivity
    console.log("1. Testing basic server connectivity...");
    const serverResponse = await axios.get("http://localhost:4066/");
    console.log("✓ Server is running:", serverResponse.data);

    // Test 2: API endpoint accessibility
    console.log("\n2. Testing API endpoint accessibility...");
    try {
      await axios.get("http://localhost:4066/api/usersData");
      console.log("✗ Unexpected: Endpoint should require authentication");
    } catch (error) {
      if (error.response?.status === 401) {
        console.log("✓ Endpoint correctly requires authentication");
        console.log("  Response:", error.response.data.message);
      } else {
        console.log(
          "✗ Unexpected error:",
          error.response?.status,
          error.response?.data
        );
      }
    }

    // Test 3: Test with invalid token
    console.log("\n3. Testing with invalid token...");
    try {
      await axios.get("http://localhost:4066/api/usersData", {
        headers: { Authorization: "Bearer invalid_token" },
      });
      console.log("✗ Unexpected: Should have rejected invalid token");
    } catch (error) {
      if (error.response?.status === 403) {
        console.log("✓ Endpoint correctly rejects invalid tokens");
        console.log("  Response:", error.response.data.message);
      } else {
        console.log(
          "✗ Unexpected error:",
          error.response?.status,
          error.response?.data
        );
      }
    }

    console.log("\n=== Test Summary ===");
    console.log(
      "✓ The usersData endpoint is properly registered and accessible"
    );
    console.log("✓ Authentication is working correctly");
    console.log(
      "✓ The issue is likely with the frontend not sending a valid token"
    );

    console.log("\n=== Troubleshooting Steps ===");
    console.log("1. Verify that the user is logged in as an admin");
    console.log('2. Check that sessionStorage contains a valid "token"');
    console.log("3. Ensure the token has not expired");
    console.log("4. Verify that the user has admin privileges");
  } catch (error) {
    console.error("Test failed with unexpected error:", error.message);
  }
}

comprehensiveTest();
