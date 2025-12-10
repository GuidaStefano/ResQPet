/// Enum representing the status of an announcement.
enum StatoAnnuncio {
  attivo('ATTIVO'),
  inAttesa('IN_ATTESA'),
  concluso('CONCLUSO'),
  scaduto('SCADUTO'),
  sospeso('SOSPESO');

  final String value;
  const StatoAnnuncio(this.value);

  /// Converts a string value to StatoAnnuncio enum.
  /// Throws ArgumentError if the value is not recognized.
  static StatoAnnuncio fromString(String value) {
    return StatoAnnuncio.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => throw ArgumentError('Invalid StatoAnnuncio: $value'),
    );
  }

  /// Converts the enum to its string representation for Firestore.
  String toFirestore() => value;
}
