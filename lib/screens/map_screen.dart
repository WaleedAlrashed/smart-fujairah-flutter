import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../models/plot.dart';
import '../providers/plots_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  Plot? _selectedPlot;

  // Fujairah Al Owaid center
  static const _fujairahCenter = LatLng(25.1295, 56.3440);

  Color _plotColor(String plotType) => switch (plotType) {
        'Residential' => Colors.green,
        'Commercial' => Colors.blue,
        'Residential-Commercial' => Colors.orange,
        'Government' => Colors.purple,
        'Industrial' => Colors.red,
        _ => Colors.amber,
      };

  @override
  Widget build(BuildContext context) {
    final plotsAsync = ref.watch(plotsProvider);
    final theme = Theme.of(context);
    final locale = context.locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text('land_map'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () => _mapController.move(_fujairahCenter, 16),
            tooltip: 'Reset view',
          ),
        ],
      ),
      body: plotsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('error_occurred'.tr()),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () => ref.invalidate(plotsProvider),
                child: Text('retry'.tr()),
              ),
            ],
          ),
        ),
        data: (plots) => Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _fujairahCenter,
                initialZoom: 16,
                minZoom: 12,
                maxZoom: 19,
                onTap: (_, __) => setState(() => _selectedPlot = null),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'ae.gov.fujmun.smartfujairah',
                ),
                PolygonLayer(
                  polygons: plots.map((plot) {
                    final color = _plotColor(plot.plotTypeEn);
                    final isSelected = _selectedPlot?.id == plot.id;
                    return Polygon(
                      points: plot.polygon,
                      color: isSelected
                          ? color.withAlpha(120)
                          : color.withAlpha(60),
                      borderColor: isSelected ? color : color.withAlpha(180),
                      borderStrokeWidth: isSelected ? 3.0 : 1.5,
                    );
                  }).toList(),
                ),
                // Invisible tap targets using markers at polygon centers
                MarkerLayer(
                  markers: plots.map((plot) => Marker(
                    point: plot.center,
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedPlot = plot);
                        _mapController.move(plot.center, _mapController.camera.zoom);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _plotColor(plot.plotTypeEn).withAlpha(180),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          plot.plotCode,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ),

            // Legend
            Positioned(
              top: 8,
              right: 8,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('legend'.tr(),
                          style: theme.textTheme.labelSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      _LegendItem(color: Colors.green, label: 'residential'.tr()),
                      _LegendItem(color: Colors.blue, label: 'commercial'.tr()),
                      _LegendItem(color: Colors.orange, label: 'mixed_use'.tr()),
                      _LegendItem(color: Colors.purple, label: 'government'.tr()),
                      _LegendItem(color: Colors.red, label: 'industrial'.tr()),
                      _LegendItem(color: Colors.amber, label: 'other'.tr()),
                    ],
                  ),
                ),
              ),
            ),

            // Selected plot bottom sheet
            if (_selectedPlot != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _PlotInfoCard(
                  plot: _selectedPlot!,
                  locale: locale,
                  color: _plotColor(_selectedPlot!.plotTypeEn),
                  onClose: () => setState(() => _selectedPlot = null),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color.withAlpha(100),
              border: Border.all(color: color, width: 1.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _PlotInfoCard extends StatelessWidget {
  final Plot plot;
  final String locale;
  final Color color;
  final VoidCallback onClose;

  const _PlotInfoCard({
    required this.plot,
    required this.locale,
    required this.color,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withAlpha(80)),
                  ),
                  child: Text(
                    plot.plotType(locale),
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onClose,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Area name
            Text(
              plot.areaName(locale),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Details grid
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    icon: Icons.tag,
                    label: 'plot_id_label'.tr(),
                    value: plot.plotId,
                  ),
                ),
                Expanded(
                  child: _InfoTile(
                    icon: Icons.qr_code,
                    label: 'plot_code_label'.tr(),
                    value: plot.plotCode,
                  ),
                ),
                Expanded(
                  child: _InfoTile(
                    icon: Icons.square_foot,
                    label: 'area_sqm'.tr(),
                    value: plot.plotAreaSqm > 0
                        ? '${plot.plotAreaSqm.toStringAsFixed(0)} m\u00B2'
                        : '-',
                  ),
                ),
                Expanded(
                  child: _InfoTile(
                    icon: Icons.grid_view,
                    label: 'block'.tr(),
                    value: plot.blockCode,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        )),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
