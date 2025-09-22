const axios = require("axios");

// Test the usersData endpoint
async function testUsersData() {
  try {
    console.log("Testing usersData endpoint...");

    // You'll need to replace this with a valid admin token from your application
    // For testing purposes, you can get this from your browser's developer tools
    // after logging in as an admin
    const token = "YOUR_ADMIN_TOKEN_HERE";

    console.log("Making request to http://localhost:4066/api/usersData");

    const response = await axios.get("http://localhost:4066/api/usersData", {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    console.log("Success! Response:", JSON.stringify(response.data, null, 2));
  } catch (error) {
    console.error(
      "Error:",
      error.response ? error.response.data : error.message
    );
  }
}

// Test single user endpoint
async function testSingleUser() {
  try {
    console.log("Testing single user endpoint...");

    // You'll need to replace this with a valid admin token and userId
    const token = "YOUR_ADMIN_TOKEN_HERE";
    const userId = "USER_ID_HERE";

    console.log(
      `Making request to http://localhost:4066/api/usersData/${userId}`
    );

    const response = await axios.get(
      `http://localhost:4066/api/usersData/${userId}`,
      {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      }
    );

    console.log("Success! Response:", JSON.stringify(response.data, null, 2));
  } catch (error) {
    console.error(
      "Error:",
      error.response ? error.response.data : error.message
    );
  }
}

// Run the tests
testUsersData()
  .then(() => {
    console.log("\n----------------------------------------\n");
    return testSingleUser();
  })
  .catch(console.error);
