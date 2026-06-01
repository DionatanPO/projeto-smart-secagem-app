import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/models/processo_model.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/processos_controller.dart';

class ProcessosView extends GetView<ProcessosController> {
  const ProcessosView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1100;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DefaultTabController(
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(isDesktop ? 32 : 16, isDesktop ? 32 : 16, isDesktop ? 32 : 16, 0),
              child: _buildHeader(context),
            ),
            Padding(
              padding: EdgeInsets.only(left: isDesktop ? 32 : 16, right: isDesktop ? 32 : 16),
              child: TabBar(
                isScrollable: !isDesktop,
                tabAlignment: isDesktop ? TabAlignment.fill : TabAlignment.start,
                indicatorColor: cs.primary,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: cs.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: cs.primary, width: 2),
                ),
                labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                labelColor: cs.primary,
                unselectedLabelColor: cs.onSurfaceVariant,
                tabs: const [
                  Tab(text: 'Etapas'),
                  Tab(text: 'Processos Salvos'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                children: [
                  _buildEtapasTab(isDesktop),
                  _buildProcessosSalvosTab(context, isDesktop, cs),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEtapasTab(bool isDesktop) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 32 : 16),
      child: Obx(() => _StageCards(
        controller: controller,
        activeStage: controller.activeStage.value,
        onNewProcesso: () => _showProcessoForm(Get.context!, tipo: 'Secagem'),
      )),
    );
  }

  Widget _buildProcessosSalvosTab(BuildContext context, bool isDesktop, ColorScheme cs) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.processos.isEmpty) {
        return Center(child: _buildEmptyState(context));
      }
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(isDesktop ? 32 : 16, 16, isDesktop ? 32 : 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Atividades em Execução', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: cs.onSurface)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => controller.getProcessos(),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Atualizar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final cols = w >= 1100 ? 3 : w >= 700 ? 2 : 1;
                final extent = (cols == 3 ? 320 : cols == 2 ? 300 : 280).toDouble();
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    mainAxisExtent: extent,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: controller.processos.length,
                  itemBuilder: (context, i) => _buildProcessoCard(context, controller.processos[i]),
                );
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gestão de Processos', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: cs.onSurface)),
        Text('Acompanhe o status e performance das operações.', style: GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(color: cs.surfaceContainerHighest.withOpacity(0.5), borderRadius: BorderRadius.circular(28)),
            child: Icon(Icons.inventory_2_outlined, size: 40, color: cs.onSurfaceVariant.withOpacity(0.4)),
          ),
          const SizedBox(height: 20),
          Text('Nenhum processo ativo', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text('Inicie uma nova atividade para começar.', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant.withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _buildProcessoCard(BuildContext context, ProcessoModel p) {
    final cs = Theme.of(context).colorScheme;
    final statusColor = _getStatusColor(p.status);
    return Card(
      elevation: 0,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: cs.outlineVariant.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildLeadingIcon(p.tipoProcesso),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.loteId != null ? 'Lote ${p.loteNumero}' : 'Atividade Avulsa',
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface),
                      ),
                      const SizedBox(height: 2),
                      Text(p.loteCultura ?? p.tipoProcesso, style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                _statusBadge(cs, p.status, statusColor),
              ],
            ),
            const Spacer(),
            _buildInfoRow(cs, p),
            const SizedBox(height: 16),
            _buildQuickActions(p),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(String tipo) {
    IconData icon;
    Color color;
    switch (tipo) {
      case 'Secagem': icon = Icons.waves_rounded; color = Colors.orange; break;
      case 'Resfriamento': icon = Icons.ac_unit_rounded; color = Colors.blue; break;
      case 'Aeração': icon = Icons.air_rounded; color = Colors.teal; break;
      default: icon = Icons.play_arrow_rounded; color = Colors.blue;
    }
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _statusBadge(ColorScheme cs, String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
      child: Text(status.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5)),
    );
  }

  Widget _buildInfoRow(ColorScheme cs, ProcessoModel p) {
    final df = DateFormat('dd/MM HH:mm');
    final duration = (p.dataFim ?? DateTime.now()).difference(p.dataInicio);
    final durationStr = '${duration.inHours}h ${duration.inMinutes % 60}m';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cs.surfaceContainerHighest.withOpacity(0.4), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          _infoItem(cs, Icons.calendar_today_rounded, 'Início', df.format(p.dataInicio.toLocal())),
          const SizedBox(width: 16),
          _infoItem(cs, Icons.timer_rounded, 'Duração', durationStr),
          if (p.responsavelNome != null) ...[
            const SizedBox(width: 16),
            _infoItem(cs, Icons.person_outline_rounded, 'Resp.', p.responsavelNome!),
          ],
        ],
      ),
    );
  }

  Widget _infoItem(ColorScheme cs, IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: cs.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(label, style: GoogleFonts.inter(fontSize: 10, color: cs.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 2),
          Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ProcessoModel p) {
    final cs = Theme.of(Get.context!).colorScheme;
    if (p.status == 'Finalizada' || p.status == 'Cancelada') {
      return Get.find<HomeController>().isAdmin
          ? Align(
              alignment: Alignment.centerRight,
              child: _ActionButton(icon: Icons.delete_outline_rounded, color: cs.error, onTap: () => _confirmDelete(p)),
            )
          : const SizedBox.shrink();
    }

    return Row(
      children: [
        if (p.status == 'Iniciada') ...[
          _ActionButton(icon: Icons.pause_rounded, color: Colors.orange, onTap: () => controller.changeStatus(p, 'Pausada')),
          const SizedBox(width: 8),
        ],
        if (p.status == 'Pausada') ...[
          _ActionButton(icon: Icons.play_arrow_rounded, color: Colors.blue, onTap: () => controller.changeStatus(p, 'Iniciada')),
          const SizedBox(width: 8),
        ],
        _ActionButton(icon: Icons.stop_rounded, color: Colors.green, onTap: () => _confirmFinish(p)),
        const SizedBox(width: 8),
        _ActionButton(icon: Icons.edit_outlined, color: cs.primary, onTap: () => _showProcessoForm(Get.context!, processo: p)),
        const Spacer(),
        _ActionButton(icon: Icons.close_rounded, color: cs.error, onTap: () => controller.changeStatus(p, 'Cancelada')),
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

  void _confirmDelete(ProcessoModel p) {
    final cs = Theme.of(Get.context!).colorScheme;
    Get.dialog(
      AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: cs.error.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.delete_outline_rounded, color: cs.error, size: 22)),
            const SizedBox(width: 12),
            Text('Excluir Atividade?', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: cs.onSurface)),
          ],
        ),
        content: Text('Esta ação não pode ser desfeita.', style: GoogleFonts.inter(color: cs.onSurfaceVariant)),
        actions: [
          TextButton(onPressed: () => Get.back(), style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text('Cancelar', style: GoogleFonts.inter(color: cs.onSurfaceVariant))),
          FilledButton(onPressed: () { Get.back(); if (p.id != null) controller.deleteProcesso(p.id!); }, style: FilledButton.styleFrom(backgroundColor: cs.error, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text('Excluir', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  void _confirmFinish(ProcessoModel p) {
    final cs = Theme.of(Get.context!).colorScheme;
    Get.dialog(
      AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 22)),
            const SizedBox(width: 12),
            Text('Finalizar Atividade?', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: cs.onSurface)),
          ],
        ),
        content: Text('Isso registrará o horário atual como data de término.', style: GoogleFonts.inter(color: cs.onSurfaceVariant)),
        actions: [
          TextButton(onPressed: () => Get.back(), style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text('Voltar', style: GoogleFonts.inter(color: cs.onSurfaceVariant))),
          FilledButton(onPressed: () { Get.back(); controller.changeStatus(p, 'Finalizada'); }, style: FilledButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text('Finalizar', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  void _showProcessoForm(BuildContext context, {ProcessoModel? processo, String? tipo}) {
    final isEditing = processo != null;
    String selectedTipo = tipo ?? processo?.tipoProcesso ?? 'Secagem';
    int? selectedLoteId = processo?.loteId ?? (controller.availableBatches.isNotEmpty ? controller.availableBatches.first.id : null);
    int? selectedSecadorId = processo?.secadorId;
    int? selectedSiloId = processo?.siloId;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          final cs = Theme.of(context).colorScheme;

          void onSecadorChanged(int? val) {
            setState(() { selectedSecadorId = val; if (val != null) selectedSiloId = null; });
          }

          void onSiloChanged(int? val) {
            setState(() { selectedSiloId = val; if (val != null) selectedSecadorId = null; });
          }

          final secadorItems = controller.availableDryers
              .where((d) => d.status == 'Disponível')
              .map((d) => DropdownMenuItem<int>(value: d.id, child: Text('${d.nome} (${d.fonteCalor})', style: GoogleFonts.inter(color: cs.onSurface))))
              .toList();

          final siloItems = controller.availableSilos
              .where((s) => s.status == 'disponivel')
              .map((s) => DropdownMenuItem<int>(value: s.id, child: Text(s.name, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(color: cs.onSurface))))
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
                          const SizedBox(height: 4),
                          _fieldLabel(cs, 'LOTE / GRÃOS'),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value: selectedLoteId,
                            isExpanded: true,
                            style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                            dropdownColor: cs.surface,
                            decoration: _fieldDeco(cs, Icons.grass),
                            items: controller.availableBatches.map((b) => DropdownMenuItem(value: b.id, child: Text('${b.numeroLote} - ${b.cultura} (${b.status})', style: GoogleFonts.inter(color: cs.onSurface)))).toList(),
                            onChanged: (val) => setState(() => selectedLoteId = val),
                          ),
                          const SizedBox(height: 20),
                          _fieldLabel(cs, 'SECADOR'),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(value: selectedSecadorId, isExpanded: true, style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface), dropdownColor: cs.surface, decoration: _fieldDeco(cs, Icons.settings_input_component_rounded), items: secadorItems, onChanged: onSecadorChanged),
                          const SizedBox(height: 20),
                          _fieldLabel(cs, 'SILO (OPCIONAL)'),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(value: selectedSiloId, isExpanded: true, style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface), dropdownColor: cs.surface, decoration: _fieldDeco(cs, Icons.warehouse_rounded), items: siloItems, onChanged: onSiloChanged),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(child: TextButton(onPressed: () => Get.back(), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: Text('Cancelar', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)))),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: FilledButton(
                                  onPressed: () {
                                    final newProcesso = ProcessoModel(id: processo?.id, tipoProcesso: selectedTipo, loteId: selectedLoteId, secadorId: selectedSecadorId, siloId: selectedSiloId, dataInicio: processo?.dataInicio ?? DateTime.now(), status: processo?.status ?? 'Iniciada');
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
      filled: true,
      fillColor: cs.surfaceContainerHighest.withOpacity(0.4),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: cs.primary)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}

class _StageData {
  final IconData icon;
  final String title;
  final Color color;
  final List<_Indicator> indicators;
  final List<_ActionData> actions;
  const _StageData(this.icon, this.title, this.color, this.indicators, this.actions);
}

class _Indicator {
  final String label;
  final String value;
  const _Indicator(this.label, this.value);
}

class _ActionData {
  final String label;
  final IconData icon;
  const _ActionData(this.label, this.icon);
}

const _stages = [
  _StageData(Icons.local_shipping_rounded, 'Chegada/Triagem', Color(0xFF2196F3), [
    _Indicator('Caminhões na fila', '18'),
    _Indicator('Tempo médio de espera', '32 min'),
    _Indicator('Em atendimento', '3'),
  ], [
    _ActionData('Nova entrada', Icons.add_circle_outline),
    _ActionData('Consultar fila', Icons.list_alt_rounded),
  ]),
  _StageData(Icons.biotech_rounded, 'Classificação', Color(0xFF9C27B0), [
    _Indicator('Aguardando análise', '12'),
    _Indicator('Classificados hoje', '146'),
    _Indicator('Umidade média', '13,8%'),
  ], [
    _ActionData('Registrar classificação', Icons.science_outlined),
    _ActionData('Emitir laudo', Icons.description_outlined),
  ]),
  _StageData(Icons.download_rounded, 'Moega/Recebimento', Color(0xFFFF9800), [
    _Indicator('Descargas em andamento', '4'),
    _Indicator('Ton. recebidas hoje', '2.450 t'),
    _Indicator('Capacidade utilizada', '68%'),
  ], [
    _ActionData('Iniciar descarga', Icons.download_rounded),
    _ActionData('Visualizar moegas', Icons.visibility_rounded),
  ]),
  _StageData(Icons.waves_rounded, 'Pré-limpeza/Secagem', Color(0xFFF44336), [
    _Indicator('Lotes em secagem', '6'),
    _Indicator('Umidade média atual', '15,2%'),
    _Indicator('Secadores ativos', '2/3'),
  ], [
    _ActionData('Monitorar secagem', Icons.monitor_heart_outlined),
    _ActionData('Ajustar parâmetros', Icons.tune_rounded),
  ]),
  _StageData(Icons.warehouse_rounded, 'Armazenamento', Color(0xFF4CAF50), [
    _Indicator('Estoque total', '32.540 t'),
    _Indicator('Ocupação dos silos', '78%'),
    _Indicator('Temperatura média', '24°C'),
  ], [
    _ActionData('Visualizar silos', Icons.warehouse_rounded),
    _ActionData('Mapa de armazenamento', Icons.map_rounded),
  ]),
  _StageData(Icons.local_shipping_rounded, 'Expedição', Color(0xFF607D8B), [
    _Indicator('Carregamentos hoje', '42'),
    _Indicator('Ton. expedidas', '1.860 t'),
    _Indicator('Caminhões aguardando', '5'),
  ], [
    _ActionData('Nova expedição', Icons.local_shipping_rounded),
    _ActionData('Emitir romaneio', Icons.receipt_long_rounded),
  ]),
];

class _StageCards extends StatelessWidget {
  final ProcessosController controller;
  final int activeStage;
  final VoidCallback? onNewProcesso;
  const _StageCards({required this.controller, required this.activeStage, this.onNewProcesso});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final cols = w >= 1100 ? 3 : w >= 700 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisExtent: 100,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: _stages.length,
          itemBuilder: (_, i) => _buildCard(cs, i, onNewProcesso),
        );
      },
    );
  }

  Widget _buildCard(ColorScheme cs, int index, VoidCallback? onNewProcesso) {
    final stage = _stages[index];
    final isActive = activeStage == index;
    final isSecagem = index == 3;

    return GestureDetector(
      onTap: () {
        controller.activeStage.value = index;
        if (isSecagem && onNewProcesso != null) onNewProcesso();
      },
      child: Card(
        elevation: isActive ? 4 : 1,
        shadowColor: isActive ? stage.color.withOpacity(0.3) : Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isActive ? stage.color : cs.outlineVariant.withOpacity(0.3),
            width: isActive ? 1.5 : 1,
          ),
        ),
        color: isActive ? cs.surfaceContainerHighest : cs.surface,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [stage.color, stage.color.withOpacity(0.6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(stage.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(stage.title, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: cs.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      ),
    );
  }
}
