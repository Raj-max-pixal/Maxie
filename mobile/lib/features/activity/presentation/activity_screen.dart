import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// PendingNotificationRequest is re-exported by notification_service.dart via
// conditional export — native uses flutter_local_notifications type,
// web uses the local stub in notification_service_web.dart.
import 'package:maxie_mobile/core/services/notification_service.dart';
import 'package:maxie_mobile/widgets/premium_card.dart';
import 'package:maxie_mobile/widgets/premium_scaffold.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late Future<List<PendingNotificationRequest>> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = _load();
  }

  Future<List<PendingNotificationRequest>> _load() async {
    if (kIsWeb) return const [];
    try {
      return await NotificationService().getPendingNotifications();
    } catch (_) {
      return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Activity',
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: () => setState(() => _notifications = _load()),
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      child: FutureBuilder<List<PendingNotificationRequest>>(
        future: _notifications,
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <PendingNotificationRequest>[];
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 108),
            children: [
              Text(
                'Your MAXie activity',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Open an item to see its real details. MAXie never invents activity.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator())
              else if (items.isEmpty)
                PremiumCard(
                  child: Column(
                    children: [
                      const Icon(Icons.notifications_none_rounded, size: 42),
                      const SizedBox(height: 12),
                      Text(
                        'You are all caught up',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        kIsWeb
                            ? 'Android notification activity is available in the installed app, not the browser preview.'
                            : 'Scheduled MAXie reminders will appear here. Cross-app notification access requires separate Android permission.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                for (final item in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: PremiumCard(
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        onTap: () => _showDetails(item),
                        leading: const CircleAvatar(
                          child: Icon(Icons.notifications_active_rounded),
                        ),
                        title: Text(item.title ?? 'MAXie reminder'),
                        subtitle: Text(
                          item.body ?? 'No extra details',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }

  void _showDetails(PendingNotificationRequest item) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title ?? 'MAXie reminder',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Text(item.body ?? 'No extra details were provided.'),
              if (item.payload?.isNotEmpty == true) ...[
                const SizedBox(height: 16),
                Chip(label: Text('Action: ${item.payload}')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
