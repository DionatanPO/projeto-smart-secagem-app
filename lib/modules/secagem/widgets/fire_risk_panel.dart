import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/models/fire_risk_model.dart';
import '../../../core/models/sensor_model.dart';
import '../../secagem/controllers/secagem_controller.dart';

class FireRiskPanel extends StatelessWidget {
  final int secadorId;
  final bool isLoading;

  const FireRiskPanel({super.key, required this.secadorId, this.isLoading = false});

  Color _levelColor(FireRiskLevel level) {
    switch (level) {
      case FireRiskLevel.safe: return const Color(0xFF22C55E);
      case FireRiskLevel.attention: return const Color(0xFFEAB308);
      case FireRiskLevel.warning: return const Color(0xFFF97316);
      case FireRiskLevel.critical: return const Color(0xFFEF4444);
      case FireRiskLevel.emergency: return const Color(0xFFDC2626);
    }
  }

  IconData _levelIcon(FireRiskLevel level) {
    switch (level) {
      case FireRiskLevel.safe: return Icons.check_circle_rounded;
      case FireRiskLevel.attention: return Icons.info_rounded;
      case FireRiskLevel.warning: return Icons.warning_rounded;
      case FireRiskLevel.critical: return Icons.gpp_bad_rounded;
      case FireRiskLevel.emergency: return Icons.local_fire_department_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final controller = Get.find<SecagemController>();

    return Obx(() {
      final assessments = controller.fireRiskAssessments;
      final overallLevel = controller.overallFireLevel.value;
      final loading = controller.isLoadingFireRisk.value || isLoading;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('PREVENÇÃO DE INCÊNDIO'.toUpperCase(),
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: cs.error)),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () => _showFireInfoDialog(context),
                    child: Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(
                        color: cs.error.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.help_outline_rounded, size: 12, color: cs.error),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _levelColor(overallLevel).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_levelIcon(overallLevel), size: 12, color: _levelColor(overallLevel)),
                        const SizedBox(width: 4),
                        Text(overallLevel.label, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: _levelColor(overallLevel), letterSpacing: 0.3)),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
          if (controller.hasFireEmergency.value)
            InkWell(
              onTap: () => _showEmergencyDialog(context, controller.fireRiskAssessments),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.notifications_active_rounded, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text('EMERGÊNCIA', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)),
                  ],
                ),
              ),
            ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 32,
                    child: OutlinedButton.icon(
                      onPressed: loading ? null : () => controller.refreshFireRisk(secadorId),
                      icon: loading
                        ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: cs.error))
                        : const Icon(Icons.refresh_rounded, size: 14),
                      label: Text('Atualizar', style: GoogleFonts.inter(fontSize: 10)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: cs.error,
                        side: BorderSide(color: cs.error.withOpacity(0.4)),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (loading && assessments.isEmpty)
            Container(
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.radar_rounded, size: 48, color: cs.onSurfaceVariant.withOpacity(0.2)),
                  const SizedBox(height: 12),
                  Text('Verificando sensores de incêndio...', style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant)),
                ],
              ),
            )
          else if (assessments.isEmpty && !loading)
            Container(
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.shield_rounded, size: 48, color: Colors.green.withOpacity(0.3)),
                  const SizedBox(height: 12),
                  Text('Nenhum sensor de mancal ou abafamento vinculado.', style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text('Adicione sensores do tipo "sensor_mancal" ou "sensor_abafando" para monitorar risco de incêndio.', style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant.withOpacity(0.6))),
                ],
              ),
            )
          else
            ...assessments.map((risk) => _buildRiskCard(context, risk)),
        ],
      );
    });
  }

  Widget _buildRiskCard(BuildContext context, FireRiskModel risk) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final color = _levelColor(risk.level);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.06 : 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25 + risk.level.index * 0.15)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          expansionTileTheme: ExpansionTileThemeData(
            iconColor: color,
            collapsedIconColor: color,
        ),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
          leading: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(_levelIcon(risk.level), size: 20, color: color),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                child: Text(SensorModel.tipoLabel(risk.sensor.tipo),
                  style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
              ),
              const SizedBox(width: 8),
              Text(risk.sensor.sensorId, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface)),
              const Spacer(),
              Text('${risk.currentTemp.toStringAsFixed(1)}°C', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: cs.outlineVariant.withOpacity(0.3)),
                  const SizedBox(height: 8),
                  _buildDetailRow('Temperatura', '${risk.currentTemp.toStringAsFixed(1)}°C', Icons.thermostat_rounded, Colors.orange),
                  if (risk.currentGasLevel != null)
                    _buildDetailRow('Gás (CO)', '${risk.currentGasLevel!.toStringAsFixed(0)} ppm', Icons.air_rounded, Colors.red.shade300),
                  if (risk.currentVibration != null)
                    _buildDetailRow('Vibração', '${risk.currentVibration!.toStringAsFixed(1)} mm/s', Icons.vibration_rounded, Colors.purple),
                  _buildDetailRow('Taxa de subida', '${risk.temperatureRiseRate.toStringAsFixed(1)}°C/min', Icons.trending_up_rounded, risk.temperatureRiseRate >= 2 ? Colors.red : Colors.green),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: color.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(_levelIcon(risk.level), size: 14, color: color),
                            const SizedBox(width: 6),
                            Text(risk.levelLabel.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(risk.message, style: GoogleFonts.inter(fontSize: 11, color: cs.onSurface, height: 1.4)),
                      ],
                    ),
                  ),
                  if (risk.recommendations.isNotEmpty && risk.level.index >= FireRiskLevel.warning.index) ...[
                    const SizedBox(height: 12),
                    Text('RECOMENDAÇÕES', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: color, letterSpacing: 1)),
                    const SizedBox(height: 6),
                    ...risk.recommendations.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.chevron_right_rounded, size: 14, color: color),
                          Expanded(child: Text(r, style: GoogleFonts.inter(fontSize: 10, color: cs.onSurfaceVariant, height: 1.3))),
                        ],
                      ),
                    )),
                  ],
                  const SizedBox(height: 8),
                  Text('Última leitura: ${DateFormat('dd/MM HH:mm').format(risk.timestamp.toLocal())}',
                    style: GoogleFonts.inter(fontSize: 9, color: cs.onSurfaceVariant.withOpacity(0.5))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
          const Spacer(),
          Text(value, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showFireInfoDialog(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(28),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: cs.error.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.local_fire_department_rounded, color: cs.error, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Prevenção de Incêndio', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: cs.onSurface)),
                          Text('Entenda como o monitoramento funciona', style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      style: IconButton.styleFrom(backgroundColor: cs.surfaceContainerHighest),
                      color: cs.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _infoSection(cs, Icons.thermostat_rounded, 'Sensores de Temperatura', Colors.orange,
                  'Monitoram a temperatura do grão durante a secagem. '
                  'Aumentos súbitos podem indicar princípio de combustão. '
                  'Valores acima de 80°C exigem atenção imediata.'),
                const SizedBox(height: 16),
                _infoSection(cs, Icons.engineering_rounded, 'Sensores de Mancal', Colors.purple,
                  'Instalados nos rolamentos do secador. '
                  'O superaquecimento do mancal (acima de 70°C) é um dos primeiros '
                  'sinais de atrito anormal que pode gerar faíscas e iniciar um incêndio.'),
                const SizedBox(height: 16),
                _infoSection(cs, Icons.air_rounded, 'Sensores de Abafamento', Colors.red.shade300,
                  'Detectam gases de combustão (CO) e monóxido de carbono '
                  'no interior do secador. A presença de gás indica '
                  'que o grão está queimando internamente (pirólise). '
                  'Níveis acima de 50 ppm são críticos.'),
                const SizedBox(height: 16),
                _infoSection(cs, Icons.trending_up_rounded, 'Taxa de Elevação', Colors.amber,
                  'Mede a velocidade com que a temperatura sobe em 1 minuto. '
                  'Uma taxa acima de 2°C/min indica aquecimento acelerado '
                  'e risco iminente de ignição.'),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      cs.error.withOpacity(0.05),
                      cs.error.withOpacity(0.02),
                    ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cs.error.withOpacity(0.12)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.shield_rounded, size: 28, color: cs.error.withOpacity(0.5)),
                      const SizedBox(height: 8),
                      Text(
                        'Níveis de Risco',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: cs.onSurface),
                      ),
                      const SizedBox(height: 12),
                      _riskLevelRow(cs, 'Seguro', 'Tudo normal, continue monitorando.', const Color(0xFF22C55E)),
                      const SizedBox(height: 6),
                      _riskLevelRow(cs, 'Atenção', 'Acompanhe de perto a evolução.', const Color(0xFFEAB308)),
                      const SizedBox(height: 6),
                      _riskLevelRow(cs, 'Alerta', 'Providencie verificação técnica.', const Color(0xFFF97316)),
                      const SizedBox(height: 6),
                      _riskLevelRow(cs, 'Crítico', 'Reduza a temperatura do secador.', const Color(0xFFEF4444)),
                      const SizedBox(height: 6),
                      _riskLevelRow(cs, 'Emergência', 'Pare o secador e acione o corpo de bombeiros.', const Color(0xFFDC2626)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.error,
                      foregroundColor: cs.onError,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('ENTENDI', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoSection(ColorScheme cs, IconData icon, String title, Color color, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface)),
              const SizedBox(height: 4),
              Text(description, style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant, height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _riskLevelRow(ColorScheme cs, String label, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          ),
          Expanded(
            child: Text(description, style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }

  void _showEmergencyDialog(BuildContext context, List<FireRiskModel> assessments) {
    final cs = Theme.of(context).colorScheme;
    final emergencies = assessments.where((r) => r.level.index >= FireRiskLevel.critical.index).toList();
    HapticFeedback.heavyImpact();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.local_fire_department_rounded, color: Colors.red, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ALERTA DE EMERGÊNCIA', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.red)),
                        Text('${emergencies.length} sensor(es) em estado crítico', style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...emergencies.map((e) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${SensorModel.tipoLabel(e.sensor.tipo)} ${e.sensor.sensorId}',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(e.message, style: GoogleFonts.inter(fontSize: 12, color: cs.onSurface, height: 1.4)),
                    const SizedBox(height: 8),
                    ...e.recommendations.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.arrow_right_rounded, size: 16, color: Colors.red),
                          Expanded(child: Text(r, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.red, height: 1.3))),
                        ],
                      ),
                    )),
                  ],
                ),
              )),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('ACITONAR MEDIDAS', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}