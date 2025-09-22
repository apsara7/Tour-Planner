@echo off
echo Testing usersData endpoint without authentication
curl -X GET http://localhost:4066/api/usersData
echo.
echo Testing with a simple header
curl -X GET -H "Content-Type: application/json" http://localhost:4066/api/usersData