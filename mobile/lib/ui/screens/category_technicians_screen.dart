import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ui/themes/app_theme.dart';
import '../../providers/technicians_provider.dart';
import '../../models/technician_model.dart';
import 'create_booking_screen.dart';
import 'chat_screen.dart';

class CategoryTechniciansScreen extends ConsumerStatefulWidget {
  final String categoryName;
  final String? serviceId;

  const CategoryTechniciansScreen({
    super.key,
    required this.categoryName,
    this.serviceId,
  });

  @override
  ConsumerState<CategoryTechniciansScreen> createState() =>
      _CategoryTechniciansScreenState();
}

class _CategoryTechniciansScreenState
    extends ConsumerState<CategoryTechniciansScreen> {
  // Own provider instance so it doesn't clobber the home list
  late final _provider = StateNotifierProvider<TechniciansNotifier, TechniciansState>(
    (ref) => TechniciansNotifier(),
  );

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(_provider.notifier).loadByCategory(widget.categoryName));
  }

  List<Color> _colorsForIndex(int index) {
    final palette = [
      [AppTheme.pastelBlue, AppTheme.primaryColor],
      [AppTheme.pastelOrange, AppTheme.primaryAccent],
      [AppTheme.pastelGreen, AppTheme.success],
      [AppTheme.pastelPurple, AppTheme.primaryLight],
      [AppTheme.pastelYellow, AppTheme.warning],
      [AppTheme.pastelMint, AppTheme.success],
    ];
    return palette[index % palette.length];
  }

  IconData _iconForCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('plumb')) return Icons.water_damage_outlined;
    if (n.contains('electr')) return Icons.electrical_services_outlined;
    if (n.contains('clean')) return Icons.cleaning_services_outlined;
    if (n.contains('ac') || n.contains('air')) return Icons.ac_unit_outlined;
    if (n.contains('appl') || n.contains('fridge')) return Icons.kitchen_outlined;
    if (n.contains('carp') || n.contains('wood')) return Icons.handyman_outlined;
    if (n.contains('paint')) return Icons.format_paint_outlined;
    if (n.contains('roof')) return Icons.roofing_outlined;
    return Icons.build_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_provider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingLg,
                AppTheme.spacingLg,
                AppTheme.spacingLg,
                0,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(
<<<<<<< HEAD
                            color: AppTheme.hairline, width: 1),
=======
                            color: const Color(0xFF2C3044), width: 1),
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          size: 20, color: AppTheme.textPrimary),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.categoryName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          state.isLoading
                              ? 'Finding technicians...'
                              : '${state.technicians.length} technician${state.technicians.length == 1 ? '' : 's'} available',
                          style: const TextStyle(
                              fontSize: 13, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.15),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Icon(
                      _iconForCategory(widget.categoryName),
                      size: 20,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingMd),
<<<<<<< HEAD
            const Divider(color: AppTheme.hairline, height: 1),
=======
            const Divider(color: Color(0xFF2C3044), height: 1),
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739

            // Body
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null
                      ? _buildError(state.error!)
                      : state.technicians.isEmpty
                          ? _buildEmpty()
                          : ListView.builder(
                              padding: const EdgeInsets.all(AppTheme.spacingLg),
                              itemCount: state.technicians.length,
                              itemBuilder: (context, i) => Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppTheme.spacingMd),
                                child: _buildTechCard(
                                    state.technicians[i], i),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _technicianCircleAvatar(TechnicianModel tech, List<Color> colors) {
    final url = tech.user?.avatar?.trim();
    final hasPhoto = url != null && url.isNotEmpty;
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.hairline.withValues(alpha: 0.85)),
        boxShadow: AppTheme.shadowSm,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasPhoto
          ? Image.network(
              url,
              width: 58,
              height: 58,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _technicianInitials(tech, colors),
            )
          : _technicianInitials(tech, colors),
    );
  }

  Widget _technicianInitials(TechnicianModel tech, List<Color> colors) {
    return ColoredBox(
      color: colors[0],
      child: Center(
        child: Text(
          tech.initials,
          style: TextStyle(
            color: colors[1],
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
  Widget _buildTechCard(TechnicianModel tech, int index) {
    final colors = _colorsForIndex(index);
    final rating = tech.rating ?? 0.0;
    final reviews = tech.reviewCount ?? 0;
    final service = tech.specialization ??
        tech.services?.firstOrNull?.name ??
        widget.categoryName;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
<<<<<<< HEAD
        border: Border.all(color: AppTheme.hairline, width: 1),
=======
        border: Border.all(color: const Color(0xFF2C3044), width: 1),
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
        boxShadow: AppTheme.shadowSm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Row(
          children: [
            // Avatar
<<<<<<< HEAD
            _technicianCircleAvatar(tech, colors),
=======
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: colors[0],
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Center(
                child: Text(
                  tech.initials,
                  style: TextStyle(
                    color: colors[1],
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
            const SizedBox(width: AppTheme.spacingMd),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tech.fullName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    service,
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppTheme.warning, size: 15),
                      const SizedBox(width: 3),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        ' ($reviews reviews)',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textTertiary),
                      ),
                    ],
                  ),
                  if (tech.services != null && tech.services!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.payments_outlined,
                            size: 13, color: AppTheme.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          'From ETB ${tech.services!.first.basePrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textTertiary),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Action buttons
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (tech.isAvailable)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.15),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: const Text(
                      'Available',
                      style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.success,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                // Message icon button
                GestureDetector(
                  onTap: () {
<<<<<<< HEAD
                    final userId = tech.user?.id ?? tech.userId;
=======
                    final userId = tech.user?.id ?? tech.userId ?? '';
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
                    if (userId.isEmpty) return;
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        receiverId: userId,
                        otherUserName: tech.fullName,
                        otherUserInitials: tech.initials,
                      ),
                    ));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: AppTheme.primaryColor.withOpacity(0.4)),
                    ),
                    child: const Icon(Icons.chat_bubble_outline_rounded,
                        size: 16, color: AppTheme.primaryColor),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient:
                        const LinearGradient(colors: AppTheme.primaryGradient),
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => CreateBookingScreen(technician: tech),
                      ));
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Book',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing2xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              ),
              child: Icon(
                _iconForCategory(widget.categoryName),
                size: 36,
                color: AppTheme.textTertiary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            const Text(
              'No technicians yet',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'No technicians are currently available for ${widget.categoryName}. Check back soon.',
              style: const TextStyle(
                  fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXl),
            GestureDetector(
              onTap: () => ref
                  .read(_provider.notifier)
                  .loadByCategory(widget.categoryName),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingLg, vertical: 12),
                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(colors: AppTheme.primaryGradient),
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: const Text('Retry',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing2xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 48, color: AppTheme.textTertiary),
            const SizedBox(height: AppTheme.spacingMd),
            const Text('Could not load technicians',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: AppTheme.spacingSm),
            Text(error,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary),
                textAlign: TextAlign.center),
            const SizedBox(height: AppTheme.spacingLg),
            GestureDetector(
              onTap: () => ref
                  .read(_provider.notifier)
                  .loadByCategory(widget.categoryName),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingLg, vertical: 12),
                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(colors: AppTheme.primaryGradient),
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: const Text('Try Again',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
