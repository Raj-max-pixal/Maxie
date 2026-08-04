import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/config/app_state.dart';

abstract interface class ConnectivityService {
  bool get isOffline;
  void setOffline({required bool value});
}

class RiverpodConnectivityService implements ConnectivityService {
  const RiverpodConnectivityService(this.ref);

  final Ref ref;

  @override
  bool get isOffline => ref.read(offlineProvider);

  @override
  void setOffline({required bool value}) {
    ref.read(offlineProvider.notifier).state = value;
  }
}

final connectivityServiceProvider = Provider<ConnectivityService>(
  RiverpodConnectivityService.new,
);
