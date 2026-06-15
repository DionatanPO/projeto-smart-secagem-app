import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../../../routes/app_routes.dart';

class LandingController extends GetxController {
  late VideoPlayerController videoController;
  final isVideoInitialized = false.obs;
  final hasVideoError = false.obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initVideo();
    });
  }

  Future<void> _initVideo() async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      videoController = VideoPlayerController.asset('assets/video.mp4');
      await videoController.initialize();
      videoController.setLooping(true);
      videoController.setVolume(0);
      videoController.play();
      isVideoInitialized.value = true;
    } catch (e) {
      hasVideoError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    videoController.dispose();
    super.onClose();
  }

  void accessSystem() {
    Get.toNamed(Routes.login);
  }
}

