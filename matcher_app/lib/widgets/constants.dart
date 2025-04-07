library;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:subtil_app/main.dart';

final Uri matcherUrlCGU = Uri.parse("https://www.matcher-app.fr/cgu.html");
final Uri matcherUrlMentionLegale = Uri.parse("https://www.matcher-app.fr/mentions-legales.html");

const String apiAgent = "MatcherAgent";


class CustomHttpClient extends http.BaseClient {
  final http.Client _client;

  CustomHttpClient(this._client);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['User-Agent'] = apiAgent;
    return _client.send(request);
  }
}
final client = CustomHttpClient(http.Client());

class backGround extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Color surfaceColor = Theme.of(context).colorScheme.surface;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
      ),
    );
  }
}

Widget pageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 16 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.pink : AppColors.pinkLight,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

class ShimmerProfileScrollLoadingInfos extends StatelessWidget {
  const ShimmerProfileScrollLoadingInfos({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerMainColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 30,
              width: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15,),
            Container(
              height: 25,
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15,),
            Row(
              children: [
                Container(
                  height: 20,
                  width: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10,),
                Container(
                  height: 20,
                  width: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10,),
                Container(
                  height: 20,
                  width: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15,),
          ],
        ),
      ),
    );
  }
}

class ShimmerProfileScrollLoadingImage extends StatelessWidget {
  const ShimmerProfileScrollLoadingImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerMainColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white
          ),
        ),
      ),
    );
  }
}

class ShimmerProfilePictureLoadingImage extends StatelessWidget {
  const ShimmerProfilePictureLoadingImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerMainColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: Container(
        width: 160,
        height: 160,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class ShimmerTextBlock extends StatelessWidget {
  final int width;
  final int height;

  const ShimmerTextBlock({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerMainColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: Container(
        width: width.toDouble(),
        height: height.toDouble(),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
      ),
    );
  }
}