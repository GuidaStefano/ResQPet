import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:resqpet/controllers/segnalazioni_controller.dart';
import 'package:resqpet/core/utils/constants.dart';
import 'package:resqpet/core/utils/functions.dart';
import 'package:resqpet/router.dart';
import 'package:resqpet/theme.dart';


class SegnalazioniMapScreen extends ConsumerStatefulWidget {

  const SegnalazioniMapScreen({super.key});

  @override
  ConsumerState<SegnalazioniMapScreen> createState() {
    return _SegnalazioniMapScreenState();
  }
}

class _SegnalazioniMapScreenState extends ConsumerState<SegnalazioniMapScreen> {

  static const double initialZoom = 10;
  static const double maxZoom = 16;
  static const double minZoom = 4;
  bool _isLoading = false;

  late final MapController _mapController;

  LatLng _currentLatLng = italyCoordinates;

  @override
  void initState() {
    super.initState();

    _mapController = MapController();
    _centerMap(context);
  }

  @override
  void dispose() {
    super.dispose();

    _mapController.dispose();
  }

  Color _getRandomColor() {
    final Random random = Random();
    return Color.fromARGB(
      255, // Alpha (opacity)
      random.nextInt(256), // Red
      random.nextInt(256), // Green
      random.nextInt(256), // Blue
    );
  }

  Future<void> _centerMap(BuildContext context) async {

    setState(() {
      _isLoading = true;
    });

    final latlang = await getCurrentLocation(context);
    setState(() {
      _currentLatLng = latlang;
      _isLoading = false;
    });

    _mapController.move(_currentLatLng, initialZoom);
  }

  @override
  Widget build(BuildContext context) {

    final segnalazioniVicine = ref.watch(segnalazioniVicineProvider(_currentLatLng));

    return Scaffold(
      appBar: AppBar(
        title: Text("Mapp Segnalazioni"),
      ),
      body: Stack(
        children: [
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
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    borderColor: Colors.blueAccent,
                    color: Colors.blue.withAlpha(50),
                    borderStrokeWidth: 2,
                    point: _currentLatLng,
                    radius: distanceKm * 1000,
                    useRadiusInMeter: true,
                  ),
                ],
              ),
              segnalazioniVicine.whenOrNull(
                data: (segnalazioni) {

                  final markers = segnalazioni.map((segnalazione) {

                    return Marker(
                      point: LatLng(
                        segnalazione.posizione.latitude,
                        segnalazione.posizione.longitude
                      ),
                      width: 80, // Increased size
                      height: 80,
                      child: IconButton(
                        onPressed: () {
                          context.pushNamed(
                            Routes.segnalazione.name, 
                            extra: {
                              'segnalazione': segnalazione,
                              'isEnte': false,
                              'isCittadino': false
                            }
                          );
                        },
                        icon: Icon(
                          Icons.pets_outlined,
                          size: 30,
                          color: _getRandomColor(),
                        )
                      )
                    );
                  })
                  .toList();

                  return MarkerLayer(
                    markers: markers
                  );
                },
              ) 
              ?? MarkerLayer(markers: [])
            ]
          ),
          if(_isLoading) Align(
            alignment: AlignmentGeometry.center,
            child: Container(
              decoration: BoxDecoration(
                color: ResQPetColors.onBackground.withAlpha(150),
                borderRadius: BorderRadius.circular(20)
              ),
              padding: EdgeInsets.all(20),
              child: const CircularProgressIndicator(),
            ),
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
                    backgroundColor: ResQPetColors.primaryDark,
                    onPressed: () => _centerMap(context),
                    child: Icon(Icons.my_location_rounded),
                  )
                ],
              ),
            )
          ),
        ],
      )
    );
  }
}