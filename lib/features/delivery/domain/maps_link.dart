/// Enlace de navegación externa. Solo incluye el destino textual.
Uri? deliveryMapsUri(String address) {
  final destination = address.trim();
  if (destination.length < 8 || destination.length > 200) return null;
  if (destination.contains(RegExp(r'[\r\n]'))) return null;
  return Uri.https('www.google.com', '/maps/search/', {
    'api': '1',
    'query': destination,
  });
}
