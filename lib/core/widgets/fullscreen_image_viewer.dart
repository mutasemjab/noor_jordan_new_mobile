import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FullscreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final String? heroTag;
  final String? title;

  const FullscreenImageViewer({
    super.key,
    required this.imageUrl,
    this.heroTag,
    this.title,
  });

  static void open(
    BuildContext context,
    String imageUrl, {
    String? heroTag,
    String? title,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => FullscreenImageViewer(
          imageUrl: imageUrl,
          heroTag: heroTag,
          title: title,
        ),
      ),
    );
  }

  Future<void> _download() async {
    final uri = Uri.parse(imageUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.contain,
      placeholder: (_, __) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      errorWidget: (_, __, ___) => const Icon(
        Icons.broken_image_outlined,
        color: Colors.white54,
        size: 64,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: title != null
            ? Text(
                title!,
                style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 15),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            onPressed: _download,
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 5,
          child: heroTag != null ? Hero(tag: heroTag!, child: image) : image,
        ),
      ),
    );
  }
}
