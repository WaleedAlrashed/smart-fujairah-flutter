import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service.dart';
import 'service_providers.dart';

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

final searchResultsProvider = FutureProvider<List<MunicipalityService>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().length < 2) return [];

  final api = ref.read(apiServiceProvider);
  return api.searchServices(query);
});
