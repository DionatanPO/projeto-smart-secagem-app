import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/motor_aeracao_model.dart';
import '../controllers/aeration_motor_controller.dart';
import '../widgets/motor_control_card.dart';

class AerationMotorsView extends GetView<AerationMotorController> {
  const AerationMotorsView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AerationMotorController>()) {
      Get.put(AerationMotorController());
    }

    final cs = Theme.of(context).colorScheme;
    final isDesktop = MediaQuery.of(context).size.width >= 1100;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (!isDesktop) ...[
                  IconButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: const Icon(Icons.menu_rounded),
                    color: cs.primary,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Motores de Aeração',
                        style: GoogleFonts.outfit(fontSize: isDesktop ? 28 : 22, fontWeight: FontWeight.w700, color: cs.onSurface),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Controle e monitore seus motores de aeração de silos.',
                        style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Obx(() {
                  if (controller.motors.isEmpty) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt_rounded, size: 16, color: cs.primary),
                        const SizedBox(width: 6),
                        Text(
                          '${controller.motors.length} motores',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: cs.primary),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: SearchBar(
                hintText: 'Buscar por ID, descrição, status ou local...',
                hintStyle: WidgetStatePropertyAll(GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant.withOpacity(0.6))),
                leading: Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
                backgroundColor: WidgetStatePropertyAll(cs.surfaceContainerLow),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                elevation: WidgetStatePropertyAll(0),
                padding: WidgetStatePropertyAll(const EdgeInsets.symmetric(horizontal: 16)),
                textStyle: WidgetStatePropertyAll(GoogleFonts.inter(fontSize: 14, color: cs.onSurface)),
                onChanged: controller.filterMotors,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Obx(() {
                controller.silos.length;
                controller.secadores.length;
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = controller.filteredMotors;
                if (list.isEmpty) {
                  return _buildEmptyState(context, controller.searchQuery.value.isNotEmpty);
                }
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = isDesktop ? (constraints.maxWidth ~/ 360).clamp(2, 4) : 1;
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisExtent: 280,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: list.length,
                      itemBuilder: (context, index) => MotorControlCard(motor: list[index]),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewMotorForm(context),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isSearch) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(isSearch ? Icons.search_off_rounded : Icons.electrical_services_rounded, size: 36, color: cs.onSurfaceVariant.withOpacity(0.5)),
          ),
          const SizedBox(height: 20),
          Text(
            isSearch ? 'Nenhum motor encontrado' : 'Nenhum motor configurado',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            isSearch ? 'Tente ajustar sua busca.' : 'Clique em "Configurar Novo" para adicionar.',
            style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  void _showNewMotorForm(BuildContext context) {
    // Delegates to widget form — triggers the form from MotorControlCard statically
    final cs = Theme.of(context).colorScheme;
    final ctrl = controller;

    final motorIdCtl = TextEditingController();
    final descriptionCtl = TextEditingController();
    final potenciaCtl = TextEditingController();
    final rpmCtl = TextEditingController();
    final vazaoCtl = TextEditingController();
    final horimetroCtl = TextEditingController();

    final selectedSiloId = Rx<int?>(null);
    final selectedSecadorId = Rx<int?>(null);
    final status = 'ativo'.obs;
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 520,
          decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(28)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(32, 28, 32, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [cs.primary, cs.primary.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Novo Motor de Aeração', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: cs.onPrimary)),
                          const SizedBox(height: 4),
                          Text('Cadastre um novo motor de aeração.', style: GoogleFonts.inter(fontSize: 13, color: cs.onPrimary.withOpacity(0.8))),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close_rounded),
                      style: IconButton.styleFrom(backgroundColor: cs.onPrimary.withOpacity(0.15)),
                      color: cs.onPrimary,
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel(cs, 'IDENTIFICAÇÃO DO MOTOR'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: motorIdCtl,
                          style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                          decoration: _fieldDeco(cs, 'Ex: MOTOR-AER-001', Icons.fingerprint_rounded),
                          validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                        ),
                        const SizedBox(height: 20),
                        _fieldLabel(cs, 'DESCRIÇÃO / LOCALIZAÇÃO'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: descriptionCtl,
                          style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                          decoration: _fieldDeco(cs, 'Ex: Aeração Sul - Silo 3', Icons.location_on_rounded),
                          validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                        ),
                        const SizedBox(height: 24),
                        _fieldLabel(cs, 'PARÂMETROS TÉCNICOS'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: potenciaCtl,
                                style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                                decoration: _fieldDeco(cs, 'kW', Icons.electric_bolt_rounded),
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: rpmCtl,
                                style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                                decoration: _fieldDeco(cs, 'RPM', Icons.speed_rounded),
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: vazaoCtl,
                                style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                                decoration: _fieldDeco(cs, 'm³/h', Icons.air_rounded),
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: horimetroCtl,
                                style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                                decoration: _fieldDeco(cs, 'Horas', Icons.timer_rounded),
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _fieldLabel(cs, 'VINCULAR A'),
                        const SizedBox(height: 8),
                        Obx(() {
                          final hasSilo = ctrl.silos.any((s) => s.id == selectedSiloId.value);
                          return DropdownButtonFormField<int>(
                            value: hasSilo ? selectedSiloId.value : null,
                            style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                            dropdownColor: cs.surface,
                            hint: Text('Silo', style: GoogleFonts.inter(color: cs.onSurfaceVariant)),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('Nenhum')),
                              ...ctrl.silos.map((silo) => DropdownMenuItem(value: silo.id, child: Text('Silo: ${silo.name}'))),
                            ],
                            onChanged: (v) {
                              selectedSiloId.value = v;
                              if (v != null) { selectedSecadorId.value = null; }
                            },
                            decoration: _fieldDeco(cs, '', Icons.warehouse_rounded),
                          );
                        }),
                        const SizedBox(height: 12),
                        Obx(() {
                          final hasSec = ctrl.secadores.any((s) => s.id == selectedSecadorId.value);
                          return DropdownButtonFormField<int>(
                            value: hasSec ? selectedSecadorId.value : null,
                            style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                            dropdownColor: cs.surface,
                            hint: Text('Secador', style: GoogleFonts.inter(color: cs.onSurfaceVariant)),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('Nenhum')),
                              ...ctrl.secadores.map((sec) => DropdownMenuItem(value: sec.id, child: Text('Secador: ${sec.nome}'))),
                            ],
                            onChanged: (v) {
                              selectedSecadorId.value = v;
                              if (v != null) { selectedSiloId.value = null; }
                            },
                            decoration: _fieldDeco(cs, '', Icons.settings_input_component_rounded),
                          );
                        }),
                        const SizedBox(height: 24),
                        _fieldLabel(cs, 'STATUS OPERACIONAL'),
                        const SizedBox(height: 8),
                        Obx(() => DropdownButtonFormField<String>(
                          value: status.value,
                          style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                          dropdownColor: cs.surface,
                          items: const [
                            DropdownMenuItem(value: 'ativo', child: Text('Ativo')),
                            DropdownMenuItem(value: 'manutencao', child: Text('Em Manutenção')),
                            DropdownMenuItem(value: 'falha', child: Text('Falha')),
                            DropdownMenuItem(value: 'desativado', child: Text('Desativado')),
                          ],
                          onChanged: (v) => status.value = v!,
                          decoration: _fieldDeco(cs, '', Icons.info_outline_rounded),
                        )),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Get.back(),
                                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                                child: Text('Cancelar', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: FilledButton(
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    ctrl.createMotor(MotorAeracaoModel(
                                      motorId: motorIdCtl.text,
                                      description: descriptionCtl.text,
                                      potenciaKW: double.tryParse(potenciaCtl.text),
                                      rpm: double.tryParse(rpmCtl.text),
                                      vazaoAr: double.tryParse(vazaoCtl.text),
                                      horimetro: double.tryParse(horimetroCtl.text),
                                      siloId: selectedSiloId.value,
                                      secadorId: selectedSecadorId.value,
                                      status: status.value,
                                    ));
                                  }
                                },
                                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                                child: Text('Cadastrar Motor', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(ColorScheme cs, String label) {
    return Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: cs.primary, letterSpacing: 1.1));
  }

  InputDecoration _fieldDeco(ColorScheme cs, String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant.withOpacity(0.5)),
      prefixIcon: Icon(icon, size: 20, color: cs.primary.withOpacity(0.5)),
      filled: true,
      fillColor: cs.surfaceContainerHighest.withOpacity(0.3),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: cs.primary, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    );
  }
}
