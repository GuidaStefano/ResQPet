import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:resqpet/core/utils/snackbar.dart';
import 'package:resqpet/theme.dart';


class SegnalazioniMapScreen extends ConsumerStatefulWidget {

  const SegnalazioniMapScreen({super.key});

  @override
  ConsumerState<SegnalazioniMapScreen> createState() {
    return _SegnalazioniMapScreenState();
  }
}

class _SegnalazioniMapScreenState extends ConsumerState<SegnalazioniMapScreen> {

  static const double initialZoom = 6.0;
  static const double maxZoom = 16;
  static const double minZoom = 4;
  static const LatLng italyCoordinates = LatLng(41.8719, 12.5674);

  late final MapController _mapController;
  bool isLoading = true;
  double _zoomLevel = initialZoom;

  LatLng _currentLatLng = italyCoordinates;

  @override
  void initState() {
    super.initState();

    _mapController = MapController();
    _getCurrentLocation(context);
  }

  @override
  void dispose() {
    super.dispose();

    _mapController.dispose();
  }

  void zoomIn() {

    if(_zoomLevel == maxZoom) {
      return;
    }

    _zoomLevel++;
    _mapController.move(_currentLatLng, _zoomLevel);
  }

  void zoomOut() {

    if(_zoomLevel == minZoom) {
      return;
    }

    _zoomLevel--;
    _mapController.move(_currentLatLng, _zoomLevel);
  }

  Future<void> _getCurrentLocation(BuildContext context) async {

    LocationPermission permission = await Geolocator.checkPermission();
    
    if(permission == LocationPermission.deniedForever) {

      if(!context.mounted) return;

      ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: const Text(
              'I permessi di posizione sono negati permanentemente. Abilitali nelle impostazioni per centrare la mappa.'
            ),
            showCloseIcon: true,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'IMPOSTAZIONI',
              onPressed: () {
                Geolocator.openAppSettings();
              },
            ),
          )
        );
    }
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition();

      setState(() {
        _currentLatLng = LatLng(position.latitude, position.longitude);
      });

      _mapController.move(_currentLatLng, _zoomLevel);
    } else {
      if(!context.mounted) return;
      showErrorSnackBar(context, "Permesso negato, impossibile centrare la mappa.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mapp Segnalazioni"),
      ),
      body: Stack(
        children: [
          if(isLoading) Align(
            alignment: AlignmentGeometry.center,
            child: const CircularProgressIndicator(),
          ),
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLatLng,
              initialZoom: initialZoom,
              minZoom: minZoom,
              maxZoom: maxZoom
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.resqpet.app',
              )
            ]
          ),
          Align(
            alignment: AlignmentGeometry.bottomRight,
            child: Padding(
              padding: EdgeInsetsGeometry.all(10),
              child:  Column(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 10,
                children: [
                  FloatingActionButton(
                    mini: true,
                    onPressed: () => zoomIn(),
                    child: Icon(Icons.zoom_in),
                  ),
                  FloatingActionButton(
                    mini: true,
                    onPressed: () => zoomOut(),
                    child: Icon(Icons.zoom_out),
                  ),
                  FloatingActionButton(
                    backgroundColor: ResQPetColors.primaryDark,
                    onPressed: () => _getCurrentLocation(context),
                    child: Icon(Icons.my_location_rounded),
                  )
                ],
              ),
            )
          )
        ],
      )
    );
  }
}

@Preview(name: "Mappa Segnalazioni", size: Size(400, 700))
Widget mappaSegnalazioni() {
  return MaterialApp(
    theme: resqpetTheme,
    home: SegnalazioniMapScreen(),
  );
}