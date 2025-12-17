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
