import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/technician_model.dart';
import '../services/technician_service.dart';

// Technicians state
class TechniciansState {
  final List<TechnicianModel> technicians;
  final List<TechnicianModel> allTechnicians;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  TechniciansState({
    this.technicians = const [],
    this.allTechnicians = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  TechniciansState copyWith({
    List<TechnicianModel>? technicians,
    List<TechnicianModel>? allTechnicians,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return TechniciansState(
      technicians: technicians ?? this.technicians,
      allTechnicians: allTechnicians ?? this.allTechnicians,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// Technicians notifier
class TechniciansNotifier extends StateNotifier<TechniciansState> {
  final TechnicianService _technicianService = TechnicianService();

  TechniciansNotifier() : super(TechniciansState());

  Future<void> loadTechnicians({
    String? service,
    bool? available,
    String? sort,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final response = await _technicianService.getTechnicians(
      service: service,
      available: available,
      sort: sort,
    );

    if (response.success) {
      final list = response.data ?? [];
      state = state.copyWith(
        technicians: list,
        allTechnicians: list,
        searchQuery: '',
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.message,
      );
    }
  }

  Future<void> loadByCategory(String categoryName) async {
    state = state.copyWith(isLoading: true, error: null);

    final response = await _technicianService.getTechnicians(
      category: categoryName,
    );

    if (response.success) {
      final list = response.data ?? [];
      state = state.copyWith(
        technicians: list,
        allTechnicians: list,
        searchQuery: '',
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.message,
      );
    }
  }

  void search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      state = state.copyWith(
        technicians: state.allTechnicians,
        searchQuery: '',
      );
      return;
    }
    final filtered = state.allTechnicians.where((t) {
      final name = t.fullName.toLowerCase();
      final spec = (t.specialization ?? '').toLowerCase();
      final bio = (t.bio ?? '').toLowerCase();
      final skills = (t.skills ?? []).map((s) => s.toLowerCase()).join(' ');
      final serviceNames = (t.services ?? []).map((s) => s.name.toLowerCase()).join(' ');
      final serviceCategories = (t.services ?? []).map((s) => s.category.toLowerCase()).join(' ');
      return name.contains(q) ||
          spec.contains(q) ||
          bio.contains(q) ||
          skills.contains(q) ||
          serviceNames.contains(q) ||
          serviceCategories.contains(q);
    }).toList();
    state = state.copyWith(
      technicians: filtered,
      searchQuery: query,
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void refresh() {
    loadTechnicians();
  }
}

// Provider
final techniciansProvider = StateNotifierProvider<TechniciansNotifier, TechniciansState>((ref) {
  return TechniciansNotifier();
});
