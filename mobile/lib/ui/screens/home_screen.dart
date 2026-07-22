import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ui/themes/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/messages_provider.dart';
<<<<<<< HEAD
import '../../providers/notifications_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/drawer_opener.dart';
=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
import 'services_screen.dart';
import 'bookings_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';
import 'technician_home_screen.dart';
import 'technician_bookings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  Timer? _unreadTimer;
<<<<<<< HEAD
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739

  // Customer screens
  final List<Widget> _customerScreens = [
    const ServicesScreen(),
    const BookingsScreen(),
    const MessagesScreen(),
    const ProfileScreen(),
  ];

  // Technician screens
  final List<Widget> _technicianScreens = [
    const TechnicianHomeScreen(),
    const TechnicianBookingsScreen(),
    const MessagesScreen(),
    const ProfileScreen(),
  ];

  final List<NavigationItem> _customerNavItems = [
    NavigationItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    NavigationItem(icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today_rounded, label: 'Bookings'),
    NavigationItem(icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble_rounded, label: 'Messages'),
    NavigationItem(icon: Icons.person_outline, activeIcon: Icons.person_rounded, label: 'Profile'),
  ];

  final List<NavigationItem> _technicianNavItems = [
    NavigationItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'Dashboard'),
    NavigationItem(icon: Icons.work_outline, activeIcon: Icons.work_rounded, label: 'My Jobs'),
    NavigationItem(icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble_rounded, label: 'Messages'),
    NavigationItem(icon: Icons.person_outline, activeIcon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    // Load conversations, notifications + unread counts on startup
    Future.microtask(() {
      ref.read(messagesProvider.notifier).loadConversations();
      ref.read(messagesProvider.notifier).loadUnreadCount();
      ref.read(notificationsProvider.notifier).loadUnreadCount();
=======
    // Load conversations + unread count on startup
    Future.microtask(() {
      ref.read(messagesProvider.notifier).loadConversations();
      ref.read(messagesProvider.notifier).loadUnreadCount();
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
    });
    // Refresh unread counts every 15 seconds
    _unreadTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) {
        ref.read(messagesProvider.notifier).loadConversations();
      }
    });
  }

  @override
  void dispose() {
    _unreadTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isTechnician = user?.role == 'technician';
    final screens = isTechnician ? _technicianScreens : _customerScreens;
    final navItems = isTechnician ? _technicianNavItems : _customerNavItems;
    final safeIndex = _currentIndex.clamp(0, screens.length - 1);
    final unreadMessages = ref.watch(messagesProvider).unreadCount;

    return Scaffold(
<<<<<<< HEAD
      key: _scaffoldKey,
      backgroundColor: AppTheme.background,
      drawer: AppDrawer(
        currentIndex: safeIndex,
        onNavTap: (i) => setState(() => _currentIndex = i),
      ),
      body: DrawerOpener(
        scaffoldKey: _scaffoldKey,
        child: screens[safeIndex],
      ),
      bottomNavigationBar: _buildBottomNavBar(navItems, unreadMessages),
    );
  }

  Widget _buildBottomNavBar(List<NavigationItem> navItems, int unreadMessages) {
    return Material(
      color: AppTheme.surface,
      child: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppTheme.hairline, width: 1)),
          ),
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
          child: Row(
            children: List.generate(
              navItems.length,
              (index) => Expanded(child: _buildNavItem(index, navItems, unreadMessages)),
            ),
=======
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          screens[safeIndex],
          Positioned(
            left: 8,
            right: 8,
            bottom: AppTheme.spacingMd,
            child: _buildFloatingNavBar(navItems, unreadMessages),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavBar(List<NavigationItem> navItems, int unreadMessages) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D2E),
        borderRadius: BorderRadius.circular(AppTheme.radius2xl),
        boxShadow: AppTheme.shadowLg,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(
            navItems.length,
            (index) => Expanded(child: _buildNavItem(index, navItems, unreadMessages)),
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, List<NavigationItem> navItems, int unreadMessages) {
    final item = navItems[index];
    final isSelected = _currentIndex == index;
    final isMessages = item.label == 'Messages';

    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        if (isMessages) {
          ref.read(messagesProvider.notifier).loadUnreadCount();
        }
      },
<<<<<<< HEAD
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: AppTheme.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: isSelected ? Colors.white : AppTheme.textTertiary,
                    size: 22,
                  ),
                  if (isMessages && unreadMessages > 0) _badge(unreadMessages),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
=======
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingSm,
          vertical: AppTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? const LinearGradient(
            colors: [Color(0xFF7C6FFF), Color(0xFF4F46E5)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ) : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? item.activeIcon : item.icon,
                  color: Colors.white.withOpacity(isSelected ? 1.0 : 0.6),
                  size: 20,
                ),
                if (isMessages && unreadMessages > 0)
                  _badge(unreadMessages),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  item.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ],
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
        ),
      ),
    );
  }

  Widget _badge(int count) {
    return Positioned(
      right: -6,
      top: -6,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
