import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_model.dart';
import '../services/service_service.dart';

// Services state
class ServicesState {
  final List<ServiceModel> services;
  final List<ServiceCategory> categories;
  final List<ServiceModel> allServices;
  final List<ServiceCategory> allCategories;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  ServicesState({
    this.services = const [],
    this.categories = const [],
    this.allServices = const [],
    this.allCategories = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  ServicesState copyWith({
    List<ServiceModel>? services,
    List<ServiceCategory>? categories,
    List<ServiceModel>? allServices,
    List<ServiceCategory>? allCategories,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return ServicesState(
      services: services ?? this.services,
      categories: categories ?? this.categories,
      allServices: allServices ?? this.allServices,
      allCategories: allCategories ?? this.allCategories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// Services notifier
class ServicesNotifier extends StateNotifier<ServicesState> {
  final ServiceService _serviceService = ServiceService();

  ServicesNotifier() : super(ServicesState());

  Future<void> loadServices() async {
    state = state.copyWith(isLoading: true, error: null);
    
    final response = await _serviceService.getServices();

    if (response.success) {
      state = state.copyWith(
        services: response.data ?? [],
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.message,
      );
    }
  }

  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true, error: null);
    
    final response = await _serviceService.getCategories();

    if (response.success) {
      state = state.copyWith(
        categories: response.data ?? [],
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.message,
      );
    }
  }

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, error: null);
    
    final servicesResponse = await _serviceService.getServices();
    final categoriesResponse = await _serviceService.getCategories();

    final services = servicesResponse.data ?? [];
    final categories = categoriesResponse.data ?? [];

    state = state.copyWith(
      services: services,
      categories: categories,
      allServices: services,
      allCategories: categories,
      searchQuery: '',
      isLoading: false,
      error: servicesResponse.success && categoriesResponse.success 
          ? null 
          : (servicesResponse.message ?? categoriesResponse.message),
    );
  }

  void search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      state = state.copyWith(
        services: state.allServices,
        categories: state.allCategories,
        searchQuery: '',
      );
      return;
    }
    final filteredServices = state.allServices
        .where((s) =>
            s.name.toLowerCase().contains(q) ||
            s.description.toLowerCase().contains(q) ||
            s.category.toLowerCase().contains(q))
        .toList();
    final filteredCategories = state.allCategories
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.description.toLowerCase().contains(q))
        .toList();
    state = state.copyWith(
      services: filteredServices,
      categories: filteredCategories,
      searchQuery: query,
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final servicesProvider = StateNotifierProvider<ServicesNotifier, ServicesState>((ref) {
  return ServicesNotifier();
});
