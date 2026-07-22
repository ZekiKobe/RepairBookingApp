import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ui/themes/app_theme.dart';
import '../../models/technician_model.dart';
import '../../models/service_model.dart';
import '../../models/booking_model.dart';
import '../../providers/bookings_provider.dart';

class CreateBookingScreen extends ConsumerStatefulWidget {
  final TechnicianModel technician;
  final ServiceModel? preselectedService;

  const CreateBookingScreen({
    super.key,
    required this.technician,
    this.preselectedService,
  });

  @override
  ConsumerState<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends ConsumerState<CreateBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();

  ServiceModel? _selectedService;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTimeSlot = '08:00 - 10:00';
  bool _isSubmitting = false;

  final List<String> _timeSlots = [
    '08:00 - 10:00',
    '10:00 - 12:00',
    '12:00 - 14:00',
    '14:00 - 16:00',
    '16:00 - 18:00',
  ];

  @override
  void initState() {
    super.initState();
    _selectedService = widget.preselectedService ?? widget.technician.services?.firstOrNull;
  }

  @override
  void dispose() {
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 60)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppTheme.primaryColor,
            surface: AppTheme.surface,
            onSurface: AppTheme.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    HapticFeedback.mediumImpact();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select a service'),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _isSubmitting = true);

    final parts = _selectedTimeSlot.split(' - ');
    final request = CreateBookingRequest(
      serviceId: _selectedService!.id,
      technicianId: widget.technician.id,
      description: _descriptionController.text.trim(),
      address: _addressController.text.trim(),
      price: _selectedService!.basePrice,
      scheduledDate: _selectedDate,
      scheduledTimeSlot: {'start': parts[0], 'end': parts[1]},
    );

    final success = await ref.read(bookingsProvider.notifier).createBooking(request);
    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (success) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: AppTheme.successGradient),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              const Text('Booking Confirmed!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                'Your booking with ${widget.technician.fullName} is pending confirmation.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                  ),
                  child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      final error = ref.read(bookingsProvider).error ?? 'Failed to create booking';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tech = widget.technician;
    final services = tech.services ?? [];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(AppTheme.spacingLg, AppTheme.spacingLg, AppTheme.spacingLg, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: AppTheme.hairline, width: 1),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppTheme.textPrimary),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  const Text('Book Technician',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingMd),
            const Divider(color: AppTheme.hairline, height: 1),

            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  children: [
                    // Technician summary card
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        border: Border.all(color: AppTheme.hairline, width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52, height: 52,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: AppTheme.primaryGradient),
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            ),
                            child: Center(
                              child: Text(tech.initials,
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tech.fullName,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, color: AppTheme.warning, size: 14),
                                    const SizedBox(width: 3),
                                    Text('${(tech.rating ?? 0).toStringAsFixed(1)}  •  ${tech.yearsOfExperience ?? 0} yrs exp',
                                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                            ),
                            child: const Text('Available',
                                style: TextStyle(fontSize: 11, color: AppTheme.success, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingLg),

                    // Service selection
                    if (services.isNotEmpty) ...[
                      const Text('Select Service',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary, letterSpacing: 0.5)),
                      const SizedBox(height: AppTheme.spacingSm),
                      ...services.map((s) => GestureDetector(
                        onTap: () { HapticFeedback.selectionClick(); setState(() => _selectedService = s); },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(AppTheme.spacingMd),
                          decoration: BoxDecoration(
                            color: _selectedService?.id == s.id
                                ? AppTheme.primaryColor.withOpacity(0.12)
                                : AppTheme.surface,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(
                              color: _selectedService?.id == s.id
                                  ? AppTheme.primaryColor.withOpacity(0.6)
                                  : AppTheme.hairline,
                              width: _selectedService?.id == s.id ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.build_outlined, size: 16, color: AppTheme.primaryColor),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(s.name,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                              ),
                              Text('ETB ${s.basePrice.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryLight)),
                              if (_selectedService?.id == s.id) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.check_circle_rounded, size: 18, color: AppTheme.primaryColor),
                              ],
                            ],
                          ),
                        ),
                      )),
                      const SizedBox(height: AppTheme.spacingMd),
                    ],

                    // Date picker
                    const Text('Scheduled Date',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary, letterSpacing: 0.5)),
                    const SizedBox(height: AppTheme.spacingSm),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(color: AppTheme.hairline, width: 1),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 18, color: AppTheme.primaryColor),
                            const SizedBox(width: 12),
                            Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
                            ),
                            const Spacer(),
                            const Icon(Icons.chevron_right, size: 18, color: AppTheme.textTertiary),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingLg),

                    // Time slot
                    const Text('Time Slot',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary, letterSpacing: 0.5)),
                    const SizedBox(height: AppTheme.spacingSm),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _timeSlots.map((slot) => GestureDetector(
                        onTap: () { HapticFeedback.selectionClick(); setState(() => _selectedTimeSlot = slot); },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedTimeSlot == slot
                                ? AppTheme.primaryColor.withOpacity(0.15)
                                : AppTheme.surface,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(
                              color: _selectedTimeSlot == slot
                                  ? AppTheme.primaryColor.withOpacity(0.6)
                                  : AppTheme.hairline,
                              width: _selectedTimeSlot == slot ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.access_time, size: 14,
                                  color: _selectedTimeSlot == slot ? AppTheme.primaryColor : AppTheme.textTertiary),
                              const SizedBox(width: 6),
                              Text(slot,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: _selectedTimeSlot == slot ? AppTheme.primaryColor : AppTheme.textSecondary,
                                  )),
                            ],
                          ),
                        ),
                      )).toList(),
                    ),

                    const SizedBox(height: AppTheme.spacingLg),

                    // Address
                    const Text('Service Address',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary, letterSpacing: 0.5)),
                    const SizedBox(height: AppTheme.spacingSm),
                    TextFormField(
                      controller: _addressController,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Enter your address',
                        hintStyle: const TextStyle(color: AppTheme.textTertiary),
                        prefixIcon: const Icon(Icons.location_on_outlined, color: AppTheme.primaryColor, size: 20),
                        filled: true,
                        fillColor: AppTheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          borderSide: const BorderSide(color: AppTheme.hairline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          borderSide: const BorderSide(color: AppTheme.hairline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          borderSide: const BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Address is required' : null,
                    ),

                    const SizedBox(height: AppTheme.spacingLg),

                    // Description
                    const Text('Problem Description (optional)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary, letterSpacing: 0.5)),
                    const SizedBox(height: AppTheme.spacingSm),
                    TextFormField(
                      controller: _descriptionController,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Describe the issue...',
                        hintStyle: const TextStyle(color: AppTheme.textTertiary),
                        filled: true,
                        fillColor: AppTheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          borderSide: const BorderSide(color: AppTheme.hairline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          borderSide: const BorderSide(color: AppTheme.hairline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          borderSide: const BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingXl),

                    // Price summary
                    if (_selectedService != null)
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.payments_outlined, color: AppTheme.primaryColor, size: 20),
                            const SizedBox(width: 10),
                            const Text('Estimated Price', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                            const Spacer(),
                            Text('ETB ${_selectedService!.basePrice.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryLight)),
                          ],
                        ),
                      ),

                    const SizedBox(height: AppTheme.spacingLg),

                    // Submit
                    GestureDetector(
                      onTap: _isSubmitting ? null : _submit,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: _isSubmitting
                              ? null
                              : const LinearGradient(colors: AppTheme.primaryGradient),
                          color: _isSubmitting ? AppTheme.surfaceLight : null,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          boxShadow: _isSubmitting ? null : [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 22, height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor))
                              : const Text('Confirm Booking',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingLg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
