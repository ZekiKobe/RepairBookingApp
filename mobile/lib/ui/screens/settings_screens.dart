import 'package:flutter/material.dart';
import '../../ui/themes/app_theme.dart';

// ─── Address model ─────────────────────────────────────────────────────────────
class _AddressItem {
  final String label;
  final String address;
  _AddressItem({required this.label, required this.address});
}

// ─── My Addresses ──────────────────────────────────────────────────────────────
class MyAddressesScreen extends StatefulWidget {
  const MyAddressesScreen({super.key});

  @override
  State<MyAddressesScreen> createState() => _MyAddressesScreenState();
}

class _MyAddressesScreenState extends State<MyAddressesScreen> {
  final List<_AddressItem> _addresses = [];

  void _showAddSheet() {
    final labelCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: AppTheme.spacingLg, right: AppTheme.spacingLg,
          top: AppTheme.spacingLg,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + AppTheme.spacingLg,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: AppTheme.pastelBlue, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                    child: const Icon(Icons.location_on_outlined, color: AppTheme.info, size: 20),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Text('Add Address', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close, color: AppTheme.textTertiary)),
                ],
              ),
              const SizedBox(height: AppTheme.spacingLg),
              _sheetField(controller: labelCtrl, label: 'Label (e.g. Home, Work)', icon: Icons.label_outline,
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
              const SizedBox(height: AppTheme.spacingMd),
              _sheetField(controller: addressCtrl, label: 'Full Address', icon: Icons.home_outlined,
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null, maxLines: 2),
              const SizedBox(height: AppTheme.spacingXl),
              SoftGradientButton(
                text: 'Save Address',
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    setState(() => _addresses.add(_AddressItem(
                      label: labelCtrl.text.trim(),
                      address: addressCtrl.text.trim(),
                    )));
                    Navigator.pop(ctx);
                  }
                },
              ),
              const SizedBox(height: AppTheme.spacingSm),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteAddress(int index) {
    showConfirmModal(
      context,
      title: 'Delete Address',
      message: 'Remove "${_addresses[index].label}" from your saved addresses?',
      confirmLabel: 'Delete',
      icon: Icons.location_off_outlined,
      iconColor: AppTheme.error,
    ).then((confirmed) {
      if (confirmed) setState(() => _addresses.removeAt(index));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, 'My Addresses', Icons.location_on_outlined),
            Expanded(
              child: _addresses.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spacing2xl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(color: AppTheme.pastelBlue, borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
                              child: const Icon(Icons.location_on_outlined, size: 40, color: AppTheme.info),
                            ),
                            const SizedBox(height: AppTheme.spacingLg),
                            const Text('No saved addresses yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                            const SizedBox(height: AppTheme.spacingSm),
                            const Text('Add your home, work or other addresses\nfor faster booking', style: TextStyle(fontSize: 14, color: AppTheme.textTertiary), textAlign: TextAlign.center),
                            const SizedBox(height: AppTheme.spacingXl),
                            SoftGradientButton(text: 'Add Address', onPressed: _showAddSheet, width: 220),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppTheme.spacingLg),
                      itemCount: _addresses.length + 1,
                      itemBuilder: (ctx, i) {
                        if (i == _addresses.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: AppTheme.spacingMd),
                            child: SoftGradientButton(text: '+ Add Another Address', onPressed: _showAddSheet),
                          );
                        }
                        final item = _addresses[i];
                        final icons = [Icons.home_outlined, Icons.work_outline, Icons.location_on_outlined];
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                          padding: const EdgeInsets.all(AppTheme.spacingMd),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            boxShadow: AppTheme.shadowSm,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(color: AppTheme.pastelBlue, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                                child: Icon(icons[i % icons.length], color: AppTheme.info, size: 22),
                              ),
                              const SizedBox(width: AppTheme.spacingMd),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                                    const SizedBox(height: 3),
                                    Text(item.address, style: const TextStyle(fontSize: 13, color: AppTheme.textTertiary), maxLines: 2, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppTheme.error, size: 20),
                                onPressed: () => _deleteAddress(i),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Payment method model ───────────────────────────────────────────────────────
class _PaymentItem {
  final String type;
  final String detail;
  _PaymentItem({required this.type, required this.detail});
}

// ─── Payment Methods ───────────────────────────────────────────────────────────
class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<_PaymentItem> _methods = [];
  String _selectedType = 'Cash';

  static const _types = ['Cash', 'Mobile Money', 'Bank Card'];

  static IconData _iconFor(String type) {
    switch (type) {
      case 'Mobile Money': return Icons.phone_android_outlined;
      case 'Bank Card':    return Icons.credit_card_outlined;
      default:             return Icons.payments_outlined;
    }
  }

  static Color _colorFor(String type) {
    switch (type) {
      case 'Mobile Money': return AppTheme.info;
      case 'Bank Card':    return AppTheme.primaryColor;
      default:             return AppTheme.success;
    }
  }

  static Color _bgFor(String type) {
    switch (type) {
      case 'Mobile Money': return AppTheme.pastelBlue;
      case 'Bank Card':    return AppTheme.pastelPurple;
      default:             return AppTheme.pastelGreen;
    }
  }

  void _showAddSheet() {
    final detailCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String sheetType = _selectedType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: AppTheme.spacingLg, right: AppTheme.spacingLg,
            top: AppTheme.spacingLg,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppTheme.spacingLg,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: AppTheme.pastelGreen, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                      child: const Icon(Icons.payment_outlined, color: AppTheme.success, size: 20),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Text('Add Payment Method', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close, color: AppTheme.textTertiary)),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingLg),
                const Text('Payment Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                const SizedBox(height: AppTheme.spacingSm),
                Row(
                  children: _types.map((t) {
                    final selected = sheetType == t;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setSheetState(() { sheetType = t; detailCtrl.clear(); }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selected ? AppTheme.primaryColor : AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
<<<<<<< HEAD
                            border: Border.all(color: selected ? AppTheme.primaryColor : AppTheme.hairline),
=======
                            border: Border.all(color: selected ? AppTheme.primaryColor : const Color(0xFF2C3044)),
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
                          ),
                          child: Column(
                            children: [
                              Icon(_iconFor(t), size: 20, color: selected ? Colors.white : AppTheme.textTertiary),
                              const SizedBox(height: 4),
                              Text(t, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppTheme.textTertiary), textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppTheme.spacingLg),
                if (sheetType != 'Cash') ...[
                  _sheetField(
                    controller: detailCtrl,
                    label: sheetType == 'Mobile Money' ? 'Phone / Account Number' : 'Card Number (last 4 digits)',
                    icon: _iconFor(sheetType),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                ],
                SoftGradientButton(
                  text: 'Save Payment Method',
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      setState(() => _methods.add(_PaymentItem(
                        type: sheetType,
                        detail: sheetType == 'Cash' ? 'Pay on delivery' : detailCtrl.text.trim(),
                      )));
                      Navigator.pop(ctx);
                    }
                  },
                ),
                const SizedBox(height: AppTheme.spacingSm),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteMethod(int index) {
    showConfirmModal(
      context,
      title: 'Remove Payment Method',
      message: 'Remove "${_methods[index].type}" from your payment methods?',
      confirmLabel: 'Remove',
      icon: Icons.credit_card_off_outlined,
      iconColor: AppTheme.error,
    ).then((confirmed) {
      if (confirmed) setState(() => _methods.removeAt(index));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, 'Payment Methods', Icons.payment_outlined),
            Expanded(
              child: _methods.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spacing2xl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(color: AppTheme.pastelGreen, borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
                              child: const Icon(Icons.payment_outlined, size: 40, color: AppTheme.success),
                            ),
                            const SizedBox(height: AppTheme.spacingLg),
                            const Text('No payment methods added', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                            const SizedBox(height: AppTheme.spacingSm),
                            const Text('Add a payment method to make\nbookings faster', style: TextStyle(fontSize: 14, color: AppTheme.textTertiary), textAlign: TextAlign.center),
                            const SizedBox(height: AppTheme.spacingXl),
                            SoftGradientButton(text: 'Add Payment Method', onPressed: _showAddSheet, width: 220),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppTheme.spacingLg),
                      itemCount: _methods.length + 1,
                      itemBuilder: (ctx, i) {
                        if (i == _methods.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: AppTheme.spacingMd),
                            child: SoftGradientButton(text: '+ Add Another Method', onPressed: _showAddSheet),
                          );
                        }
                        final item = _methods[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                          padding: const EdgeInsets.all(AppTheme.spacingMd),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            boxShadow: AppTheme.shadowSm,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(color: _bgFor(item.type), borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                                child: Icon(_iconFor(item.type), color: _colorFor(item.type), size: 22),
                              ),
                              const SizedBox(width: AppTheme.spacingMd),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.type, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                                    const SizedBox(height: 3),
                                    Text(item.detail, style: const TextStyle(fontSize: 13, color: AppTheme.textTertiary)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppTheme.error, size: 20),
                                onPressed: () => _deleteMethod(i),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Notifications ─────────────────────────────────────────────────────────────
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _bookingUpdates = true;
  bool _messages = true;
  bool _promotions = false;
  bool _reminders = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, 'Notifications', Icons.notifications_outlined),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                children: [
                  _buildSectionTitle('Booking Alerts'),
                  _buildToggle('Booking Updates', 'Get notified when your booking status changes', _bookingUpdates, (v) => setState(() => _bookingUpdates = v)),
                  _buildToggle('Reminders', 'Reminders before your scheduled appointments', _reminders, (v) => setState(() => _reminders = v)),
                  const SizedBox(height: AppTheme.spacingLg),
                  _buildSectionTitle('Communication'),
                  _buildToggle('Messages', 'New messages from technicians', _messages, (v) => setState(() => _messages = v)),
                  _buildToggle('Promotions', 'Offers and discounts from the app', _promotions, (v) => setState(() => _promotions = v)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
    );
  }

  Widget _buildToggle(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusLg), boxShadow: AppTheme.shadowSm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: AppTheme.textTertiary)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }
}

// ─── Help & Support ────────────────────────────────────────────────────────────
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, 'Help & Support', Icons.help_outline),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                children: [
                  _buildFaqItem('How do I book a service?', 'Go to the Home tab, browse categories or technicians, and tap "Book" on any technician to schedule a service.'),
                  _buildFaqItem('How do I cancel a booking?', 'Go to Bookings tab, find your pending booking, and tap "Cancel". Cancellations must be made at least 1 hour before the scheduled time.'),
                  _buildFaqItem('How do I contact a technician?', 'Once a booking is accepted, a chat will appear in the Messages tab where you can communicate directly.'),
                  _buildFaqItem('What payment methods are accepted?', 'We accept cash on delivery and mobile payment options. You can manage payment methods in your profile.'),
                  _buildFaqItem('How do I rate a technician?', 'After a booking is completed, you will find a "Review" button in the completed bookings tab.'),
                  const SizedBox(height: AppTheme.spacingLg),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingLg),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: AppTheme.primaryGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.support_agent, color: Colors.white, size: 40),
                        const SizedBox(height: AppTheme.spacingMd),
                        const Text('Still need help?', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text('Contact our support team', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: AppTheme.spacingMd),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
                            child: const Text('Contact Support', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusLg), boxShadow: AppTheme.shadowSm),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(AppTheme.spacingMd, 0, AppTheme.spacingMd, AppTheme.spacingMd),
        title: Text(question, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        iconColor: AppTheme.primaryColor,
        collapsedIconColor: AppTheme.textTertiary,
        children: [Text(answer, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.6))],
      ),
    );
  }
}

// ─── About ─────────────────────────────────────────────────────────────────────
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, 'About', Icons.info_outline),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Column(
                  children: [
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: AppTheme.primaryGradient),
                        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                        boxShadow: AppTheme.shadowMd,
                      ),
                      child: const Icon(Icons.build_circle, color: Colors.white, size: 50),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    const Text('RepairBooking', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    const SizedBox(height: 4),
                    const Text('Version 1.0.0', style: TextStyle(fontSize: 14, color: AppTheme.textTertiary)),
                    const SizedBox(height: AppTheme.spacingXl),
                    _buildInfoCard('About the App', 'RepairBooking connects you with trusted and professional technicians for all your home repair and maintenance needs.'),
                    const SizedBox(height: AppTheme.spacingMd),
                    _buildInfoTile(Icons.privacy_tip_outlined, 'Privacy Policy', AppTheme.pastelBlue, AppTheme.info),
                    _buildInfoTile(Icons.description_outlined, 'Terms of Service', AppTheme.pastelGreen, AppTheme.success),
                    _buildInfoTile(Icons.star_outline, 'Rate the App', AppTheme.pastelYellow, AppTheme.warning),
                    _buildInfoTile(Icons.share_outlined, 'Share the App', AppTheme.pastelOrange, AppTheme.primaryAccent),
                    const SizedBox(height: AppTheme.spacingXl),
                    Text('© 2026 RepairBooking. All rights reserved.', style: TextStyle(fontSize: 12, color: AppTheme.textTertiary), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String body) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusLg), boxShadow: AppTheme.shadowSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, Color bg, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusLg), boxShadow: AppTheme.shadowSm),
      child: Row(
        children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppTheme.radiusMd)), child: Icon(icon, color: iconColor, size: 22)),
          const SizedBox(width: AppTheme.spacingMd),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const Spacer(),
          Icon(Icons.arrow_forward_ios, color: AppTheme.textTertiary, size: 16),
        ],
      ),
    );
  }
}

// ─── Shared Helpers ────────────────────────────────────────────────────────────
Widget _buildHeader(BuildContext context, String title, IconData icon) {
  return Padding(
    padding: const EdgeInsets.all(AppTheme.spacingLg),
    child: Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd), boxShadow: AppTheme.shadowSm),
            child: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary, size: 20),
          ),
        ),
        const SizedBox(width: AppTheme.spacingMd),
        Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

// ─── Shared bottom-sheet field ─────────────────────────────────────────────────
Widget _sheetField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  String? Function(String?)? validator,
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
}) {
  return TextFormField(
    controller: controller,
    validator: validator,
    keyboardType: keyboardType,
    maxLines: maxLines,
    style: const TextStyle(color: AppTheme.textPrimary),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.textTertiary, fontSize: 14),
      prefixIcon: Icon(icon, color: AppTheme.textTertiary, size: 20),
      filled: true,
      fillColor: AppTheme.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
<<<<<<< HEAD
        borderSide: const BorderSide(color: AppTheme.hairline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        borderSide: const BorderSide(color: AppTheme.hairline),
=======
        borderSide: const BorderSide(color: Color(0xFF2C3044)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        borderSide: const BorderSide(color: Color(0xFF2C3044)),
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        borderSide: const BorderSide(color: AppTheme.error),
      ),
    ),
  );
}
