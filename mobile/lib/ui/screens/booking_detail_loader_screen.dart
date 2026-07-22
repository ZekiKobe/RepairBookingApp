import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repair_booking/l10n/app_localizations.dart';

import '../../services/booking_service.dart';
import '../../ui/themes/app_theme.dart';
import 'booking_detail_screen.dart';

/// Loads a booking by id (e.g. deep link) then shows [BookingDetailScreen].
class BookingDetailLoaderScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const BookingDetailLoaderScreen({super.key, required this.bookingId});

  @override
  ConsumerState<BookingDetailLoaderScreen> createState() =>
      _BookingDetailLoaderScreenState();
}

class _BookingDetailLoaderScreenState
    extends ConsumerState<BookingDetailLoaderScreen> {
  final _service = BookingService();
  late Future _load;

  @override
  void initState() {
    super.initState();
    _load = _service.getBooking(widget.bookingId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FutureBuilder(
      future: _load,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppTheme.background,
            appBar: AppBar(title: Text(l10n.appTitle)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final res = snapshot.data;
        if (res != null && res.success && res.data != null) {
          return BookingDetailScreen(booking: res.data!);
        }
        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(title: Text(l10n.appTitle)),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.bookingLoadError,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  Semantics(
                    button: true,
                    label: l10n.retry,
                    child: FilledButton(
                      onPressed: () {
                        setState(() {
                          _load = _service.getBooking(widget.bookingId);
                        });
                      },
                      child: Text(l10n.retry),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
