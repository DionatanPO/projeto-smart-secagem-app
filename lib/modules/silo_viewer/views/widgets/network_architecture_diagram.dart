import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NetworkArchitectureDiagram extends StatelessWidget {
  const NetworkArchitectureDiagram({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey[50],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Fundo de Grid Técnico
            Positioned.fill(
              child: CustomPaint(
                painter: GridPainter(isDark: isDark),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.lan_rounded, color: theme.primaryColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Arquitetura de Conectividade',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Integração Modbus TCP/RTU em Tempo Real',
                              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            width: 900,
                            height: 450,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Cabos com Brilho (Neon Style)
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: WirePainter(
                                      isDark: isDark, 
                                      primaryColor: theme.primaryColor,
                                      glow: true,
                                    ),
                                  ),
                                ),
                                
                                // X7 Box (Client)
                                Positioned(
                                  left: 0,
                                  top: 150,
                                  child: _buildDeviceBox(
                                    context,
                                    'CONTROLADOR X7',
                                    ['MODBUS TCP CLIENT', 'DASHBOARD INTERFACE'],
                                    icon: Icons.computer_rounded,
                                    width: 180,
                                    height: 140,
                                    statusColor: Colors.blue,
                                  ),
                                ),

                                // Fieldlogger Box (Master)
                                Positioned(
                                  left: 280,
                                  top: 80,
                                  child: _buildDeviceBox(
                                    context,
                                    'GATEWAY FIELDLOGGER',
                                    [
                                      'MESTRE MODBUS RTU',
                                      'SERVER MODBUS TCP',
                                      'CONVERSOR DE PROTOCOLOS'
                                    ],
                                    icon: Icons.hub_rounded,
                                    headerLeft: 'ADDR 50 (D1)',
                                    headerRight: 'ADDR 49 (D0)',
                                    width: 250,
                                    height: 220,
                                    statusColor: theme.primaryColor,
                                    isMain: true,
                                  ),
                                ),

                                // Sensors/Devices
                                Positioned(
                                  left: 600,
                                  top: 280,
                                  child: _buildSensorBox(context, '01', 'Ativo'),
                                ),
                                Positioned(
                                  left: 730,
                                  top: 280,
                                  child: _buildSensorBox(context, '02', 'Ativo'),
                                ),
                                Positioned(
                                  left: 860,
                                  top: 280,
                                  child: _buildSensorBox(context, '03', 'Standby'),
                                ),

                                // Labels Técnicas de Cabo
                                Positioned(
                                  left: 170,
                                  bottom: 125,
                                  child: _buildCableLabel('Cabo Ethernet CAT6e', Icons.settings_ethernet),
                                ),
                                Positioned(
                                  left: 650,
                                  top: 20,
                                  child: _buildCableLabel('Barramento RS485 (Par Trançado)', Icons.linear_scale),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 48),
                  _buildLegend(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCableLabel(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceBox(
    BuildContext context,
    String title,
    List<String> details, {
    required IconData icon,
    String? headerLeft,
    String? headerRight,
    double width = 150,
    double height = 150,
    required Color statusColor,
    bool isMain = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900]?.withOpacity(0.8) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMain ? theme.primaryColor : (isDark ? Colors.white10 : Colors.black12),
          width: isMain ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: isMain ? 2 : 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Títulos de Pinos
          if (headerLeft != null || headerRight != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(headerLeft ?? '', style: GoogleFonts.firaCode(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.blue)),
                  Text(headerRight ?? '', style: GoogleFonts.firaCode(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.brown)),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: statusColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                ...details.map((d) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 10, color: statusColor.withOpacity(0.5)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              d,
                              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const Spacer(),
          // Status Bar
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorBox(BuildContext context, String id, String status) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('D1', style: GoogleFonts.firaCode(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 10)),
                Text('D0', style: GoogleFonts.firaCode(color: Colors.brown, fontWeight: FontWeight.bold, fontSize: 10)),
              ],
            ),
          ),
          Expanded(
            child: Icon(Icons.sensors_rounded, color: theme.primaryColor, size: 28),
          ),
          Text(
            'SENSOR $id',
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: status == 'Ativo' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: status == 'Ativo' ? Colors.green : Colors.orange),
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 32,
        runSpacing: 16,
        children: [
          _legendItem(Colors.black, 'Link Ethernet (TCP/IP)'),
          _legendItem(Colors.blue, 'Linha Dados D+ (RS485)'),
          _legendItem(Colors.brown, 'Linha Dados D- (RS485)'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[700]),
        ),
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  final bool isDark;
  GridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.02)
      ..strokeWidth = 1;

    const spacing = 30.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WirePainter extends CustomPainter {
  final bool isDark;
  final Color primaryColor;
  final bool glow;

  WirePainter({required this.isDark, required this.primaryColor, this.glow = false});

  @override
  void paint(Canvas canvas, Size size) {
    void drawPath(Path path, Paint paint, Color color) {
      if (glow) {
        // Camada de Brilho (Glow Effect)
        final glowPaint = Paint()
          ..color = color.withOpacity(0.15)
          ..strokeWidth = paint.strokeWidth * 4
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawPath(path, glowPaint);
        
        final coreGlow = Paint()
          ..color = color.withOpacity(0.3)
          ..strokeWidth = paint.strokeWidth * 2
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
        canvas.drawPath(path, coreGlow);
      }
      canvas.drawPath(path, paint);
    }

    final ethPaint = Paint()
      ..color = isDark ? Colors.white54 : Colors.black87
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final d1Paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final d0Paint = Paint()
      ..color = Colors.brown
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // 1. Cabo Ethernet (Estilo futurista com curvas suaves)
    final ethPath = Path();
    ethPath.moveTo(180, 220); // Lateral do X7
    ethPath.cubicTo(230, 220, 230, 340, 320, 340);
    ethPath.lineTo(405, 340);
    ethPath.lineTo(405, 300); // Entra no Fieldlogger por baixo
    drawPath(ethPath, ethPaint, isDark ? Colors.white : Colors.black);

    // 2. Barramento Modbus D1 (Blue)
    final d1BusY = 40.0;
    final d1Path = Path();
    d1Path.moveTo(310, 80); // Terminal 50 (D1)
    d1Path.lineTo(310, d1BusY);
    d1Path.lineTo(size.width - 20, d1BusY);
    
    // Conexões para Sensores
    _addSensorTap(d1Path, 600 + 15, d1BusY, 280);
    _addSensorTap(d1Path, 730 + 15, d1BusY, 280);
    _addSensorTap(d1Path, 860 + 15, d1BusY, 280);
    drawPath(d1Path, d1Paint, Colors.blue);

    // 3. Barramento Modbus D0 (Brown)
    final d0BusY = 60.0;
    final d0Path = Path();
    d0Path.moveTo(500, 80); // Terminal 49 (D0)
    d0Path.lineTo(500, d0BusY);
    d0Path.lineTo(size.width - 10, d0BusY);

    // Conexões para Sensores (Deslocados)
    _addSensorTap(d0Path, 600 + 75, d0BusY, 280);
    _addSensorTap(d0Path, 730 + 75, d0BusY, 280);
    _addSensorTap(d0Path, 860 + 75, d0BusY, 280);
    drawPath(d0Path, d0Paint, Colors.brown);
  }

  void _addSensorTap(Path path, double x, double fromY, double toY) {
    path.moveTo(x, fromY);
    path.lineTo(x, toY);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
