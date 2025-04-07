import 'dart:async';

import 'package:subtil_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:subtil_app/services/api_service.dart';
import 'package:subtil_app/services/user_service.dart';
import 'package:subtil_app/services/various_service.dart';
import 'package:subtil_app/models/user_model.dart';
import 'package:subtil_app/providers/user_provider.dart';
import 'package:subtil_app/widgets/constants.dart';
import 'package:subtil_app/widgets/likesCounter_widget.dart';
import 'package:subtil_app/widgets/profileScroll_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:subtil_app/services/jwt_service.dart';
import 'package:subtil_app/configs/api.configs.dart';

class ScrollsScreen extends StatefulWidget {
  const ScrollsScreen({super.key});

  @override
  _ScrollsScreenState createState() => _ScrollsScreenState();
}

class _ScrollsScreenState extends State<ScrollsScreen> {
  final PageController _pageController = PageController(initialPage: 1);
  late Future<List<dynamic>> _getFlowFuture;
  late final List<Widget> _allWidgets;
  bool _isLoading = false;
  late User currentUser;
  Timer? _refreshTimer;

  void _scrollToNextPage() {
    _pageController.nextPage(
        duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

  @override
  void initState() {
    super.initState();
    _allWidgets = [const TooUpPage()];
    _getFlowFuture = _getFlow(current: true);
    currentUser = Provider.of<UserProvider>(context, listen: false).user!;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!currentUser.hasClaimedDailyLikes) {
        showClaimLikesDialog(context);
      }
    });

    _startShimmerRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startShimmerRefresh() {
    _refreshTimer?.cancel();

    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (timer) async {
      if (_allWidgets.isEmpty || _allWidgets.last is ShimmerProfileSearch) {
        await _getFlow();
      } else {
        timer.cancel();
      }
    });
  }

  Future<List<dynamic>> _getFlow(
      {bool reset = false, bool current = false}) async {
    if (_isLoading) return [];
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    String apiUrl = reset
        ? '$API_URL/flow?reset'
        : current
            ? '$API_URL/flow?current'
            : '$API_URL/flow';
    final jwt = await getJWT();
    try {
      final http.Response response = await client.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final usersCompatible = json.decode(response.body);
        if (usersCompatible.isNotEmpty) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              for (var i = 0; i < usersCompatible.length; i++) {
                Future<Map<String, Image>> userImages =
                    fetchImages(usersCompatible[i]["uid"], withImages: true);

                _allWidgets.add(ProfileScrollWidget(
                  usersCompatible[i]["name"],
                  usersCompatible[i]["liked"],
                  usersCompatible[i]["uid"],
                  usersCompatible[i]["age"],
                  usersCompatible[i]["hobbies"],
                  usersCompatible[i]["distance"],
                  usersCompatible[i]["bio"] ?? "",
                  images: userImages,
                  callback: _scrollToNextPage,
                ));
              }
            });
          }
        }
        if (usersCompatible.length <= 2 &&
            _allWidgets.last is! ShimmerProfileSearch) {
          if (mounted) {
            setState(() {
              _allWidgets.add(const ShimmerProfileSearch());
            });
          }
        }
        return usersCompatible;
      } else {
        // Gestion des erreurs
        if (response.statusCode == 403 || response.statusCode == 401) {
          deleteJWT();
          sendToLoginScreen(context, arguments: {
            'message': AppLocalizations.of(context)!.pleaseReconnect
          });
        }
      }
    } catch (e) {
      print('Error when scrolling: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      showSnackBarBad(context);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          FutureBuilder<List<dynamic>>(
            future: _getFlowFuture,
            builder:
                (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ShimmerProfileSearch();
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                if (snapshot.data!.isEmpty) {
                  return const ShimmerProfileSearch();
                } else {
                  return PageView.builder(
                    physics: const CustomPageViewScrollPhysics(),
                    controller: _pageController,
                    itemCount: _allWidgets.length,
                    onPageChanged: (value) async {
                      if (_allWidgets[value] is ShimmerProfileSearch) {
                        _startShimmerRefresh();
                      } else {
                        _refreshTimer?.cancel();
                      }

                      if (_allWidgets[value] is TooUpPage) {
                        _pageController.nextPage(
                            duration: const Duration(milliseconds: 1000),
                            curve: Curves.easeIn);
                      } else if (value - 1 >= 1) {
                        if (_allWidgets[value - 1] is! TooUpPage) {
                          await _getFlow();
                          if (mounted) {
                            setState(() {
                              _allWidgets[value - 1] = const TooUpPage();
                            });
                          }
                        }
                      }
                    },
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      return _allWidgets[index];
                    },
                  );
                }
              }
            },
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: LikeCounterWidget(),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomPageViewScrollPhysics extends ScrollPhysics {
  const CustomPageViewScrollPhysics({super.parent});

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(parent: buildParent(ancestor)!);
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 50,
        stiffness: 100,
        damping: 0.8,
      );
}

class ShimmerProfileSearch extends StatelessWidget {
  const ShimmerProfileSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Column(
        children: [
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context)!.searchNewProfiles),
                SizedBox(height: 30),
                CircularProgressIndicator(),
              ],
            ),
          ),
          ShimmerProfileScrollLoadingInfos(),
        ],
      ),
    );
  }
}

class TooUpPage extends StatelessWidget {
  const TooUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(AppLocalizations.of(context)!.niceTry,
          style: Theme.of(context).textTheme.displayMedium),
    );
  }
}
