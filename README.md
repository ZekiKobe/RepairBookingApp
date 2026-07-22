# Repair & Technician Booking Platform

A production-ready mobile application for booking repair technicians (Electricians, Plumbers, AC Repair, etc.) built with Flutter, Node.js/Express, and MongoDB.

## Project Structure

```
RepairBookingApp/
├── backend/           # Node.js + Express + MongoDB API
├── mobile/            # Flutter mobile application
├── admin/             # React admin panel (placeholder)
└── README.md
```

## Tech Stack

### Backend
- **Runtime**: Node.js
- **Framework**: Express.js with TypeScript
- **Database**: MongoDB with Mongoose
- **Authentication**: JWT-based with bcrypt password hashing
- **Validation**: Joi
- **Security**: Helmet, CORS, Compression

### Mobile App
- **Framework**: Flutter (Dart)
- **State Management**: Riverpod
- **HTTP Client**: Dio
- **Navigation**: Custom navigation with Material routes
- **UI**: Material 3 with custom dark theme
- **Location**: Google Maps Flutter, Geolocator
- **Payment**: Flutter Stripe (mock integration)

## Features

### Customer App
- Phone-based registration & login
- Forgot password (OTP via phone → verify → reset)
- Profile management with edit support
- Service discovery with category grid and search
- Browse & filter technicians by category
- Technician cards with ratings, reviews, pricing
- Create bookings (date/time picker, issue description, address)
- Booking tracking (Pending → Accepted → In Progress → Completed)
- Cancel bookings with confirmation modal
- In-app chat per booking or direct with technician
- Real-time unread message badge on nav bar
- Job completion: rate technician (stars + comment) & confirm payment
- Payment status shown in booking details

### Technician App (same app, role-based)
- Register as technician
- Dashboard with pending and active jobs
- Accept / decline job requests with confirmation
- Start job → Mark as In Progress → Mark as Completed flow
- View all bookings with tab filters (Pending / Active / Completed)
- In-app chat with customers
- Profile & settings management

### Admin (API endpoints only)
- Manage users & technicians
- Approve/reject technicians
- View bookings & analytics

## Getting Started

### Prerequisites
- Node.js v18+
- MongoDB (local or MongoDB Atlas)
- Flutter SDK 3.x
- Android Studio / Xcode

### Backend Setup

```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env
# Edit .env with your MongoDB URI and JWT secrets

# Run database seed
npm run seed

# Start development server
npm run dev
```

The backend will run on `http://localhost:5000`

### Mobile App Setup

```bash
# Navigate to mobile directory
cd mobile

# Get Flutter dependencies
flutter pub get

# Run the app
flutter run
```

### Demo Accounts (from seed data)

| Role | Phone | Password |
|------|-------|----------|
| Admin | 0912345678 | admin123 |
| Technician | 0998765432 | tech123 |
| User | 0911122334 | user123 |

## API Documentation

### Authentication Endpoints
- `POST /api/auth/register` - Register new user/technician
- `POST /api/auth/login` - Login with phone/password
- `POST /api/auth/refresh` - Refresh access token
- `GET /api/auth/me` - Get current user
- `POST /api/auth/forgot-password` - Request OTP for password reset
- `POST /api/auth/verify-otp` - Verify OTP code
- `POST /api/auth/reset-password` - Set new password

### User Endpoints
- `GET /api/users/profile` - Get user profile
- `PUT /api/users/profile` - Update profile
- `PUT /api/users/location` - Update location

### Technician Endpoints
- `GET /api/technicians` - List approved technicians
- `GET /api/technicians/:id` - Get technician details
- `POST /api/technicians/profile` - Create technician profile
- `PUT /api/technicians/:id` - Update technician profile

### Booking Endpoints
- `POST /api/bookings` - Create booking
- `GET /api/bookings/my-bookings` - Get user bookings
- `PUT /api/bookings/:id/accept` - Accept booking (technician)
- `PUT /api/bookings/:id/status` - Update booking status (in_progress / completed)
- `PUT /api/bookings/:id/cancel` - Cancel booking

### Message Endpoints
- `GET /api/messages/conversations` - Get all conversations
- `GET /api/messages/booking/:bookingId` - Get booking messages
- `GET /api/messages/direct/:userId` - Get direct messages
- `POST /api/messages` - Send a message
- `GET /api/messages/unread-count` - Get unread message count

### Review Endpoints
- `POST /api/reviews` - Submit a review (customer, after completion)
- `GET /api/reviews/technician/:technicianId` - Get technician reviews
- `GET /api/reviews/my/reviews` - Get my reviews
- `PUT /api/reviews/:id` - Update a review
- `DELETE /api/reviews/:id` - Delete a review

### Payment Endpoints
- `POST /api/payments/intent` - Create payment intent
- `POST /api/payments/confirm` - Confirm payment
- `GET /api/payments/status/:bookingId` - Get payment status

### Service Endpoints
- `GET /api/services` - List all services
- `GET /api/services/categories` - List categories

## UI/UX Design

The app features a premium dark theme:
- **Background**: Deep black (#0F0F0F)
- **Surface**: Dark gray (#1A1A1A)
- **Primary**: Indigo (#6366F1)
- **Accent**: Blue/Purple gradient
- **Typography**: Clean, modern fonts with clear hierarchy
- **Components**: Rounded cards (12-16px radius), soft shadows, consistent 8px grid spacing

### Key Screens
1. **Splash Screen** - Animated logo with loading
2. **Onboarding** - 3-page intro with feature highlights
3. **Login / Register** - Phone-based auth with role selection
4. **Forgot Password** - 3-step OTP reset flow (phone → OTP → new password)
5. **Home (Customer)** - Service category grid, search, top technicians list
6. **Home (Technician)** - Dashboard with pending jobs and quick actions
7. **Services / Search** - Category browser + technician search results
8. **Booking Detail** - Full info, status banner, actions, chat button, rate & pay
9. **Create Booking** - Date/time picker, address, description
10. **Messages** - Full-width conversation list with unread badges
11. **Chat** - Per-booking or direct chat with presence status
12. **Profile** - Stats card, menu, edit profile, settings, logout
13. **Settings** - Edit profile, change password, notifications, support

## Architecture

### Backend (Clean Architecture)
```
src/
├── config/         # Database configuration
├── controllers/    # Request handlers
├── middleware/     # Auth, error handling
├── models/         # Mongoose schemas
├── routes/         # API route definitions
├── services/       # Business logic
└── utils/          # Helper functions
```

### Mobile (Layered Architecture)
```
lib/
├── data/
│   ├── models/     # Data classes
│   ├── repositories/ # Data access
│   └── services/   # API clients
├── providers/      # Riverpod state management
├── ui/
│   ├── screens/    # Full page widgets
│   ├── widgets/    # Reusable components
│   └── themes/     # AppTheme
└── utils/          # Constants, helpers
```

## MongoDB Schema

### Collections
- **users**: phone, email, password, role, profile info, location
- **technicians**: user ref, services, pricing, availability, approval status
- **services**: name, category, icon, base price
- **bookings**: user, technician, service, status, timestamps
- **reviews**: booking ref, rating, comment
- **messages**: sender, receiver, booking ref, content

## Development Status

### Completed
- Full backend REST API (auth, users, technicians, bookings, messages, reviews, payments)
- JWT authentication with refresh tokens
- Forgot password via OTP (in-memory, 10-min expiry)
- All Mongoose models and relationships
- Flutter app fully connected to backend via Dio
- Riverpod state management across all providers
- Premium dark theme with consistent AppTheme constants
- All core screens implemented and wired
- Booking full lifecycle: create → accept → progress → complete
- Job completion flow: customer rates technician + confirms payment
- In-app messaging (booking-based + direct) with polling
- Real-time unread message badge on bottom nav
- Online / last-seen presence indicator in chat
- Confirmation modals for all destructive actions
- Profile editing, settings, change password
- Technician dashboard with accept/decline job controls

### Remaining for Production
- Real SMS gateway for OTP (Twilio / Africa's Talking)
- Push notifications (FCM)
- Real payment gateway (Stripe / local ETB provider)
- Image upload for profile photos and chat attachments
- WebSocket / SSE for real-time chat (replace polling)
- React admin panel
- Comprehensive test suite
- CI/CD pipeline and cloud deployment

## License

MIT License

## Contributors

Built for the Ethiopian market and beyond.
