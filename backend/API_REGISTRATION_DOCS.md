# User Registration API Documentation

## Base URL

`http://localhost:3000` (or your server URL)

## Registration Endpoints

### 1. Register New User

**POST** `/register`

**Request Body:**

```json
{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "password123",
  "firstName": "John",
  "lastName": "Doe",
  "phone": "+1234567890"
}
```

**Success Response (201):**

```json
{
  "success": true,
  "message": "User registered successfully! You can now log in.",
  "data": {
    "id": "64f1234567890abcdef12345",
    "username": "john_doe",
    "email": "john@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "mobile": "+1234567890",
    "role": "user"
  }
}
```

**Error Response (400):**

```json
{
  "message": "Username already exists. Please choose a different username."
}
```

### 2. Check Username Availability

**GET** `/check-username/:username`

**Example:** `/check-username/john_doe`

**Response:**

```json
{
  "available": false,
  "message": "Username already taken"
}
```

### 3. Check Email Availability

**GET** `/check-email/:email`

**Example:** `/check-email/john@example.com`

**Response:**

```json
{
  "available": true,
  "message": "Email is available"
}
```

### 4. Check Phone Availability

**GET** `/check-phone/:phone`

**Example:** `/check-phone/+1234567890`

**Response:**

```json
{
  "available": false,
  "message": "Phone number already registered"
}
```

## Validation Rules

1. **Username**: Required, minimum 3 characters, must be unique
2. **Email**: Required, valid email format, must be unique
3. **Password**: Required, minimum 6 characters
4. **First Name**: Required
5. **Last Name**: Optional
6. **Phone**: Optional but recommended, must be unique if provided

## Error Codes

- **400**: Bad request (validation errors, duplicate data)
- **500**: Internal server error

## Usage in Flutter App

```dart
// Registration function for AuthProvider
Future<bool> register(Map<String, String> userData) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(userData),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 201) {
      return true;
    } else {
      errorMessage = data['message'];
      return false;
    }
  } catch (e) {
    errorMessage = 'Network error occurred';
    return false;
  }
}

// Check username availability
Future<bool> checkUsernameAvailability(String username) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/check-username/$username'),
    );

    final data = json.decode(response.body);
    return data['available'] ?? false;
  } catch (e) {
    return false;
  }
}
```

## Password Security

- Passwords are hashed using bcrypt with 10 salt rounds
- Original passwords are never stored in the database
- Hashed passwords are never returned in API responses

## Default User Role

- All registered users get the default role: "user"
- Admin users are created only through the initial setup endpoint
