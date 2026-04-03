import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/plot.dart';
import 'service_providers.dart';

final plotsProvider = FutureProvider<List<Plot>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.getPlots();
});
