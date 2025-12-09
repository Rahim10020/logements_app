import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';

/// Widget de carte OpenStreetMap
class MapWidget extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final String? address;

  const MapWidget({
    super.key,
    this.latitude,
    this.longitude,
    this.address,
  });

  @override
  Widget build(BuildContext context) {
    // Si pas de coordonnées, afficher un placeholder
    if (latitude == null || longitude == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8),
              Text(
                'Localisation non disponible',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      clipBehavior: Clip.hardEdge,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(latitude!, longitude!),
          initialZoom: 15.0,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
        ),
        children: [
          // Tuiles OpenStreetMap
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.Ahoe.app',
          ),
          // Marqueur de position
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(latitude!, longitude!),
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
