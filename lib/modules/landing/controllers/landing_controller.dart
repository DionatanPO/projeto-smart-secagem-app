import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../../../routes/app_routes.dart';

class LandingController extends GetxController {
  VideoPlayerController? videoController;
  final isVideoInitialized = false.obs;
  final hasVideoError = false.obs;
  final isLoading = true.obs;
  bool _disposed = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initVideo();
    });
  }

  Future<void> _initVideo() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (_disposed) return;
    try {
      final vc = VideoPlayerController.asset('assets/video.mp4');
      await vc.initialize();
      if (_disposed) {
        vc.dispose();
        return;
      }
      videoController = vc;
      vc.setLooping(true);
      vc.setVolume(0);
      vc.play();
      isVideoInitialized.value = true;
    } catch (e) {
      hasVideoError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _disposed = true;
    videoController?.dispose();
    videoController = null;
    super.onClose();
  }

  void accessSystem() {
    Get.toNamed(Routes.login);
  }
}

