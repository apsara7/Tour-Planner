const express = require("express");
const cors = require("cors");
require("dotenv").config();

const allowedOrigins = process.env.ORIGIN_URL.split(",");

const corsMiddleware = cors({
  // origin: function (origin, callback) {
  //   if (!origin || allowedOrigins.includes(origin)) {
  //     callback(null, true);
  //   } else {
  //     callback(new Error("Not allowed by CORS"));
  //   }
  // },
  origin: "*",
  methods: ["GET", "POST", "PUT", "DELETE"],
  allowedHeaders: ["Content-Type", "Authorization"],
  credentials: true,
});

const bodyParserMiddleware = express.json();

module.exports = { corsMiddleware, bodyParserMiddleware };
