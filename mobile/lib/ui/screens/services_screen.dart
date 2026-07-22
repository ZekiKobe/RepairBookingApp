import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ui/themes/app_theme.dart';
import '../../providers/services_provider.dart';
import '../../providers/technicians_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/technician_model.dart';
import 'category_technicians_screen.dart';
import 'create_booking_screen.dart';
import 'chat_screen.dart';
import 'notifications_screen.dart';
import '../../providers/notifications_provider.dart';
import '../widgets/drawer_opener.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(servicesProvider.notifier).loadAll();
      ref.read(techniciansProvider.notifier).loadTechnicians();
      ref.read(notificationsProvider.notifier).loadUnreadCount();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesAcCoolingCategory(String n) {
    if (n.contains('hvac')) return true;
    if (n.contains('a/c') || n.contains('a.c')) return true;
    if (RegExp(r'\bac\b').hasMatch(n)) return true;
    if (n.contains('air conditioning') || n.contains('air-conditioning')) return true;
    if (n.contains('cooling') && (n.contains('air') || n.contains('home') || n.contains('repair'))) return true;
    return false;
  }

  // Fallback category icons based on name
  IconData _iconForCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('plumb') || n.contains('pipe') || n.contains('drain') || n.contains('faucet')) {
      return Icons.water_damage_outlined;
    }
    if (n.contains('electr')) return Icons.electrical_services_outlined;
    if (n.contains('clean')) return Icons.cleaning_services_outlined;
    if (_matchesAcCoolingCategory(n)) return Icons.ac_unit_outlined;
    if (n.contains('appl') || n.contains('fridge')) return Icons.kitchen_outlined;
    if (n.contains('carp') || n.contains('wood')) return Icons.handyman_outlined;
    if (n.contains('paint')) return Icons.format_paint_outlined;
    if (n.contains('roof')) return Icons.roofing_outlined;
    return Icons.build_outlined;
  }

  List<Color> _colorsForIndex(int index) {
    final palette = [
      [AppTheme.pastelBlue, AppTheme.primaryLight],
      [AppTheme.pastelOrange, AppTheme.warningLight],
      [AppTheme.pastelGreen, AppTheme.successLight],
      [AppTheme.pastelPurple, AppTheme.primaryColor],
      [AppTheme.pastelYellow, AppTheme.warning],
      [AppTheme.pastelMint, AppTheme.primaryAccent],
    ];
    return palette[index % palette.length];
  }

  static const double _categoryTileWidth = 158;
  static const double _categorySliderHeight = 152;
  static const double _categoryCardHeight = 148;

  TextStyle _sectionHeadingStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
          letterSpacing: -0.25,
        );
  }

  /// Horizontal category chips for the home / search results.
  Widget _buildCategorySlider({
    required int itemCount,
    required Widget Function(BuildContext context, int index) itemBuilder,
  }) {
    return SizedBox(
      height: _categorySliderHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: AppTheme.spacingMd),
        itemBuilder: itemBuilder,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final servicesState = ref.watch(servicesProvider);
    final techniciansState = ref.watch(techniciansProvider);
    final user = ref.watch(currentUserProvider);
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Sticky top bar
            SliverAppBar(
              pinned: true,
              floating: false,
              backgroundColor: AppTheme.background,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              toolbarHeight: 60,
              flexibleSpace: FlexibleSpaceBar(
                background: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                    child: Row(
                      children: [
                        // Hamburger
                        GestureDetector(
                          onTap: () => DrawerOpener.open(context),
                          child: Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              boxShadow: AppTheme.shadowSm,
                              border: Border.all(color: AppTheme.hairline),
                            ),
                            child: const Icon(Icons.menu_rounded, color: AppTheme.textPrimary, size: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Hello, ${user?.firstName ?? 'there'}! 👋',
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                              const Text('Find a Service', style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        _buildBellButton(context, ref),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Content header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppTheme.spacingLg, AppTheme.spacingSm, AppTheme.spacingLg, AppTheme.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What service do\nyou need?',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    Container(
                      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusLg), boxShadow: AppTheme.shadowSm),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                            ref.read(servicesProvider.notifier).search(value);
                            ref.read(techniciansProvider.notifier).search(value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search for services...',
                          hintStyle: TextStyle(color: AppTheme.textTertiary),
                          prefixIcon: Icon(Icons.search, color: AppTheme.textTertiary),
                          suffixIcon: servicesState.searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close, color: AppTheme.textTertiary, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    ref.read(servicesProvider.notifier).search('');
                                    ref.read(techniciansProvider.notifier).search('');
                                  },
                                )
                              : Container(
                                  margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                                  child: const Icon(Icons.tune, color: Colors.white, size: 18),
                                ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(AppTheme.spacingMd),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (servicesState.isLoading)
              const SliverToBoxAdapter(
                child: Center(child: Padding(
                  padding: EdgeInsets.all(AppTheme.spacingLg),
                  child: CircularProgressIndicator(),
                )),
              )

            // ── SEARCH ACTIVE ─────────────────────────────────────────────
            else if (servicesState.searchQuery.isNotEmpty) ...[

              // No results at all
              if (servicesState.categories.isEmpty && techniciansState.technicians.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg, vertical: AppTheme.spacingXl),
                    child: Column(
                      children: [
                        Container(
                          width: 64, height: 64,
                          decoration: BoxDecoration(color: AppTheme.pastelBlue, borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
                          child: const Icon(Icons.search_off_rounded, size: 32, color: AppTheme.primaryColor),
                        ),
                        const SizedBox(height: AppTheme.spacingMd),
                        const Text('No results found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                        const SizedBox(height: AppTheme.spacingSm),
                        Text('Try a different keyword', style: TextStyle(fontSize: 13, color: AppTheme.textTertiary)),
                      ],
                    ),
                  ),
                ),

              // Matched categories
              if (servicesState.categories.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppTheme.spacingLg, 0, AppTheme.spacingLg, AppTheme.spacingMd),
                    child: Row(
                      children: [
                        Text('Categories', style: _sectionHeadingStyle(context)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
                          child: Text('${servicesState.categories.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildCategorySlider(
                    itemCount: servicesState.categories.length,
                    itemBuilder: (context, index) {
                      final cat = servicesState.categories[index];
                      final colors = _colorsForIndex(index);
                      return SizedBox(
                        width: _categoryTileWidth,
                        child: _buildCategoryCard(
                          name: cat.name,
                          description: cat.description,
                          icon: _iconForCategory(cat.name),
                          bgColor: colors[0],
                          iconColor: colors[1],
                          count: cat.serviceCount,
                          onTap: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => CategoryTechniciansScreen(categoryName: cat.name, serviceId: cat.id),
                          )),
                        ),
                      );
                    },
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingLg)),
              ],

              // Matched technicians
              if (techniciansState.technicians.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppTheme.spacingLg, 0, AppTheme.spacingLg, AppTheme.spacingMd),
                    child: Row(
                      children: [
                        Text('Technicians', style: _sectionHeadingStyle(context)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
                          child: Text('${techniciansState.technicians.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(color: AppTheme.surface, boxShadow: AppTheme.shadowSm),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (int i = 0; i < techniciansState.technicians.length; i++)
                          ...[
                            _buildTechnicianCard(techniciansState.technicians[i], i),
                            if (i < techniciansState.technicians.length - 1)
                              const Divider(height: 1, thickness: 1, indent: 76, color: AppTheme.hairline),
                          ],
                      ],
                    ),
                  ),
                ),
              ],
            ]

            // ── NO QUERY: show all categories ────────────────────────────
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                  child: Text('Categories', style: _sectionHeadingStyle(context)),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingMd)),
              if (servicesState.categories.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildCategorySlider(
                    itemCount: servicesState.categories.length,
                    itemBuilder: (context, index) {
                      final cat = servicesState.categories[index];
                      final colors = _colorsForIndex(index);
                      return SizedBox(
                        width: _categoryTileWidth,
                        child: _buildCategoryCard(
                          name: cat.name,
                          description: cat.description,
                          icon: _iconForCategory(cat.name),
                          bgColor: colors[0],
                          iconColor: colors[1],
                          count: cat.serviceCount,
                          onTap: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => CategoryTechniciansScreen(categoryName: cat.name, serviceId: cat.id),
                          )),
                        ),
                      );
                    },
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: _buildCategorySlider(
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      final fallbacks = [
                        ('Plumbing', 'Leaks, pipes', Icons.water_damage_outlined),
                        ('Electrical', 'Wiring, outlets', Icons.electrical_services_outlined),
                        ('Cleaning', 'Deep clean', Icons.cleaning_services_outlined),
                        ('AC Repair', 'Installation', Icons.ac_unit_outlined),
                        ('Appliances', 'Fridge, washer', Icons.kitchen_outlined),
                        ('Carpentry', 'Furniture, doors', Icons.handyman_outlined),
                      ];
                      final f = fallbacks[index];
                      final colors = _colorsForIndex(index);
                      return SizedBox(
                        width: _categoryTileWidth,
                        child: _buildCategoryCard(
                          name: f.$1,
                          description: f.$2,
                          icon: f.$3,
                          bgColor: colors[0],
                          iconColor: colors[1],
                          count: 0,
                          onTap: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => CategoryTechniciansScreen(categoryName: f.$1),
                          )),
                        ),
                      );
                    },
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingLg)),

              // Top Technicians
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                  child: Text('Top Technicians', style: _sectionHeadingStyle(context)),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingMd)),
              if (techniciansState.isLoading)
                const SliverToBoxAdapter(
                  child: Center(child: Padding(
                    padding: EdgeInsets.all(AppTheme.spacingLg),
                    child: CircularProgressIndicator(),
                  )),
                )
              else if (techniciansState.technicians.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                    child: Text('No technicians available yet', style: TextStyle(color: AppTheme.textTertiary)),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Builder(builder: (context) {
                    final count = techniciansState.technicians.length > 5 ? 5 : techniciansState.technicians.length;
                    return Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        boxShadow: AppTheme.shadowSm,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          for (int i = 0; i < count; i++)
                            ...[  
                              _buildTechnicianCard(techniciansState.technicians[i], i),
                              if (i < count - 1)
                                const Divider(height: 1, thickness: 1, indent: 76, color: AppTheme.hairline),
                            ],
                        ],
                      ),
                    );
                  }),
                ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingLg)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required String name,
    required String description,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required int count,
    VoidCallback? onTap,
  }) {
    final radius = AppTheme.radiusLg;
    return SoftCard(
      onTap: onTap,
      height: _categoryCardHeight,
      padding: EdgeInsets.zero,
      borderColor: AppTheme.hairline.withValues(alpha: 0.85),
      backgroundColor: AppTheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(radius),
                topRight: Radius.circular(radius),
              ),
              gradient: LinearGradient(
                colors: [
                  iconColor.withValues(alpha: 0.75),
                  AppTheme.primaryColor,
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.hairline.withValues(alpha: 0.7)),
                        ),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(icon, color: iconColor, size: 22),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: AppTheme.textMuted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.1,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                          height: 1.25,
                        ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Text(
                        '$count ${count == 1 ? 'service' : 'services'}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryDark,
                          letterSpacing: 0.15,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Circular avatar: technician's linked user profile photo when available.
  Widget _technicianAvatar(TechnicianModel tech, List<Color> colors) {
    final url = tech.user?.avatar?.trim();
    final hasPhoto = url != null && url.isNotEmpty;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.hairline.withValues(alpha: 0.85)),
        boxShadow: AppTheme.shadowSm,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasPhoto
          ? Image.network(
              url,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _technicianInitialsFallback(tech, colors),
            )
          : _technicianInitialsFallback(tech, colors),
    );
  }

  Widget _technicianInitialsFallback(TechnicianModel tech, List<Color> colors) {
    return ColoredBox(
      color: colors[0],
      child: Center(
        child: Text(
          tech.initials,
          style: TextStyle(color: colors[1], fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTechnicianCard(TechnicianModel tech, int index) {
    final colors = _colorsForIndex(index);
    final name = tech.fullName;
    final rating = tech.rating ?? 0.0;
    final reviews = tech.reviewCount ?? 0;
    final service = tech.specialization ?? tech.services?.firstOrNull?.name ?? 'Technician';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CreateBookingScreen(technician: tech))),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Row(
        children: [
          _technicianAvatar(tech, colors),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text(service, style: TextStyle(fontSize: 13, color: AppTheme.textTertiary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: AppTheme.warning, size: 16),
                    const SizedBox(width: 4),
                    Text(rating.toStringAsFixed(1), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    Text(' ($reviews)', style: TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  final userId = tech.user?.id ?? tech.userId;
                  if (userId.isEmpty) return;
                  Navigator.push(context, MaterialPageRoute(
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
                  child: const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppTheme.primaryColor),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: AppTheme.primaryGradient),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateBookingScreen(technician: tech),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: const Text('Book', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
          ),
        ),
      ),
    );
  }

  Widget _buildBellButton(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(notificationsProvider).unreadCount;
    return GestureDetector(
      onTap: () {
        ref.read(notificationsProvider.notifier).load();
        Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              boxShadow: AppTheme.shadowSm,
            ),
            child: const Icon(Icons.notifications_outlined, color: AppTheme.textPrimary, size: 22),
          ),
          if (unread > 0)
            Positioned(
              right: -4, top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  unread > 99 ? '99+' : unread.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
