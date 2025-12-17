final RegExp italianPhoneRegex = RegExp(r'^(?:\+39[\s.-]?)?(?:3\d{2}|0\d{1,3})(?:[\s.-]?\d){6,7}$');
final RegExp emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
final RegExp min8PasswordRegex = RegExp(r'^.{8,}$');
final RegExp partitaIvaRegex = RegExp(r'^(?:IT)?[0-9]{11}$');
final RegExp sessoRegex = RegExp(r'^(maschio|femmina)$', caseSensitive: false);
final RegExp dataRegex = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$');
final RegExp microchipRegex = RegExp(r'^\d{15}$');