# Users Data API Documentation

This document describes the new API endpoints for managing users and their trip data.

## Endpoints

### Get All Users with Trips
```
GET /api/usersData
```

**Description**: Retrieves all users with their associated trips.

**Authentication**: Required (Admin token)

**Response**:
```json
{
  "success": true,
  "message": "Users retrieved successfully",
  "users": [
    {
      "_id": "user_id",
      "firstName": "John",
      "lastName": "Doe",
      "email": "john.doe@example.com",
      "username": "johndoe",
      "role": "user",
      "createdAt": "2023-01-01T00:00:00.000Z",
      "updatedAt": "2023-01-01T00:00:00.000Z",
      "trips": [
        {
          "_id": "trip_id",
          "name": "My Trip to Sri Lanka",
          "description": "A wonderful trip",
          "status": "planning",
          "startDate": "2023-06-01T00:00:00.000Z",
          "endDate": "2023-06-10T00:00:00.000Z",
          "travellersCount": 2,
          "estimatedBudget": {
            "entriesTotal": 1000,
            "guidesTotal": 500,
            "hotelsTotal": 2000,
            "vehiclesTotal": 800,
            "otherExpenses": 300,
            "totalBudget": 4600
          },
          "places": [...],
          "guides": [...],
          "hotels": [...],
          "vehicles": [...],
          "createdAt": "2023-01-01T00:00:00.000Z",
          "updatedAt": "2023-01-01T00:00:00.000Z"
        }
      ]
    }
  ]
}
```

### Get Single User with Trips
```
GET /api/usersData/:userId
```

**Description**: Retrieves a specific user with their associated trips.

**Authentication**: Required (Admin token)

**Parameters**:
- `userId` (string, required): The ID of the user to retrieve

**Response**:
```json
{
  "success": true,
  "message": "User retrieved successfully",
  "user": {
    "_id": "user_id",
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@example.com",
    "username": "johndoe",
    "role": "user",
    "createdAt": "2023-01-01T00:00:00.000Z",
    "updatedAt": "2023-01-01T00:00:00.000Z",
    "trips": [...]
  }
}
```

### Delete User
```
DELETE /api/usersData/:userId
```

**Description**: Soft deletes a user by setting their `isActive` flag to false. Also soft deletes all trips associated with the user.

**Authentication**: Required (Admin token)

**Parameters**:
- `userId` (string, required): The ID of the user to delete

**Response**:
```json
{
  "success": true,
  "message": "User deleted successfully"
}
```

## Implementation Details

The implementation can be found in:
- Controller: `backend/controllers/usersController.js`
- Routes: `backend/routes/index.js`

The controller provides three functions:
1. `getAllUsersWithTrips` - Gets all users with their trips
2. `getUserWithTrips` - Gets a specific user with their trips
3. `deleteUser` - Soft deletes a user and their trips

## Testing

To test these endpoints, you can use the provided test script:
```bash
node backend/testUsersData.js
```

Note: You'll need to replace the placeholder token with a valid admin authentication token.