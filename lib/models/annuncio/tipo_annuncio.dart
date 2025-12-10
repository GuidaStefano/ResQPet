/// Enum representing the type of announcement.
/// Used to differentiate between sale and adoption announcements.
enum TipoAnnuncio {
  vendita('VENDITA'),
  adozione('ADOZIONE');

  final String value;
  const TipoAnnuncio(this.value);

  /// Converts a string value to TipoAnnuncio enum.
  /// Throws ArgumentError if the value is not recognized.
  static TipoAnnuncio fromString(String value) {
    return TipoAnnuncio.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => throw ArgumentError('Invalid TipoAnnuncio: $value'),
    );
  }

  /// Converts the enum to its string representation for Firestore.
  String toFirestore() => value;
}
