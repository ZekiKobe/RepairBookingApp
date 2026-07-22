import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ui/themes/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/services_provider.dart';
import '../../services/technician_service.dart';
import 'technician_confirmation_screen.dart';
import 'login_screen.dart';

class TechnicianRegistrationScreen extends ConsumerStatefulWidget {
  const TechnicianRegistrationScreen({super.key});

  @override
  ConsumerState<TechnicianRegistrationScreen> createState() =>
      _TechnicianRegistrationScreenState();
}

class _TechnicianRegistrationScreenState
    extends ConsumerState<TechnicianRegistrationScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  bool _isSubmitting = false;

  // ── Step 2: Category Selection ───────────────────────────────
  final Set<String> _selectedCategories = {};

  static const _allCategories = [
    {'name': 'Plumbing',        'icon': '🔧', 'desc': 'Pipes, leaks, drainage'},
    {'name': 'Electrical',      'icon': '⚡', 'desc': 'Wiring, outlets, breakers'},
    {'name': 'Cleaning',        'icon': '🧹', 'desc': 'Home & office cleaning'},
    {'name': 'AC & Cooling',    'icon': '❄️', 'desc': 'AC install, repair, service'},
    {'name': 'Appliance Repair','icon': '🏠', 'desc': 'Fridge, washer, dryer'},
    {'name': 'Carpentry',       'icon': '🪚', 'desc': 'Furniture, doors, wood'},
    {'name': 'Painting',        'icon': '🎨', 'desc': 'Interior & exterior paint'},
    {'name': 'Roofing',         'icon': '🏗️', 'desc': 'Roof repair & waterproofing'},
    {'name': 'IT & Electronics','icon': '💻', 'desc': 'Computers, networks, phones'},
    {'name': 'Welding',         'icon': '🔩', 'desc': 'Metal work & fabrication'},
    {'name': 'Gardening',       'icon': '🌿', 'desc': 'Garden care & landscaping'},
    {'name': 'General Repair',  'icon': '🛠️', 'desc': 'Handyman & misc repairs'},
  ];

  // ── Step 3: Professional Info ─────────────────────────────────
  final _bioController = TextEditingController();
  final _cityController = TextEditingController();
  final _idDocController = TextEditingController();
  final _certDocController = TextEditingController();
  int _yearsOfExperience = 0;
  final _step2Key = GlobalKey<FormState>();

  // ── Step 3: Services ─────────────────────────────────────────
  // Backend services (by ID)
  final Map<String, TextEditingController> _servicePrices = {};
  final Set<String> _selectedServiceIds = {};
  // Custom typed services: list of {name, price controller}
  final List<Map<String, dynamic>> _customServices = [];
  final _customServiceNameController = TextEditingController();
  final _customServicePriceController = TextEditingController();

  // ── Step 4: Availability ─────────────────────────────────────
  final _days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
  final _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final Map<String, bool> _dayEnabled = {};
  final Map<String, TimeOfDay> _startTimes = {};
  final Map<String, TimeOfDay> _endTimes = {};

  @override
  void initState() {
    super.initState();
    for (final d in _days) {
      _dayEnabled[d] = false;
      _startTimes[d] = const TimeOfDay(hour: 8, minute: 0);
      _endTimes[d] = const TimeOfDay(hour: 17, minute: 0);
    }
    Future.microtask(() => ref.read(servicesProvider.notifier).loadAll());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    _idDocController.dispose();
    _certDocController.dispose();
    for (final c in _servicePrices.values) c.dispose();
    for (final cs in _customServices) {
      (cs['priceCtrl'] as TextEditingController).dispose();
    }
    _customServiceNameController.dispose();
    _customServicePriceController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentStep == 1 && _selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select at least one category'),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    if (_currentStep == 2 && !(_step2Key.currentState?.validate() ?? false)) return;
    if (_currentStep < 4) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep++);
    } else {
      _submit();
    }

  }

  void _goBack() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep--);
    }
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    final techService = TechnicianService();

    // Build services list (backend selected + custom typed)
    final servicesList = [
      ..._selectedServiceIds.map((id) {
        final price = double.tryParse(_servicePrices[id]?.text ?? '') ?? 0;
        return {'service': id, 'price': price};
      }),
    ];
    // Custom services have no backend ID — we store name in description
    final customServicesList = _customServices.map((cs) {
      final price = double.tryParse((cs['priceCtrl'] as TextEditingController).text) ?? 0;
      return {'serviceName': cs['name'] as String, 'price': price};
    }).toList();

    // Build availability as array of {day, slots:[{start,end}]} matching backend schema
    final availabilityList = _days
        .where((d) => _dayEnabled[d] == true)
        .map((d) => {
              'day': d,
              'slots': [
                {
                  'start': _formatTime(_startTimes[d]!),
                  'end': _formatTime(_endTimes[d]!),
                }
              ],
            })
        .toList();
    final availability = availabilityList.isNotEmpty ? availabilityList : null;

    // Append city to bio since location field requires GeoJSON coordinates
    final city = _cityController.text.trim();
    final bioWithCity = [
      _bioController.text.trim(),
      if (city.isNotEmpty) 'City: $city',
      if (_selectedCategories.isNotEmpty)
        'Categories: ${_selectedCategories.join(', ')}',
    ].where((s) => s.isNotEmpty).join('\n');

    // Create technician profile
    final result = await techService.createProfile(
      bio: bioWithCity,
      yearsOfExperience: _yearsOfExperience,
      idDocument: _idDocController.text.trim(),
      certificationDocument: _certDocController.text.trim(),
      isAvailable: true,
      services: servicesList.isNotEmpty ? servicesList : null,
      customServices: customServicesList.isNotEmpty ? customServicesList : null,
      availability: availability,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (result.success) {
      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        // Came from Profile screen — just show confirmation and pop back
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const TechnicianConfirmationScreen()),
        );
      } else {
        // Fresh registration — log out, pending approval
        await ref.read(authProvider.notifier).logout();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const TechnicianConfirmationScreen()),
          (route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.message ?? 'Submission failed. Please try again.'),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final steps = ['Account', 'Category', 'Profile', 'Services', 'Availability'];
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(AppTheme.spacingLg, AppTheme.spacingLg, AppTheme.spacingLg, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (_currentStep > 0)
                        GestureDetector(
                          onTap: _goBack,
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd), boxShadow: AppTheme.shadowSm),
                            child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppTheme.textPrimary),
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: () => Navigator.of(context).canPop()
                              ? Navigator.of(context).pop()
                              : Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  (route) => false,
                                ),
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd), boxShadow: AppTheme.shadowSm),
                            child: const Icon(Icons.close_rounded, size: 20, color: AppTheme.textPrimary),
                          ),
                        ),
                      const Spacer(),
                      Text('Step ${_currentStep + 1} of 5', style: const TextStyle(fontSize: 13, color: AppTheme.textTertiary, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  // Progress bar
                  Row(
                    children: List.generate(5, (i) {
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
                          decoration: BoxDecoration(
                            gradient: i <= _currentStep
                                ? const LinearGradient(colors: AppTheme.primaryGradient)
                                : null,
                            color: i <= _currentStep ? null : AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  Text(steps[_currentStep], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Text(_stepSubtitle(_currentStep), style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                  const SizedBox(height: AppTheme.spacingMd),
                ],
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2Categories(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                ],
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppTheme.primaryGradient),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: TextButton(
                    onPressed: _isSubmitting ? null : _goNext,
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: _isSubmitting
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : Text(
                            _currentStep < 3 ? 'Continue' : 'Submit Application',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _stepSubtitle(int step) {
    switch (step) {
      case 0: return 'Your account has been created successfully';
      case 1: return 'Choose the fields you specialise in';
      case 2: return 'Tell us about your professional background';
      case 3: return 'Select services you offer and set your prices';
      case 4: return 'Set your working days and hours';
      default: return '';
    }
  }

  // ── Step 1: Account created confirmation ──────────────────────
  Widget _buildStep1() {
    final user = ref.watch(currentUserProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: AppTheme.shadowSm,
            ),
            child: Row(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppTheme.successGradient),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 30),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.fullName ?? 'Account Created', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                      Text(user?.phone ?? '', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            decoration: BoxDecoration(color: AppTheme.pastelBlue, borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 20),
                SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: Text(
                    'Great! Your basic account is ready. Now complete your professional profile so our team can verify your qualifications.',
                    style: TextStyle(fontSize: 14, color: AppTheme.textPrimary, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          _buildChecklist(),
        ],
      ),
    );
  }

  Widget _buildChecklist() {
    final items = [
      ('Professional information & bio', Icons.person_outline),
      ('Services you offer with pricing', Icons.build_outlined),
      ('Working days & hours', Icons.schedule_outlined),
    ];
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusLg), boxShadow: AppTheme.shadowSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('What\'s next:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: AppTheme.spacingMd),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: AppTheme.pastelBlue, borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
                  child: Icon(item.$2, size: 18, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(child: Text(item.$1, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ── Step 2: Category Selection ────────────────────────────────
  Widget _buildStep2Categories() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          AppTheme.spacingLg, 0, AppTheme.spacingLg, AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Select all categories that apply. This helps customers find you.',
                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.55,
            ),
            itemCount: _allCategories.length,
            itemBuilder: (context, i) {
              final cat = _allCategories[i];
              final name = cat['name']!;
              final selected = _selectedCategories.contains(name);
              return GestureDetector(
                onTap: () => setState(() {
                  selected
                      ? _selectedCategories.remove(name)
                      : _selectedCategories.add(name);
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.primaryColor.withOpacity(0.12)
                        : AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(
                      color: selected
                          ? AppTheme.primaryColor.withOpacity(0.7)
<<<<<<< HEAD
                          : AppTheme.hairline,
=======
                          : const Color(0xFF2C3044),
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(cat['icon']!, style: const TextStyle(fontSize: 22)),
                          const Spacer(),
                          if (selected)
                            Container(
                              width: 20, height: 20,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, size: 13, color: Colors.white),
                            ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected ? AppTheme.primaryLight : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        cat['desc']!,
                        style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (_selectedCategories.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingMd),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: AppTheme.success, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedCategories.length} categor${_selectedCategories.length == 1 ? 'y' : 'ies'} selected',
                    style: const TextStyle(fontSize: 13, color: AppTheme.success, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Step 3: Professional Info ─────────────────────────────────
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
      child: Form(
        key: _step2Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('Bio / Introduction'),
            _buildTextArea(
              controller: _bioController,
              hint: 'Describe yourself and your experience in a few sentences...',
              maxLines: 4,
              maxLength: 500,
            ),
            const SizedBox(height: AppTheme.spacingLg),

            _sectionLabel('Years of Experience'),
            _buildExperiencePicker(),
            const SizedBox(height: AppTheme.spacingLg),

            _sectionLabel('City / Area You Serve *'),
            _buildField(
              controller: _cityController,
              hint: 'e.g. Addis Ababa, Bole',
              icon: Icons.location_on_outlined,
              validator: (v) => (v?.trim().isEmpty ?? true) ? 'City is required' : null,
            ),
            const SizedBox(height: AppTheme.spacingLg),

            _sectionLabel('National ID Number *'),
            _buildField(
              controller: _idDocController,
              hint: 'Enter your national ID number',
              icon: Icons.badge_outlined,
              validator: (v) => (v?.trim().isEmpty ?? true) ? 'ID number is required' : null,
            ),
            const SizedBox(height: AppTheme.spacingLg),

            _sectionLabel('Certification / License Number'),
            _buildField(
              controller: _certDocController,
              hint: 'e.g. Trade license, professional cert number',
              icon: Icons.workspace_premium_outlined,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(color: AppTheme.pastelYellow, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_outlined, color: AppTheme.warning, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Keep original documents ready. You\'ll be asked to present them during verification.',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
          ],
        ),
      ),
    );
  }

  Widget _buildExperiencePicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingSm),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd), boxShadow: AppTheme.shadowSm),
      child: Row(
        children: [
          const Icon(Icons.work_history_outlined, color: AppTheme.textTertiary, size: 20),
          const SizedBox(width: AppTheme.spacingMd),
          const Expanded(
            child: Text('Years of Experience', style: TextStyle(fontSize: 15, color: AppTheme.textPrimary)),
          ),
          IconButton(
            onPressed: () => setState(() { if (_yearsOfExperience > 0) _yearsOfExperience--; }),
            icon: const Icon(Icons.remove_circle_outline, color: AppTheme.primaryColor),
          ),
          Container(
            width: 44,
            alignment: Alignment.center,
            child: Text('$_yearsOfExperience', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          ),
          IconButton(
            onPressed: () => setState(() { if (_yearsOfExperience < 50) _yearsOfExperience++; }),
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }

  // ── Step 3: Services ─────────────────────────────────────────
  Widget _buildStep3() {
    final servicesState = ref.watch(servicesProvider);
    final backendServices = servicesState.services.where((s) => s.isActive).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Add custom service ──
          _sectionLabel('Add Services You Offer'),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: AppTheme.shadowSm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _customServiceNameController,
                        style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Service name (e.g. AC Repair)',
                          hintStyle: const TextStyle(color: AppTheme.textTertiary, fontSize: 13),
                          filled: true,
                          fillColor: AppTheme.surfaceLight,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _customServicePriceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Price (ETB)',
                          hintStyle: const TextStyle(color: AppTheme.textTertiary, fontSize: 13),
                          filled: true,
                          fillColor: AppTheme.surfaceLight,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: AppTheme.primaryGradient),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: IconButton(
                        onPressed: _addCustomService,
                        icon: const Icon(Icons.add, color: Colors.white, size: 20),
                        padding: const EdgeInsets.all(10),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
                if (_customServices.isNotEmpty) ...[  
                  const SizedBox(height: AppTheme.spacingMd),
                  const Divider(color: Color(0xFFE5E7EB)),
                  const SizedBox(height: AppTheme.spacingSm),
                  ..._customServices.asMap().entries.map((entry) {
                    final i = entry.key;
                    final cs = entry.value;
                    final priceCtrl = cs['priceCtrl'] as TextEditingController;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(color: AppTheme.pastelBlue, borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
                            child: const Icon(Icons.build_outlined, size: 18, color: AppTheme.primaryColor),
                          ),
                          const SizedBox(width: AppTheme.spacingSm),
                          Expanded(child: Text(cs['name'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
                          SizedBox(
                            width: 90,
                            child: TextFormField(
                              controller: priceCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              style: const TextStyle(fontSize: 13, color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                hintText: 'ETB',
                                hintStyle: const TextStyle(color: AppTheme.textTertiary, fontSize: 12),
                                filled: true,
                                fillColor: AppTheme.surfaceLight,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() {
                              (_customServices[i]['priceCtrl'] as TextEditingController).dispose();
                              _customServices.removeAt(i);
                            }),
                            icon: const Icon(Icons.close_rounded, size: 18, color: AppTheme.error),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),

          // ── Backend services (if available) ──
          if (servicesState.isLoading) ...[  
            const SizedBox(height: AppTheme.spacingLg),
            const Center(child: CircularProgressIndicator()),
          ] else if (backendServices.isNotEmpty) ...[  
            const SizedBox(height: AppTheme.spacingLg),
            _sectionLabel('Or pick from common services'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: backendServices.map((svc) {
                final selected = _selectedServiceIds.contains(svc.id);
                _servicePrices.putIfAbsent(svc.id, () => TextEditingController(text: svc.basePrice.toStringAsFixed(0)));
                return GestureDetector(
                  onTap: () => setState(() {
                    if (selected) _selectedServiceIds.remove(svc.id);
                    else _selectedServiceIds.add(svc.id);
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.primaryColor.withOpacity(0.1) : AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      border: Border.all(color: selected ? AppTheme.primaryColor : const Color(0xFFE5E7EB), width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selected) const Icon(Icons.check, size: 14, color: AppTheme.primaryColor),
                        if (selected) const SizedBox(width: 4),
                        Text(svc.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: selected ? AppTheme.primaryColor : AppTheme.textPrimary)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            // Show price fields for selected backend services
            if (_selectedServiceIds.isNotEmpty) ...[  
              const SizedBox(height: AppTheme.spacingMd),
              ..._selectedServiceIds.map((id) {
                final svc = backendServices.firstWhere((s) => s.id == id, orElse: () => backendServices.first);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: AppTheme.pastelBlue, borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
                        child: const Icon(Icons.build_outlined, size: 18, color: AppTheme.primaryColor),
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Expanded(child: Text(svc.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
                      const Text('ETB ', style: TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
                      SizedBox(
                        width: 90,
                        child: TextFormField(
                          controller: _servicePrices[id],
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          style: const TextStyle(fontSize: 13, color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            filled: true, fillColor: AppTheme.surfaceLight,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
          const SizedBox(height: AppTheme.spacingLg),
        ],
      ),
    );
  }

  void _addCustomService() {
    final name = _customServiceNameController.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _customServices.add({
        'name': name,
        'priceCtrl': TextEditingController(text: _customServicePriceController.text.trim()),
      });
      _customServiceNameController.clear();
      _customServicePriceController.clear();
    });
  }

  // ── Step 4: Availability ─────────────────────────────────────
  Widget _buildStep4() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
      itemCount: _days.length,
      itemBuilder: (context, i) {
        final day = _days[i];
        final label = _dayLabels[i];
        final enabled = _dayEnabled[day] ?? false;

        return Container(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: enabled ? AppTheme.primaryColor : Colors.transparent, width: 1.5),
            boxShadow: AppTheme.shadowSm,
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: Text(day[0].toUpperCase() + day.substring(1),
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: enabled ? AppTheme.textPrimary : AppTheme.textTertiary)),
                subtitle: enabled
                    ? Text('${_formatTime(_startTimes[day]!)} – ${_formatTime(_endTimes[day]!)}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary))
                    : const Text('Day off', style: TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
                secondary: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: enabled ? AppTheme.primaryColor.withOpacity(0.1) : AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Center(
                    child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: enabled ? AppTheme.primaryColor : AppTheme.textTertiary)),
                  ),
                ),
                value: enabled,
                onChanged: (v) => setState(() => _dayEnabled[day] = v),
                activeColor: AppTheme.primaryColor,
              ),
              if (enabled)
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppTheme.spacingMd, 0, AppTheme.spacingMd, AppTheme.spacingMd),
                  child: Row(
                    children: [
                      _timePicker(
                        label: 'Start',
                        time: _startTimes[day]!,
                        onPick: () async {
                          final t = await showTimePicker(context: context, initialTime: _startTimes[day]!);
                          if (t != null) setState(() => _startTimes[day] = t);
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
                        child: Icon(Icons.arrow_forward, size: 16, color: AppTheme.textTertiary),
                      ),
                      _timePicker(
                        label: 'End',
                        time: _endTimes[day]!,
                        onPick: () async {
                          final t = await showTimePicker(context: context, initialTime: _endTimes[day]!);
                          if (t != null) setState(() => _endTimes[day] = t);
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _timePicker({required String label, required TimeOfDay time, required VoidCallback onPick}) {
    return Expanded(
      child: GestureDetector(
        onTap: onPick,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: 10),
          decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: AppTheme.primaryColor),
                  const SizedBox(width: 4),
                  Text(_formatTime(time), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Shared helpers ────────────────────────────────────────────
  Widget _sectionLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
    child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
  );

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textTertiary, fontSize: 14),
        prefixIcon: Icon(icon, color: AppTheme.textTertiary, size: 20),
        filled: true,
        fillColor: AppTheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd), borderSide: const BorderSide(color: AppTheme.error, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd), borderSide: const BorderSide(color: AppTheme.error, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingMd),
      ),
    );
  }

  Widget _buildTextArea({
    required TextEditingController controller,
    required String hint,
    int maxLines = 4,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textTertiary, fontSize: 14),
        filled: true,
        fillColor: AppTheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
        contentPadding: const EdgeInsets.all(AppTheme.spacingMd),
      ),
    );
  }
}
