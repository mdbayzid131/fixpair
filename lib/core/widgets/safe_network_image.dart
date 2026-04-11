import 'package:fixpair/core/controllers/internet_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class SafeNetworkImage extends StatelessWidget {
  final String imageUrl;

  const SafeNetworkImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final internet = Get.find<InternetController>();

    if (!internet.hasInternet.value || imageUrl.isEmpty) {
      return const Icon(Icons.image_not_supported);
    }

    return Image.network(
      imageUrl,
      errorBuilder: (_, _, _) => const Icon(Icons.image_not_supported),
    );
  }
}
