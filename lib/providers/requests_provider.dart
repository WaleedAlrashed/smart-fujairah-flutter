import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_request.dart';
import 'service_providers.dart';

final myRequestsProvider =
    AsyncNotifierProvider<MyRequestsNotifier, List<ServiceRequest>>(
  MyRequestsNotifier.new,
);

class MyRequestsNotifier extends AsyncNotifier<List<ServiceRequest>> {
  @override
  Future<List<ServiceRequest>> build() => _fetch();

  Future<List<ServiceRequest>> _fetch() async {
    final api = ref.read(apiServiceProvider);
    return api.getMyRequests();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}
