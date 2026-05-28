import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/models/processo_model.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/processos_controller.dart';

class ProcessosView extends GetView<ProcessosController> {
  const ProcessosView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.processos.isEmpty) {
                  return _buildEmptyState(context);
                }
                return _buildProcessosList(context);
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProcessoForm(context),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_circle_outline_rounded),
        label: Text('Iniciar Nova Atividade', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gestão de Tempo e Atividades',
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Acompanhe o tempo exato de cada operação na sua unidade.',
          style: GoogleFonts.inter(fontSize: 16, color: theme.hintColor),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer_outlined, size: 80, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'Nenhum processo ativo',
            style: GoogleFonts.inter(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessosList(BuildContext context) {
    return ListView.separated(
      itemCount: controller.processos.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildSimpleCard(context, controller.processos[index]),
    );
  }

  Widget _buildSimpleCard(BuildContext context, ProcessoModel p) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final df = DateFormat('dd/MM HH:mm');
    
    // Cálculo de tempo
    final duration = (p.dataFim ?? DateTime.now()).difference(p.dataInicio);
    final durationStr = '${duration.inHours}h ${duration.inMinutes % 60}m';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          _buildLeadingIcon(p.tipoProcesso, p.status),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.tipoProcesso,
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: theme.primaryColor),
                ),
                Text(
                  p.loteId != null ? 'Lote ${p.loteNumero} - ${p.loteCultura}' : 'Atividade Avulsa',
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildTimeInfo('Início:', df.format(p.dataInicio.toLocal())),
                    if (p.dataFim != null) ...[
                      const SizedBox(width: 16),
                      _buildTimeInfo('Fim:', df.format(p.dataFim!.toLocal())),
                    ],
                  ],
                ),
                if (p.siloNome != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.storage_rounded, size: 14, color: theme.hintColor),
                      const SizedBox(width: 4),
                      Text(
                        'Silo ${p.siloNome}',
                        style: GoogleFonts.inter(fontSize: 12, color: theme.hintColor, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
                if (p.tipoProcesso == 'Secagem' && p.secadorNome != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.settings_input_component_rounded, size: 14, color: theme.hintColor),
                      const SizedBox(width: 4),
                      Text(
                        'Secador ${p.secadorNome}',
                        style: GoogleFonts.inter(fontSize: 12, color: theme.hintColor, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded, size: 14, color: theme.hintColor),
                    const SizedBox(width: 4),
                    Text(
                      p.responsavelNome ?? 'Operador do Sistema',
                      style: GoogleFonts.inter(fontSize: 12, color: theme.hintColor, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                durationStr,
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: theme.primaryColor),
              ),
              Text(
                p.status.toUpperCase(),
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: _getStatusColor(p.status)),
              ),
            ],
          ),
          const SizedBox(width: 32),
          _buildQuickActions(p),
        ],
      ),
    );
  }

  Widget _buildLeadingIcon(String tipo, String status) {
    IconData icon;
    Color color;
    switch (tipo) {
      case 'Secagem': icon = Icons.waves_rounded; color = Colors.orange; break;
      case 'Expurgo': icon = Icons.biotech_rounded; color = Colors.red; break;
      case 'Transilagem': icon = Icons.swap_horiz_rounded; color = Colors.purple; break;
      default: icon = Icons.play_arrow_rounded; color = Colors.blue;
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 28),
    );
  }

  Widget _buildTimeInfo(String label, String value) {
    return Row(
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
        const SizedBox(width: 4),
        Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Iniciada': return Colors.blue;
      case 'Pausada': return Colors.orange;
      case 'Finalizada': return Colors.green;
      case 'Cancelada': return Colors.red;
      default: return Colors.grey;
    }
  }

  Widget _buildQuickActions(ProcessoModel p) {
    final theme = Theme.of(Get.context!);
    if (p.status == 'Finalizada' || p.status == 'Cancelada') {
      return Get.find<HomeController>().isAdmin
        ? _ActionButton(
            icon: Icons.delete_outline_rounded,
            color: Colors.red,
            onTap: () => _confirmDelete(p),
          )
        : const SizedBox.shrink();
    }

    return Row(
      children: [
        _ActionButton(
          icon: Icons.edit_outlined, 
          color: theme.primaryColor, 
          onTap: () => _showProcessoForm(Get.context!, processo: p)
        ),
        const SizedBox(width: 8),
        if (p.status == 'Iniciada')
          _ActionButton(
            icon: Icons.pause_rounded, 
            color: Colors.orange, 
            onTap: () => controller.changeStatus(p, 'Pausada')
          )
        else if (p.status == 'Pausada')
          _ActionButton(
            icon: Icons.play_arrow_rounded, 
            color: Colors.blue, 
            onTap: () => controller.changeStatus(p, 'Iniciada')
          ),
        const SizedBox(width: 8),
        _ActionButton(
          icon: Icons.stop_rounded, 
          color: Colors.green, 
          onTap: () => _confirmFinish(p)
        ),
        const SizedBox(width: 8),
        _ActionButton(
          icon: Icons.close_rounded, 
          color: Colors.red, 
          onTap: () => controller.changeStatus(p, 'Cancelada')
        ),
        if (p.status != 'Iniciada' && p.status != 'Pausada' && Get.find<HomeController>().isAdmin) ...[
          const SizedBox(width: 8),
          _ActionButton(
            icon: Icons.delete_outline_rounded,
            color: Colors.red.withOpacity(0.6),
            onTap: () => _confirmDelete(p),
          ),
        ],
      ],
    );
  }

  void _confirmDelete(ProcessoModel p) {
    Get.dialog(
      AlertDialog(
        title: const Text('Excluir Atividade?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Get.back();
              if (p.id != null) controller.deleteProcesso(p.id!);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmFinish(ProcessoModel p) {
    Get.dialog(
      AlertDialog(
        title: const Text('Finalizar Atividade?'),
        content: const Text('Isso registrará o horário atual como data de término do processo.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Voltar')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.changeStatus(p, 'Finalizada');
            },
            child: const Text('Finalizar Agora', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Formulário simplificado
  void _showProcessoForm(BuildContext context, {ProcessoModel? processo}) {
    final isEditing = processo != null;

    // Estado declarado UMA VEZ, fora do builder
    String selectedTipo = processo?.tipoProcesso ?? 'Secagem';
    int? selectedLoteId = processo?.loteId ?? (controller.availableBatches.isNotEmpty ? controller.availableBatches.first.id : null);
    int? selectedSecadorId = processo?.secadorId;
    int? selectedSiloId = processo?.siloId;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          final cs = Theme.of(context).colorScheme;

          void onSecadorChanged(int? val) {
            setState(() {
              selectedSecadorId = val;
              if (val != null) selectedSiloId = null;
            });
          }

          void onSiloChanged(int? val) {
            setState(() {
              selectedSiloId = val;
              if (val != null) selectedSecadorId = null;
            });
          }

          final secadorItems = controller.availableDryers
              .where((d) => d.status == 'Disponível')
              .map((d) => DropdownMenuItem<int>(
                    value: d.id,
                    child: Text('${d.nome} (${d.fonteCalor})', style: GoogleFonts.inter(color: cs.onSurface)),
                  ))
              .toList();

          final siloItems = controller.availableSilos
              .where((s) => s.status == 'disponivel')
              .map((s) => DropdownMenuItem<int>(
                    value: s.id,
                    child: Text(s.name, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(color: cs.onSurface)),
                  ))
              .toList();

          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 500,
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
                              Text(isEditing ? 'Editar Atividade' : 'Iniciar Nova Operação', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: cs.onPrimary)),
                              const SizedBox(height: 4),
                              Text(isEditing ? 'Atualize os dados da operação.' : 'Configure uma nova operação no sistema.', style: GoogleFonts.inter(fontSize: 13, color: cs.onPrimary.withOpacity(0.8))),
                            ],
                          ),
                        ),
                        IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close_rounded), style: IconButton.styleFrom(backgroundColor: cs.onPrimary.withOpacity(0.15)), color: cs.onPrimary),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel(cs, 'TIPO DE ATIVIDADE'),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: selectedTipo,
                            style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                            dropdownColor: cs.surface,
                            decoration: _fieldDeco(cs, Icons.category_rounded),
                            items: ['Secagem', 'Resfriamento']
                                .map((t) => DropdownMenuItem(value: t, child: Text(t, style: GoogleFonts.inter(color: cs.onSurface))))
                                .toList(),
                            onChanged: (val) => setState(() {
                              selectedTipo = val!;
                              if (val != 'Secagem') selectedSecadorId = null;
                              if (val != 'Resfriamento') {
                                selectedSecadorId = null;
                                selectedSiloId = null;
                              }
                            }),
                          ),
                          const SizedBox(height: 20),
                          _fieldLabel(cs, 'LOTE / GRÃOS'),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value: selectedLoteId,
                            isExpanded: true,
                            style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                            dropdownColor: cs.surface,
                            decoration: _fieldDeco(cs, Icons.grass),
                            items: controller.availableBatches
                                .map((b) => DropdownMenuItem(value: b.id, child: Text('${b.numeroLote} - ${b.cultura} (${b.status})', style: GoogleFonts.inter(color: cs.onSurface))))
                                .toList(),
                            onChanged: (val) => setState(() => selectedLoteId = val),
                          ),
                          if (selectedTipo == 'Secagem') ...[
                            const SizedBox(height: 20),
                            _fieldLabel(cs, 'SECADOR'),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              value: selectedSecadorId,
                              isExpanded: true,
                              style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                              dropdownColor: cs.surface,
                              decoration: _fieldDeco(cs, Icons.settings_input_component_rounded),
                              items: secadorItems,
                              onChanged: onSecadorChanged,
                            ),
                          ],
                          if (selectedTipo == 'Resfriamento') ...[
                            const SizedBox(height: 20),
                            _fieldLabel(cs, 'DESTINO'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Flexible(
                                  child: DropdownButtonFormField<int>(
                                    value: selectedSecadorId,
                                    isExpanded: true,
                                    style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                                    dropdownColor: cs.surface,
                                    decoration: _fieldDeco(cs, Icons.settings_input_component_rounded),
                                    items: secadorItems,
                                    onChanged: onSecadorChanged,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text('OU', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: cs.onSurfaceVariant)),
                                ),
                                Flexible(
                                  child: DropdownButtonFormField<int>(
                                    value: selectedSiloId,
                                    isExpanded: true,
                                    style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                                    dropdownColor: cs.surface,
                                    decoration: _fieldDeco(cs, Icons.warehouse_rounded),
                                    items: siloItems,
                                    onChanged: onSiloChanged,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => Get.back(),
                                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                                  child: Text('Cancelar', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: FilledButton(
                                  onPressed: () {
                                    final newProcesso = ProcessoModel(
                                      id: processo?.id,
                                      tipoProcesso: selectedTipo,
                                      loteId: selectedLoteId,
                                      secadorId: selectedSecadorId,
                                      siloId: selectedSiloId,
                                      dataInicio: processo?.dataInicio ?? DateTime.now(),
                                      status: processo?.status ?? 'Iniciada',
                                    );
                                    if (isEditing) controller.updateProcesso(newProcesso);
                                    else controller.createProcesso(newProcesso);
                                  },
                                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                                  child: Text(isEditing ? 'Salvar' : 'Iniciar Agora', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _fieldLabel(ColorScheme cs, String label) {
    return Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: cs.primary, letterSpacing: 0.8));
  }

  InputDecoration _fieldDeco(ColorScheme cs, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, size: 20, color: cs.primary.withOpacity(0.6)),
      filled: true, fillColor: cs.surfaceContainerHighest.withOpacity(0.4),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: cs.primary)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, required IconData icon}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDropdownField<T>({required String label, required T? value, required List<DropdownMenuItem<T>> items, required Function(T?) onChanged}) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}
