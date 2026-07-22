# API Integration Guide

## Overview
The mobile app is now configured to connect to the backend API instead of using mock data.

## Base URL Configuration
Edit `lib/services/api_service.dart` to set the correct backend URL:

```dart
// For Android emulator
static const String baseUrl = 'http://10.0.2.2:5000/api';

// For iOS simulator
static const String baseUrl = 'http://localhost:5000/api';

// For physical device (use your computer's IP)
static const String baseUrl = 'http://192.168.1.xxx:5000/api';
```

## Created Files

### Services (lib/services/)
- `api_service.dart` - Base API configuration with Dio
- `auth_service.dart` - Authentication API calls
- `booking_service.dart` - Booking API calls
- `service_service.dart` - Services API calls
- `technician_service.dart` - Technicians API calls
- `message_service.dart` - Messages API calls
- `user_service.dart` - User profile API calls

### Models (lib/models/)
- `user_model.dart` - User data model
- `service_model.dart` - Service data model
- `booking_model.dart` - Booking data model
- `technician_model.dart` - Technician data model
- `message_model.dart` - Message data model

### Providers (lib/providers/)
- `auth_provider.dart` - Authentication state management
- `services_provider.dart` - Services state management
- `bookings_provider.dart` - Bookings state management
- `technicians_provider.dart` - Technicians state management
- `messages_provider.dart` - Messages state management
- `index.dart` - Provider exports

## Updated Files
- `main.dart` - Added API service initialization
- `login_screen.dart` - Now uses real authentication API
- `register_screen.dart` - Now uses real registration API

## How to Use

### Authentication
```dart
// Login
final success = await ref.read(authProvider.notifier).login(
  phone: '0912345678',
  password: 'password123',
);

// Register
final success = await ref.read(authProvider.notifier).register(
  firstName: 'John',
  lastName: 'Doe',
  phone: '0912345678',
  password: 'password123',
  role: 'user', // or 'technician'
);

// Logout
await ref.read(authProvider.notifier).logout();

// Check auth state
final isAuthenticated = ref.watch(isAuthenticatedProvider);
final user = ref.watch(currentUserProvider);
```

### Bookings
```dart
// Load bookings
await ref.read(bookingsProvider.notifier).loadBookings();

// Create booking
await ref.read(bookingsProvider.notifier).createBooking(
  CreateBookingRequest(
    serviceId: 'service_id',
    description: 'Fix my plumbing',
    address: 'Addis Ababa',
    price: 500,
    scheduledDate: DateTime.now().add(Duration(days: 1)),
  ),
);

// Cancel booking
await ref.read(bookingsProvider.notifier).cancelBooking('booking_id');

// Access bookings
final bookings = ref.watch(bookingsProvider).bookings;
final pending = ref.watch(bookingsProvider).pending;
```

### Services
```dart
// Load services
await ref.read(servicesProvider.notifier).loadServices();
await ref.read(servicesProvider.notifier).loadCategories();

// Access data
final services = ref.watch(servicesProvider).services;
final categories = ref.watch(servicesProvider).categories;
```

### Technicians
```dart
// Load technicians
await ref.read(techniciansProvider.notifier).loadTechnicians();

// Access data
final technicians = ref.watch(techniciansProvider).technicians;
```

### Messages
```dart
// Load conversations
await ref.read(messagesProvider.notifier).loadConversations();

// Load messages for a booking
await ref.read(messagesProvider.notifier).loadMessages('booking_id');

// Send message
await ref.read(messagesProvider.notifier).sendMessage(
  bookingId: 'booking_id',
  content: 'Hello, when will you arrive?',
);

// Access data
final conversations = ref.watch(messagesProvider).conversations;
final unreadCount = ref.watch(messagesProvider).unreadCount;
```

## Backend API Endpoints

### Authentication
- POST `/api/auth/register` - Register new user
- POST `/api/auth/login` - Login
- GET `/api/auth/me` - Get current user

### Bookings
- GET `/api/bookings/my-bookings` - Get user's bookings
- POST `/api/bookings` - Create booking
- PUT `/api/bookings/:id/cancel` - Cancel booking

### Services
- GET `/api/services` - List services
- GET `/api/services/categories` - List categories

### Technicians
- GET `/api/technicians` - List technicians

### Messages
- GET `/api/messages/conversations` - Get conversations
- GET `/api/messages/booking/:id` - Get messages
- POST `/api/messages` - Send message
- GET `/api/messages/unread-count` - Get unread count

### User Profile
- GET `/api/users/profile` - Get profile
- PUT `/api/users/profile` - Update profile

## Testing the Integration

1. Start the backend server:
   ```bash
   cd backend
   npm run dev
   ```

2. Update the base URL in `api_service.dart` to match your backend

3. Run the mobile app:
   ```bash
   cd mobile
   flutter run
   ```

4. Register a new account or login with existing credentials

## Next Steps

To complete the integration, update the remaining screens:

1. **services_screen.dart** - Use `servicesProvider` instead of mock data
2. **bookings_screen.dart** - Use `bookingsProvider` instead of mock data
3. **messages_screen.dart** - Use `messagesProvider` instead of mock data
4. **profile_screen.dart** - Use `authProvider` for user data

Example pattern for updating screens:
```dart
// In build method, wrap with Consumer or use ref.watch
@override
Widget build(BuildContext context) {
  final servicesState = ref.watch(servicesProvider);
  
  // Load data on init
  useEffect(() {
    ref.read(servicesProvider.notifier).loadServices();
    return null;
  }, []);
  
  // Use servicesState.services instead of mock data
  // Handle loading with servicesState.isLoading
  // Handle errors with servicesState.error
}
```
