import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../../../routes/app_routes.dart';

class LandingController extends GetxController {
  late VideoPlayerController videoController;
  final isVideoInitialized = false.obs;
  final hasVideoError = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      videoController = VideoPlayerController.asset('assets/video.mp4');
      await videoController.initialize();
      videoController.setLooping(true);
      videoController.setVolume(0);
      videoController.play();
      isVideoInitialized.value = true;
    } catch (e) {
      hasVideoError.value = true;
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

