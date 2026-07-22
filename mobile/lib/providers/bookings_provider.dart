import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';

// Bookings state
class BookingsState {
  final List<BookingModel> bookings;
  final bool isLoading;
  final String? error;

  BookingsState({
    this.bookings = const [],
    this.isLoading = false,
    this.error,
  });

  BookingsState copyWith({
    List<BookingModel>? bookings,
    bool? isLoading,
    String? error,
  }) {
    return BookingsState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // Get bookings by status
  List<BookingModel> getByStatus(String status) {
    return bookings.where((b) => b.status == status).toList();
  }

  List<BookingModel> get pending => getByStatus('pending');
  List<BookingModel> get active => getByStatus('accepted') + getByStatus('in_progress');
  List<BookingModel> get completed => getByStatus('completed');
  List<BookingModel> get cancelled => getByStatus('cancelled');
}

// Bookings notifier
class BookingsNotifier extends StateNotifier<BookingsState> {
  final BookingService _bookingService = BookingService();

  BookingsNotifier() : super(BookingsState());

  Future<void> loadBookings({bool isTechnician = false}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final response = isTechnician
        ? await _bookingService.getTechnicianBookings()
        : await _bookingService.getMyBookings();

    if (response.success) {
      state = state.copyWith(
        bookings: response.data ?? [],
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.message,
      );
    }
  }

  Future<bool> createBooking(CreateBookingRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final response = await _bookingService.createBooking(request);

    if (response.success && response.data != null) {
      state = state.copyWith(
        bookings: [...state.bookings, response.data!],
        isLoading: false,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.message,
      );
      return false;
    }
  }

  Future<bool> cancelBooking(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final response = await _bookingService.cancelBooking(id);

    if (response.success) {
      // Update the booking status locally
      final updatedBookings = state.bookings.map((b) {
        if (b.id == id) {
          return BookingModel(
            id: b.id,
            user: b.user,
            userId: b.userId,
            technician: b.technician,
            technicianId: b.technicianId,
            service: b.service,
            serviceId: b.serviceId,
            status: 'cancelled',
            description: b.description,
            address: b.address,
            price: b.price,
            scheduledDate: b.scheduledDate,
            timeSlot: b.timeSlot,
            createdAt: b.createdAt,
            updatedAt: b.updatedAt,
            completedAt: b.completedAt,
          );
        }
        return b;
      }).toList();

      state = state.copyWith(
        bookings: updatedBookings,
        isLoading: false,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.message,
      );
      return false;
    }
  }

  Future<bool> acceptBooking(String id) async {
    final response = await _bookingService.acceptBooking(id);
    if (response.success) {
      _updateLocalStatus(id, 'accepted');
      return true;
    }
    state = state.copyWith(error: response.message);
    return false;
  }

  Future<bool> updateBookingStatus(String id, String status) async {
    final response = await _bookingService.updateStatus(id, status);
    if (response.success) {
      _updateLocalStatus(id, status);
      return true;
    }
    state = state.copyWith(error: response.message);
    return false;
  }

  void _updateLocalStatus(String id, String status) {
    final updated = state.bookings.map((b) {
      if (b.id == id) {
        return BookingModel(
          id: b.id, user: b.user, userId: b.userId,
          technician: b.technician, technicianId: b.technicianId,
          service: b.service, serviceId: b.serviceId,
          status: status, description: b.description,
          address: b.address, price: b.price,
          scheduledDate: b.scheduledDate, timeSlot: b.timeSlot,
          createdAt: b.createdAt, updatedAt: b.updatedAt,
          completedAt: status == 'completed' ? DateTime.now() : b.completedAt,
          paymentStatus: b.paymentStatus,
        );
      }
      return b;
    }).toList();
    state = state.copyWith(bookings: updated);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void refresh({bool isTechnician = false}) {
    loadBookings(isTechnician: isTechnician);
  }
}

// Provider
final bookingsProvider = StateNotifierProvider<BookingsNotifier, BookingsState>((ref) {
  return BookingsNotifier();
});
