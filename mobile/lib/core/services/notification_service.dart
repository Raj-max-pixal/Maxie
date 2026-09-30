/// Conditional export: on web targets (dart.library.html available,
/// dart.library.io unavailable) we get the no-op stub; on mobile/desktop
/// (dart.library.io available) we get the real FlutterLocalNotifications impl.
///
/// All callers simply `import 'notification_service.dart'` as before.
export 'notification_service_web.dart'
    if (dart.library.io) 'notification_service_native.dart';