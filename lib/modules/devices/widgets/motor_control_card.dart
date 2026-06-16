import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/motor_aeracao_model.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/aeration_motor_controller.dart';

class MotorControlCard extends StatelessWidget {
  final MotorAeracaoModel motor;

  const MotorControlCard({super.key, required this.motor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ctrl = Get.find<AerationMotorController>();

    final isLigado = motor.estado == 'ligado';
    final isAtivo = motor.status == 'ativo';

    Color statusColor;
    switch (motor.status) {
      case 'ativo':
        statusColor = isLigado ? Colors.green : Colors.orange;
        break;
      case 'manutencao':
        statusColor = Colors.orange;
        break;
      case 'falha':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    String locationName;
    IconData locationIcon;
    if (motor.siloId != null) {
      final silo = ctrl.silos.firstWhereOrNull((s) => s.id == motor.siloId);
      locationName = motor.siloName ?? silo?.name ?? 'Silo #${motor.siloId}';
      locationIcon = Icons.warehouse_rounded;
    } else if (motor.secadorId != null) {
      final secador = ctrl.secadores.firstWhereOrNull((s) => s.id == motor.secadorId);
      locationName = motor.secadorName ?? secador?.nome ?? 'Secador #${motor.secadorId}';
      locationIcon = Icons.settings_input_component_rounded;
    } else {
      locationName = 'Não vinculado';
      locationIcon = Icons.link_off_rounded;
    }

    return Card(
      color: cs.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isLigado
                          ? [Colors.green.shade600, Colors.green.shade300]
                          : [cs.primary, cs.primary.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.bolt_rounded, color: cs.onPrimary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(motor.motorId, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(motor.description, style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Obx(() {
                  final commanding = ctrl.isCommanding.value;
                  return GestureDetector(
                    onTap: commanding
                        ? null
                        : () {
                            if (!isAtivo) {
                              final statusLabel = _statusLabel(motor.status);
                              final action = isLigado ? 'desligado' : 'ligado';
                              Get.dialog(
                                Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: Container(
                                    width: 380,
                                    padding: const EdgeInsets.all(32),
                                    decoration: BoxDecoration(
                                      color: cs.surface,
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: cs.error.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(Icons.block_rounded, color: cs.error, size: 40),
                                        ),
                                        const SizedBox(height: 24),
                                        Text(
                                          'Operação bloqueada',
                                          style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: cs.onSurface),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'O motor ${motor.motorId} não pode ser $action. Status operacional: "$statusLabel".',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant),
                                        ),
                                        const SizedBox(height: 32),
                                        SizedBox(
                                          width: double.infinity,
                                          child: FilledButton(
                                            onPressed: () => Get.back(),
                                            style: FilledButton.styleFrom(
                                              backgroundColor: cs.error,
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                            ),
                                            child: Text('Entendi', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                              return;
                            }
                            HapticFeedback.lightImpact();
                            if (isLigado) {
                              ctrl.turnOff(motor);
                            } else {
                              ctrl.turnOn(motor);
                            }
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 52, height: 28,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: isLigado ? Colors.green : cs.surfaceContainerHighest,
                      ),
                      child: Stack(
                        children: [
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            left: isLigado ? 26 : 2,
                            top: 2,
                            child: Container(
                              width: 24, height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 2)),
                                ],
                              ),
                              child: commanding
                                  ? Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
                                    )
                                  : Icon(
                                      isLigado ? Icons.power_rounded : Icons.power_off_rounded,
                                      size: 14,
                                      color: isLigado ? Colors.green : cs.onSurfaceVariant,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 14),
            _infoRow(cs, Icons.category_rounded, 'Potência', motor.potenciaKW != null ? '${motor.potenciaKW!.toStringAsFixed(1)} kW' : '—'),
            const SizedBox(height: 6),
            _infoRow(cs, Icons.air_rounded, 'Vazão', motor.vazaoAr != null ? '${motor.vazaoAr!.toStringAsFixed(0)} m³/h' : '—'),
            const SizedBox(height: 6),
            _infoRow(cs, Icons.speed_rounded, 'RPM', motor.rpm != null ? '${motor.rpm!.toStringAsFixed(0)} rpm' : '—'),
            const SizedBox(height: 6),
            _infoRow(cs, locationIcon, 'Vinculado a', locationName),
            const Spacer(),
            Row(
              children: [
                _statusIndicator(cs, isLigado ? 'LIGADO' : 'DESLIGADO', isLigado ? Colors.green : Colors.grey),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                  child: Text(motor.status.toUpperCase(), style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w700, color: statusColor, letterSpacing: 0.3)),
                ),
                const Spacer(),
                PopupMenuButton<int>(
                  icon: Icon(Icons.more_vert_rounded, size: 18, color: cs.onSurfaceVariant),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                  color: cs.surfaceContainerLow,
                  onSelected: (value) {
                    if (value == 0) _showMotorForm(context, motor: motor);
                    if (value == 1) _confirmDeleteMotor(context, motor);
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 0, child: Row(children: [Icon(Icons.edit_rounded, size: 18, color: cs.primary), const SizedBox(width: 10), Text('Editar', style: GoogleFonts.inter(color: cs.onSurface))])),
                    if (Get.find<HomeController>().isAdmin)
                    PopupMenuItem(value: 1, child: Row(children: [Icon(Icons.delete_outline_rounded, size: 18, color: cs.error), const SizedBox(width: 10), Text('Excluir', style: GoogleFonts.inter(color: cs.error))])),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(ColorScheme cs, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 15, color: cs.primary),
        const SizedBox(width: 6),
        Text('$label: ', style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant)),
        Expanded(child: Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'ativo': return 'Ativo';
      case 'manutencao': return 'Em Manutenção';
      case 'falha': return 'Falha';
      case 'desativado': return 'Desativado';
      default: return status;
    }
  }

  Widget _statusIndicator(ColorScheme cs, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color, boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)]),
        ),
        const SizedBox(width: 5),
        Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5)),
      ],
    );
  }

  void _showMotorForm(BuildContext context, {MotorAeracaoModel? motor}) {
    final isEditing = motor != null;
    final cs = Theme.of(context).colorScheme;
    final ctrl = Get.find<AerationMotorController>();

    final motorIdCtl = TextEditingController(text: motor?.motorId ?? '');
    final descriptionCtl = TextEditingController(text: motor?.description ?? '');
    final potenciaCtl = TextEditingController(text: motor?.potenciaKW?.toString() ?? '');
    final rpmCtl = TextEditingController(text: motor?.rpm?.toString() ?? '');
    final vazaoCtl = TextEditingController(text: motor?.vazaoAr?.toString() ?? '');
    final horimetroCtl = TextEditingController(text: motor?.horimetro?.toString() ?? '');

    final selectedSiloId = (motor?.siloId).obs;
    final selectedSecadorId = (motor?.secadorId).obs;

    final validStatuses = ['ativo', 'manutencao', 'falha', 'desativado'];
    final rawStatus = motor?.status.toLowerCase() ?? 'ativo';
    final status = (validStatuses.contains(rawStatus) ? rawStatus : 'ativo').obs;

    final formKey = GlobalKey<FormState>();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 520,
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(28),
          ),
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
                          Text(
                            isEditing ? 'Editar Motor' : 'Novo Motor de Aeração',
                            style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: cs.onPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isEditing ? 'Atualize as informações do motor.' : 'Cadastre um novo motor de aeração.',
                            style: GoogleFonts.inter(fontSize: 13, color: cs.onPrimary.withOpacity(0.8)),
                          ),
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
                              ...ctrl.silos.map((silo) => DropdownMenuItem(
                                value: silo.id,
                                child: Text('Silo: ${silo.name}'),
                              )),
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
                              ...ctrl.secadores.map((sec) => DropdownMenuItem(
                                value: sec.id,
                                child: Text('Secador: ${sec.nome}'),
                              )),
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
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: Text('Cancelar', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: FilledButton(
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    final newMotor = MotorAeracaoModel(
                                      id: motor?.id,
                                      motorId: motorIdCtl.text,
                                      description: descriptionCtl.text,
                                      potenciaKW: double.tryParse(potenciaCtl.text),
                                      rpm: double.tryParse(rpmCtl.text),
                                      vazaoAr: double.tryParse(vazaoCtl.text),
                                      horimetro: double.tryParse(horimetroCtl.text),
                                      siloId: selectedSiloId.value,
                                      secadorId: selectedSecadorId.value,
                                      status: status.value,
                                    );
                                    if (isEditing) {
                                      ctrl.updateMotor(newMotor);
                                    } else {
                                      ctrl.createMotor(newMotor);
                                    }
                                  }
                                },
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: Text(
                                  isEditing ? 'Atualizar Motor' : 'Cadastrar Motor',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                ),
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
    return Text(
      label,
      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: cs.primary, letterSpacing: 1.1),
    );
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

  void _confirmDeleteMotor(BuildContext context, MotorAeracaoModel motor) {
    final cs = Theme.of(context).colorScheme;
    Get.dialog(
      AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: cs.error.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.delete_forever_rounded, color: cs.error, size: 40),
            ),
            const SizedBox(height: 24),
            Text('Excluir Motor', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: cs.onSurface)),
            const SizedBox(height: 12),
            Text('Deseja realmente remover o motor ${motor.motorId}? Esta ação não poderá ser desfeita.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: cs.onSurfaceVariant, fontSize: 14),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: Text('Cancelar', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.error,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      ctrl.deleteMotor(motor.id!);
                      Get.back();
                    },
                    child: Text('Excluir', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  AerationMotorController get ctrl => Get.find<AerationMotorController>();
}
