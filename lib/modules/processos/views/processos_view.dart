import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/models/processo_model.dart';
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
      return const SizedBox.shrink(); // Remove a opção de deletar
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
      ],
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
    final typeNotifier = ValueNotifier<String>(processo?.tipoProcesso ?? 'Secagem');
    var selectedLoteId = processo?.loteId ?? (controller.availableBatches.isNotEmpty ? controller.availableBatches.first.id : null);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isEditing ? 'Editar Atividade' : 'Iniciar Nova Operação', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              ValueListenableBuilder<String>(
                valueListenable: typeNotifier,
                builder: (context, currentType, _) {
                  return Column(
                    children: [
                      _buildDropdownField<String>(
                        label: 'Tipo de Atividade',
                        value: currentType,
                        items: ['Secagem', 'Aeração'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (val) => typeNotifier.value = val!,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField<int>(
                        label: 'Lote / Grãos',
                        value: selectedLoteId,
                        items: controller.availableBatches
                            .map((b) => DropdownMenuItem(
                                  value: b.id, 
                                  child: Text('${b.numeroLote} - ${b.cultura} (${b.status})')
                                ))
                            .toList(),
                        onChanged: (val) {
                          selectedLoteId = val;
                          typeNotifier.notifyListeners();
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedLoteId != null) {
                        final batch = controller.availableBatches.firstWhere((b) => b.id == selectedLoteId);
                        
                        // Regra de Negócio: Lote não pode ter 2 atividades ativas
                        final isBusy = batch.status.contains('Iniciada') || batch.status.contains('Pausada');
                        
                        // Só bloqueia se for uma NOVA atividade ou se estiver trocando para um lote ocupado
                        if (isBusy && batch.id != processo?.loteId) {
                          Get.dialog(
                            AlertDialog(
                              title: Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                                  const SizedBox(width: 8),
                                  Text('Lote Ocupado', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              content: Text(
                                'O lote ${batch.numeroLote} já possui uma atividade: ${batch.status}.\n\nVocê precisa finalizar ou cancelar a atividade atual antes de iniciar uma nova para este grão.',
                                style: GoogleFonts.inter(),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('Entendido'),
                                ),
                              ],
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          );
                          return;
                        }
                      }

                      final newProcesso = ProcessoModel(
                        id: processo?.id,
                        tipoProcesso: typeNotifier.value,
                        loteId: selectedLoteId,
                        dataInicio: processo?.dataInicio ?? DateTime.now(),
                        status: processo?.status ?? 'Iniciada',
                      );
                      if (isEditing) {
                        controller.updateProcesso(newProcesso);
                      } else {
                        controller.createProcesso(newProcesso);
                      }
                    },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                    child: Text(isEditing ? 'Salvar' : 'Iniciar Agora'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
