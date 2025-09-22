const http = require("http");

const options = {
  hostname: "localhost",
  port: 4066,
  path: "/api/users",
  method: "GET",
  headers: {
    Authorization: "Bearer your-test-token-here",
  },
};

const req = http.request(options, (res) => {
  console.log(`Status Code: ${res.statusCode}`);
  console.log(`Headers: ${JSON.stringify(res.headers)}`);

  let data = "";
  res.on("data", (chunk) => {
    data += chunk;
  });

  res.on("end", () => {
    console.log(`Body: ${data}`);
    console.log("Request completed");
  });
});

req.on("error", (error) => {
  console.error("Error:", error.message);
});

req.end();
