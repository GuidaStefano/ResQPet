import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:resqpet/core/utils/constants.dart';
import 'package:resqpet/core/utils/snackbar.dart';

bool isJPEG(String path) {
  return path.toLowerCase().endsWith(".jpeg") ||
    path.toLowerCase().endsWith(".jpg");
}

bool isLengthBetween(String value, int min, int max) {
  final len = value.trim().length;
  return len >= min && len <= max;
}

bool isValidLatitude(double lat) {
  return lat >= -90 && lat <= 90;
}

bool isValidLongitude(double lng) {
  return lng >= -180 && lng <= 180;
}


Future<LatLng> getCurrentLocation(BuildContext context) async {

  LocationPermission permission = await Geolocator.checkPermission();
  
  if(permission == LocationPermission.deniedForever) {

    if(!context.mounted) {
      return italyCoordinates;
    }

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
    return LatLng(position.latitude, position.longitude);
  } else {
    if(context.mounted) {
      showErrorSnackBar(context, "Permesso negato, impossibile centrare la mappa.");
    }
  }

  return italyCoordinates;
}

Future<XFile> pickImage(BuildContext context, { bool fromCamera = false}) async {
  final ImagePicker picker = ImagePicker();

  final XFile? image = await picker.pickImage(
    source: fromCamera ? ImageSource.camera : ImageSource.gallery
  );

  if(image == null) {
    throw StateError("Impossibile caricare l'immagine");
  }

  return image;
}

String formatDate(DateTime date) {
  return DateFormat('dd/MM/yyyy HH:mm').format(date);
}