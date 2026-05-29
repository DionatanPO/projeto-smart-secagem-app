import 'package:get/get.dart';

class CustosDeProducaoController extends GetxController {
  final currentStep = 0.obs;
  final isEditing = false.obs;

  void nextStep() {
    if (currentStep.value < 3) currentStep.value++;
  }

  void previousStep() {
    if (currentStep.value > 0) currentStep.value--;
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 3) currentStep.value = step;
  }

  Future<void> loadInfraestrutura() async {}

  Future<void> loadLote() async {}

  Future<void> loadInsumos() async {}

  Future<void> calcularCustos() async {}
}
