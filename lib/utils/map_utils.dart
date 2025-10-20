// Converts any dynamic map (from Firebase) into Map<String, dynamic>,
// recursively converting nested maps and lists
Map<String, dynamic> convertDynamicMapToStringMap(Map<dynamic, dynamic> map) {
  return map.map((key, value) {
    final k = key.toString();
    final v = value is Map ? convertDynamicMapToStringMap(value) : value;
    return MapEntry(k, v);
  });
}
