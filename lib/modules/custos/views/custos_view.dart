import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/models/custo_processo_model.dart';
import '../controllers/custos_controller.dart';

class CustosView extends GetView<CustosController> {
  const CustosView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1100;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        padding: EdgeInsets.all(isDesktop ? 32 : 16),
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
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Custos de Secagem',
                          style: GoogleFonts.outfit(fontSize: isDesktop ? 28 : 22, fontWeight: FontWeight.w700, color: cs.onSurface),
                        ),
                      ),
                      if (isDesktop)
                        Text('Custos dos processos de secagem com dados de lotes e secadores.', style: GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = controller.processos;
                if (list.isEmpty) {
                  return _buildEmptyState(context);
                }
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _buildCard(context, list[i]),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, CustoProcessoModel item) {
    final cs = Theme.of(context).colorScheme;
    final fmt = NumberFormat('#,##0.0#', 'pt_BR');
    final p = item.processo;
    final lote = item.lote;
    final secador = item.secador;

    final duracao = p.dataFim?.difference(p.dataInicio);
    final horas = duracao != null ? duracao.inMinutes / 60.0 : null;
    final perdaMassa = lote != null && lote.pesoFinal != null ? lote.pesoInicial - lote.pesoFinal! : null;
    final aguaRemovida = lote != null && lote.umidadeFinal != null ? lote.umidadeInicial - lote.umidadeFinal! : null;

    return Card(
      elevation: 0,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [cs.primary, cs.primary.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.monetization_on_rounded, color: cs.onPrimary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lote?.numeroLote ?? p.loteNumero ?? 'Processo #${p.id}', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
                      const SizedBox(height: 2),
                      Text('${p.tipoProcesso} • ${lote?.cultura ?? p.loteCultura ?? '-'}', style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                _statusBadge(cs, p.status),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: cs.surfaceContainerHighest.withOpacity(0.4), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _row(cs, Icons.calendar_today_rounded, 'Período', '${DateFormat('dd/MM/yyyy HH:mm').format(p.dataInicio)} — ${p.dataFim != null ? DateFormat('dd/MM/yyyy HH:mm').format(p.dataFim!) : 'Em andamento'}'),
                  if (horas != null) ...[
                    const SizedBox(height: 8),
                    _row(cs, Icons.timer_rounded, 'Duração', '${horas.toStringAsFixed(1)} h'),
                  ],
                  if (secador != null) ...[
                    const SizedBox(height: 8),
                    _row(cs, Icons.heat_pump_rounded, 'Secador', '${secador.nome} (${secador.fonteCalor})'),
                    const SizedBox(height: 8),
                    _row(cs, Icons.speed_rounded, 'Capacidade', '${secador.capacidade} t/h'),
                  ],
                ],
              ),
            ),
            if (lote != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: cs.surfaceContainerHighest.withOpacity(0.4), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    _row(cs, Icons.monitor_weight_rounded, 'Peso inicial/final', '${fmt.format(lote.pesoInicial)} kg${lote.pesoFinal != null ? ' → ${fmt.format(lote.pesoFinal!)} kg' : ''}'),
                    const SizedBox(height: 8),
                    _row(cs, Icons.water_drop_rounded, 'Umidade inicial/final', '${lote.umidadeInicial}%${lote.umidadeFinal != null ? ' → ${lote.umidadeFinal!}%' : ''}'),
                    if (perdaMassa != null) ...[
                      const SizedBox(height: 8),
                      _row(cs, Icons.remove_circle_outline_rounded, 'Perda de massa', '${fmt.format(perdaMassa)} kg'),
                    ],
                    if (aguaRemovida != null) ...[
                      const SizedBox(height: 8),
                      _row(cs, Icons.opacity_rounded, 'Água removida', '${aguaRemovida.toStringAsFixed(1)} p.p.'),
                    ],
                  ],
                ),
              ),
            ],
            if (lote?.clienteNome != null) ...[
              const SizedBox(height: 8),
              _row(cs, Icons.person_rounded, 'Cliente', lote!.clienteNome!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(ColorScheme cs, String status) {
    final color = switch (status) {
      'Finalizada' => Colors.green,
      'Cancelada' => Colors.red,
      'Pausada' => Colors.orange,
      'Iniciada' => Colors.blue,
      _ => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Widget _row(ColorScheme cs, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: cs.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant)),
        const Spacer(),
        Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface)),
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
            width: 88, height: 88,
            decoration: BoxDecoration(color: cs.surfaceContainerHighest.withOpacity(0.5), borderRadius: BorderRadius.circular(28)),
            child: Icon(Icons.monetization_on_outlined, size: 40, color: cs.onSurfaceVariant.withOpacity(0.4)),
          ),
          const SizedBox(height: 20),
          Text('Nenhum processo encontrado', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text('Os processos de secagem com seus dados aparecerão aqui.', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant.withOpacity(0.7))),
        ],
      ),
    );
  }
}
