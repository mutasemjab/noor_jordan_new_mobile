import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../di/injection.dart';

class PdfViewerPage extends StatefulWidget {
  final String url;
  final String title;

  const PdfViewerPage({super.key, required this.url, required this.title});

  static void open(BuildContext context, {required String url, required String title}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PdfViewerPage(url: url, title: title)),
    );
  }

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  Uint8List? _bytes;
  String? _error;
  int? _totalPages;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.url.isEmpty) {
      setState(() => _error = 'رابط الملف غير متوفر');
      return;
    }
    try {
      final dio = sl<Dio>();
      final response = await dio.get<List<int>>(
        widget.url,
        options: Options(responseType: ResponseType.bytes),
      );
      if (!mounted) return;
      setState(() => _bytes = Uint8List.fromList(response.data!));
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'تعذّر تحميل الملف');
    }
  }

  Future<void> _openExternally() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700),
        ),
        actions: [
          if (_totalPages != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  '${_currentPage + 1} / $_totalPages',
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded),
            tooltip: 'فتح خارجياً',
            onPressed: _openExternally,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 12),
              const Text('تعذّر تحميل الملف', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _openExternally,
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('فتح خارجياً', style: TextStyle(fontFamily: 'Cairo')),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    if (_bytes == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return PDFView(
      pdfData: _bytes,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
      pageSnap: true,
      fitPolicy: FitPolicy.WIDTH,
      onRender: (pages) {
        if (mounted) setState(() => _totalPages = pages);
      },
      onPageChanged: (page, total) {
        if (mounted) setState(() => _currentPage = page ?? 0);
      },
      onError: (error) {
        if (mounted) setState(() => _error = 'تعذّر عرض الملف');
      },
      onPageError: (page, error) {
        if (mounted) setState(() => _error = 'تعذّر عرض الصفحة ${(page ?? 0) + 1}');
      },
    );
  }
}
