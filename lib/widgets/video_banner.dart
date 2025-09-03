import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoBanner extends StatefulWidget {
  final String manifestPath; // Firebase Storage HTTPS URL to HLS manifest (m3u8)
  final VoidCallback onFinished;

  const VideoBanner({
    super.key,
    required this.manifestPath,
    required this.onFinished,
  });

  @override
  State<VideoBanner> createState() => _VideoBannerState();
}

class _VideoBannerState extends State<VideoBanner> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      VideoPlayerController? controller;
      
      // First, try to load the URL directly (in case it's a direct video file)
      try {
        controller = VideoPlayerController.networkUrl(Uri.parse('${widget.manifestPath}manifest.mpd'), formatHint: VideoFormat.dash);
        await controller.initialize();
        debugPrint('Successfully loaded direct video URL: ${widget.manifestPath}');
      } catch (e) {
        debugPrint('Direct video loading failed, trying manifest files: $e');
        controller?.dispose();
        controller = null;
        
        // If direct loading fails, try different manifest file extensions
        final List<String> manifestExtensions = [
          'manifest.m3u8',  // HLS manifest
          'manifest.mpd',   // DASH manifest
          'media-hd.m3u8', // HD HLS manifest
          'media-sd.m3u8', // SD HLS manifest
        ];

        for (final extension in manifestExtensions) {
          try {
            final url = '${widget.manifestPath}$extension';
            debugPrint('Trying manifest URL: $url');
            
            controller = VideoPlayerController.networkUrl(Uri.parse(url));
            await controller.initialize();
            debugPrint('Successfully loaded manifest: $url');
            break;
          } catch (e) {
            debugPrint('Failed to load $extension: $e');
            controller?.dispose();
            controller = null;
          }
        }
      }

      if (controller == null) {
        throw Exception('Could not load video or any manifest file');
      }

      _controller = controller;
      await controller.setLooping(false);
      await controller.play();

      // Listen for end of playback
      controller.addListener(() {
        if (!mounted) return;
        final currentController = _controller;
        if (currentController != null && 
            currentController.value.isInitialized && 
            !currentController.value.isPlaying) {
          final position = currentController.value.position;
          final duration = currentController.value.duration;
          if (position >= duration) {
            widget.onFinished();
          }
        }
      });

      if (mounted) {
        setState(() {
          _initialized = true;
          _hasError = false;
        });
      }
    } catch (e) {
      debugPrint('Video initialization error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.video_library,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'فشل تحميل الفيديو',
              style: TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
            // const SizedBox(height: 8),
            // Text(
            //   _errorMessage,
            //   style: const TextStyle(fontSize: 12),
            //   textAlign: TextAlign.center,
            // ),
          ],
        ),
      );
    }

    if (!_initialized || _controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: _controller?.value.size.width ?? 0,
        height: _controller?.value.size.height ?? 0,
        child: VideoPlayer(_controller!),
      ),
    );
  }
}



