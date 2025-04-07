import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:subtil_app/services/notifs_service.dart';
import 'package:subtil_app/services/various_service.dart';
import 'package:subtil_app/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:subtil_app/l10n/app_localizations.dart';

final notifications = Notifications();

class MapScreen extends StatefulWidget {
  final bool isRegistration;
  final LatLng location;
  final int searchDist;
  final Function(LatLng, int) callback;

  const MapScreen(
      {super.key,
      required this.isRegistration,
      required this.location,
      required this.searchDist,
      required this.callback});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with AutomaticKeepAliveClientMixin {
  late bool isRegistration;
  late LatLng location;
  late int searchDist;

  MapController mapController = MapController();
  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.low,
  );

  late Position currentLoc;

  Future<bool> _handlePermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final permissionRequest = await Geolocator.requestPermission();
      return permissionRequest == LocationPermission.whileInUse ||
          permissionRequest == LocationPermission.always;
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  void moveToCurrentLoc() async {
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      showSnackBarBad(context,
          content: AppLocalizations.of(context)!.unableToGetLocation);
      return;
    }

    final hasPermission = await _handlePermission();
    if (!hasPermission) return;

    try {
      final currentLoc = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings);
      if (mounted) {
        setState(() {
          location = LatLng(currentLoc.latitude, currentLoc.longitude);
        });
      }

      // Déplacer la carte
      mapController.move(location, mapController.camera.zoom);
    } catch (e) {
      showSnackBarBad(context,
          content: AppLocalizations.of(context)!.unableToGetLocation);
    }
  }

  @override
  void initState() {
    isRegistration = widget.isRegistration;
    location = widget.location;
    searchDist = widget.searchDist;

    moveToCurrentLoc();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !isRegistration
          ? AppBar(
              title: Text(
                AppLocalizations.of(context)!.edit,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_outlined),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      body: Center(
        child: Column(
          // Localisation
          children: [
            Text(
              AppLocalizations.of(context)!.whereAreYou,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            Expanded(
              child: Stack(children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                      onTap: (tapPosition, point) {
                        setState(() {
                          location = point;
                        });

                        if (isRegistration)
                          widget.callback(location, searchDist);
                      },
                      initialCenter: location,
                      initialZoom: calculInitalZoomMap(
                          MediaQuery.of(context).size.width, searchDist * 1000),
                      minZoom: 1,
                      maxZoom: 20),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'fr.aube33.matcher',
                    ),
                    CircleLayer(circles: [
                      CircleMarker(
                        point: location,
                        radius: searchDist * 1000,
                        useRadiusInMeter: true,
                        color: AppColors.pink.withOpacity(0.3),
                        borderColor: Colors.red.withOpacity(0.7),
                        borderStrokeWidth: 2,
                      )
                    ]),
                    MarkerLayer(markers: [
                      Marker(
                        width: 40.0,
                        height: 40.0,
                        point: location,
                        child: const Icon(
                          Icons.location_on,
                          color: AppColors.darkBlue,
                        ),
                      )
                    ]),
                    RichAttributionWidget(
                      animationConfig: const ScaleRAWA(),
                      attributions: [
                        TextSourceAttribution(
                          'OpenStreetMap contributors',
                          onTap: () => launchUrl(
                              Uri.parse('https://openstreetmap.org/copyright')),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  bottom: isRegistration ? 50 : 115,
                  right: 20,
                  child: FloatingActionButton(
                    heroTag: 'btn1',
                    onPressed: () async {
                      moveToCurrentLoc();

                      if (isRegistration) widget.callback(location, searchDist);
                    },
                    child: const Icon(Icons.gps_fixed),
                  ),
                ),
                if (!isRegistration)
                  Positioned(
                    bottom: 50,
                    right: 20,
                    child: FloatingActionButton(
                      heroTag: 'btn2',
                      onPressed: () {
                        widget.callback(location, searchDist);
                      },
                      child: const Icon(Icons.check),
                    ),
                  ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Text(
                AppLocalizations.of(context)!.yourSearchDistance,
                style: Theme.of(context)
                    .textTheme
                    .displaySmall!
                    .copyWith(height: 0),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: 20, right: 20, bottom: isRegistration ? 80 : 20),
              child: Slider(
                value: fromExponential(searchDist.toDouble()),
                min: minSliderValue,
                max: maxSliderValue,
                divisions: 500,
                label: '$searchDist km',
                onChanged: (double value) {
                  final oldSearchDist = searchDist;
                  setState(() {
                    searchDist = toExponential(value).round();
                  });

                  if (oldSearchDist < searchDist)
                    mapController.move(
                        location,
                        calculInitalZoomMap(MediaQuery.of(context).size.width,
                            searchDist * 1000));

                  if (isRegistration) widget.callback(location, searchDist);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
