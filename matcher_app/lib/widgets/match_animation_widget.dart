import 'package:flutter/material.dart';
import 'package:subtil_app/main.dart';
import 'package:subtil_app/services/api_service.dart';
import 'package:subtil_app/widgets/constants.dart';
import 'package:subtil_app/l10n/app_localizations.dart';

class MatchAnimation extends StatefulWidget {
  final String matchUid;
  final VoidCallback onClose; // Callback pour fermer l'overlay
  const MatchAnimation(
      {super.key, required this.matchUid, required this.onClose});

  @override
  _MatchAnimationState createState() =>
      _MatchAnimationState(matchUid: matchUid, onClose: onClose);
}

class _MatchAnimationState extends State<MatchAnimation>
    with SingleTickerProviderStateMixin {
  final String matchUid;
  final VoidCallback onClose;

  _MatchAnimationState({required this.matchUid, required this.onClose});

  late AnimationController _controller;
  late Animation<double> _zoomAnimationNouveau;
  late Animation<double> _zoomAnimationMatch;

  late Future<Map<String, Image>> _matchProfilePicture;
  late Future<Map<String, dynamic>> _matchProfile;

  @override
  void initState() {
    super.initState();

    _matchProfilePicture = fetchImages(matchUid, withProfilePicture: true);
    _matchProfile = getUserData(matchUid);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _zoomAnimationNouveau = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutExpo),
    );

    _zoomAnimationMatch = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 0.7, curve: Curves.easeOutExpo),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.8),
        body: Stack(
          children: [
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.scale(
                        scale: _zoomAnimationNouveau.value,
                        child: Text(
                          AppLocalizations.of(context)!.newLabel,
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge!
                              .copyWith(
                                fontSize: 40,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Transform.scale(
                        scale: _zoomAnimationMatch.value,
                        child: Text(
                          AppLocalizations.of(context)!.match,
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge!
                              .copyWith(
                                fontSize: 65,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Transform.scale(
                        scale: _zoomAnimationMatch.value,
                        child: FutureBuilder(
                          future: _matchProfilePicture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const ShimmerProfilePictureLoadingImage();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              Map<String, Image>? userImages = snapshot.data;
                              if (userImages!.isNotEmpty) {
                                return CircleAvatar(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.onSurface,
                                  radius: 80,
                                  backgroundImage: userImages["profile"]!.image,
                                );
                              } else {
                                return Text(AppLocalizations.of(context)!
                                    .imageUnavailable);
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Transform.scale(
                        scale: _zoomAnimationMatch.value,
                        child: FutureBuilder(
                          future: _matchProfile,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text(
                                "",
                                style:
                                    Theme.of(context).textTheme.displayMedium,
                              );
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              Map<String, dynamic>? userData = snapshot.data;
                              if (userData!.isNotEmpty) {
                                return Text(
                                  userData["name"],
                                  style:
                                      Theme.of(context).textTheme.displayMedium,
                                );
                              } else {
                                return Text(AppLocalizations.of(context)!
                                    .nameUnavailable);
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.tapToClose,
                  style: const TextStyle(
                    color: AppColors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showMatchAnimOverlay(String uid) {
  final BuildContext? context = navigatorKey.currentState?.overlay?.context;

  if (context != null) {
    final overlay = navigatorKey.currentState!.overlay;
    if (overlay != null) {
      late OverlayEntry overlayEntry;

      overlayEntry = OverlayEntry(
        builder: (context) => MatchAnimation(
          matchUid: uid,
          onClose: () {
            overlayEntry.remove();
          },
        ),
      );

      overlay.insert(overlayEntry);
    } else {
      print("Overlay is not available in this context.");
    }
  } else {
    print("Navigator context is null.");
  }
}
