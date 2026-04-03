import 'package:latlong2/latlong.dart';

class Plot {
  final int id;
  final String areaNameEn;
  final String areaNameAr;
  final String plotTypeEn;
  final String plotTypeAr;
  final String plotId;
  final String plotCode;
  final double plotAreaSqm;
  final String blockCode;
  final double centerLat;
  final double centerLng;
  final List<LatLng> polygon;

  const Plot({
    required this.id,
    required this.areaNameEn,
    required this.areaNameAr,
    required this.plotTypeEn,
    required this.plotTypeAr,
    required this.plotId,
    required this.plotCode,
    required this.plotAreaSqm,
    required this.blockCode,
    required this.centerLat,
    required this.centerLng,
    required this.polygon,
  });

  factory Plot.fromJson(Map<String, dynamic> json) => Plot(
        id: json['id'] as int,
        areaNameEn: json['area_name_en'] as String,
        areaNameAr: json['area_name_ar'] as String,
        plotTypeEn: json['plot_type_en'] as String,
        plotTypeAr: json['plot_type_ar'] as String,
        plotId: json['plot_id'] as String,
        plotCode: json['plot_code'] as String,
        plotAreaSqm: (json['plot_area_sqm'] as num).toDouble(),
        blockCode: json['block_code'] as String,
        centerLat: (json['center_lat'] as num).toDouble(),
        centerLng: (json['center_lng'] as num).toDouble(),
        polygon: (json['polygon'] as List)
            .map((coord) {
              final c = coord as List;
              return LatLng(
                (c[1] as num).toDouble(),
                (c[0] as num).toDouble(),
              );
            })
            .toList(),
      );

  LatLng get center => LatLng(centerLat, centerLng);
  String areaName(String locale) => locale == 'ar' ? areaNameAr : areaNameEn;
  String plotType(String locale) => locale == 'ar' ? plotTypeAr : plotTypeEn;
}
