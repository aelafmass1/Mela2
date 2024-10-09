getLocation() async {
  // Check if location services are enabled
  // bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  // if (!serviceEnabled) {
  //   return null;
  // }

  // Check for location permissions
  // LocationPermission permission = await Geolocator.checkPermission();
  // if (permission == LocationPermission.denied) {
  //   permission = await Geolocator.requestPermission();
  //   if (permission == LocationPermission.denied) {
  //     return null;
  //   }
  // }

  // if (permission == LocationPermission.deniedForever) {
  //   return null;
  // }

  // // Get the location
  // Position position = await Geolocator.getCurrentPosition();
  // return position;
  return null;
}
