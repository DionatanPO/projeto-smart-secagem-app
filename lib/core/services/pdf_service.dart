import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static const _primary   = PdfColor.fromInt(0xFF1A2B4A);
  static const _accent    = PdfColor.fromInt(0xFF2563EB);
  static const _subtle    = PdfColor.fromInt(0xFF64748B);
  static const _divider   = PdfColor.fromInt(0xFFE2E8F0);
  static const _rowAlt    = PdfColor.fromInt(0xFFF8FAFC);
  static const _white     = PdfColors.white;
  static const _black     = PdfColor.fromInt(0xFF1E293B);
  static const _surface   = PdfColor.fromInt(0xFFF0F4FF);
  static const _success   = PdfColor.fromInt(0xFF16A34A);
  static const _warning   = PdfColor.fromInt(0xFFD97706);
  static const _danger    = PdfColor.fromInt(0xFFDC2626);

  String _clean(String s) => s.replaceAll('__', '').replaceAll('`', '');

  String _formatDateFile(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  String _formatDateDisplay(DateTime dt) {
    const months = [
      '', 'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
    ];
    return '${dt.day} de ${months[dt.month]} de ${dt.year}';
  }

  List<pw.TextSpan> _buildSpans(String text, double size,
      {PdfColor color = _black, bool justify = false}) {
    final parts = text.split('**');
    return [
      for (int i = 0; i < parts.length; i++)
        if (parts[i].isNotEmpty)
          pw.TextSpan(
            text: _clean(parts[i]),
            style: pw.TextStyle(
              fontSize: size,
              color: color,
              lineSpacing: 1.6,
              fontWeight: i.isOdd ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
    ];
  }

  pw.Widget _sectionTitle(String text) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 20, bottom: 8),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.fromLTRB(0, 0, 0, 4),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: _accent, width: 2),
                ),
              ),
              child: pw.Text(
                text.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: _accent,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            pw.SizedBox(height: 6),
          ],
        ),
      );

  pw.Widget _subTitle(String text) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 14, bottom: 6),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: _primary,
          ),
        ),
      );

  pw.Widget _h1(String text) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 16, bottom: 8),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: _primary,
          ),
        ),
      );

  pw.Widget _bulletItem(String content) => pw.Padding(
        padding: const pw.EdgeInsets.only(left: 12, bottom: 4),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 8, right: 8),
              child: pw.Container(
                width: 5,
                height: 5,
                decoration: const pw.BoxDecoration(
                  color: _accent,
                  shape: pw.BoxShape.circle,
                ),
              ),
            ),
            pw.Expanded(
              child: pw.RichText(
                text: pw.TextSpan(
                  children: _buildSpans(content, 10, color: _black),
                ),
              ),
            ),
          ],
        ),
      );

  pw.Widget _bodyText(String content) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.RichText(
          textAlign: pw.TextAlign.justify,
          text: pw.TextSpan(
            children: _buildSpans(content, 10, color: _black, justify: true),
          ),
        ),
      );

  pw.Widget _infoCard(String title, String content) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 8),
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _surface,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: PdfColor.fromInt(0xFFD6E4FF), width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: _accent,
              letterSpacing: 1.2,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.RichText(
            text: pw.TextSpan(
              children: _buildSpans(content, 10, color: _black),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTable(List<List<String>> rows) {
    if (rows.isEmpty) return pw.SizedBox();
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Table(
        border: pw.TableBorder(
          horizontalInside: pw.BorderSide(color: _divider, width: 0.5),
          verticalInside: pw.BorderSide(color: _divider, width: 0.3),
          bottom: pw.BorderSide(color: _divider, width: 0.5),
          top: pw.BorderSide(color: _divider, width: 0.5),
        ),
        columnWidths: {
          for (int i = 0; i < rows.first.length; i++)
            i: const pw.FlexColumnWidth(),
        },
        children: rows.asMap().entries.map((entry) {
          final isHeader = entry.key == 0;
          final isEven   = entry.key.isEven;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isHeader ? _primary : (isEven ? _rowAlt : _white),
            ),
            children: entry.value
                .map((cell) => pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      child: pw.Text(
                        cell.trim(),
                        style: pw.TextStyle(
                          fontSize: 8.5,
                          fontWeight: isHeader
                              ? pw.FontWeight.bold
                              : pw.FontWeight.normal,
                          color: isHeader ? _white : _black,
                        ),
                      ),
                    ))
                .toList(),
          );
        }).toList(),
      ),
    );
  }

  pw.Widget _buildHeader(DateTime date) => pw.Container(
        decoration: const pw.BoxDecoration(
          border: pw.Border(
            bottom: pw.BorderSide(color: _primary, width: 2.5),
          ),
        ),
        padding: const pw.EdgeInsets.only(bottom: 12),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Container(
                      width: 4,
                      height: 24,
                      color: _accent,
                    ),
                    pw.SizedBox(width: 10),
                    pw.Text(
                      'SILO SENSE',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: _primary,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Relatório Inteligente de Secagem',
                  style: pw.TextStyle(fontSize: 9, color: _subtle),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  _formatDateDisplay(date),
                  style: pw.TextStyle(fontSize: 8.5, color: _subtle),
                ),
                pw.SizedBox(height: 4),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: pw.BoxDecoration(
                    color: _accent,
                    borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(4)),
                  ),
                  child: pw.Text(
                    'RELATÓRIO GERENCIAL',
                    style: pw.TextStyle(
                      fontSize: 7,
                      color: _white,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  pw.Widget _buildFooter(pw.Context context) => pw.Column(
        children: [
          pw.Container(height: 0.5, color: _divider),
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  'Gerado por Silo Sense IA em ${DateTime.now().toIso8601String().substring(0, 19).replaceAll('T', ' às ')} · '
                  'Documento autenticado pelo usuário',
                  style: pw.TextStyle(fontSize: 6.5, color: _subtle),
                ),
              ),
              pw.Row(
                children: [
                  pw.Container(
                    width: 6, height: 6,
                    decoration: pw.BoxDecoration(
                      color: _accent,
                      shape: pw.BoxShape.circle,
                    ),
                  ),
                  pw.SizedBox(width: 4),
                  pw.Text(
                    'Pág. ${context.pageNumber}',
                    style: pw.TextStyle(fontSize: 7, color: _subtle),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

  Future<void> generateDashboardPdf(String text, DateTime? updated) async {
    final date = updated ?? DateTime.now();
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: await PdfGoogleFonts.interRegular(),
        bold: await PdfGoogleFonts.interBold(),
      ),
    );

    final lines = text.split('\n');
    final processedWidgets = <pw.Widget>[];
    int i = 0;

    while (i < lines.length) {
      final trimmed = lines[i].trim();

      if (trimmed.startsWith('|')) {
        final tableLines = <String>[];
        while (i < lines.length && lines[i].trim().startsWith('|')) {
          tableLines.add(lines[i].trim());
          i++;
        }
        final rows = tableLines
            .where((l) => !l.split('|').every((c) => c.trim().contains('---')))
            .map((l) =>
                l.split('|').where((c) => c.trim().isNotEmpty).toList())
            .toList();
        if (rows.isNotEmpty) processedWidgets.add(_buildTable(rows));
        continue;
      }

      if (trimmed.isEmpty) {
        processedWidgets.add(pw.SizedBox(height: 4));
      } else if (trimmed == '---') {
        processedWidgets.add(pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 8),
          child: pw.Container(height: 0.5, color: _divider),
        ));
      } else if (trimmed.startsWith('### ')) {
        processedWidgets.add(_subTitle(_clean(trimmed.substring(4))));
      } else if (trimmed.startsWith('## ')) {
        processedWidgets.add(_sectionTitle(_clean(trimmed.substring(3))));
      } else if (trimmed.startsWith('# ')) {
        processedWidgets.add(_h1(_clean(trimmed.substring(2))));
      } else if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        processedWidgets.add(_bulletItem(trimmed.substring(2)));
      } else if (trimmed.startsWith('> ')) {
        processedWidgets.add(_infoCard('Destaque', trimmed.substring(2)));
      } else {
        processedWidgets.add(_bodyText(trimmed));
      }

      i++;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(44, 44, 44, 40),
        header: (_) => _buildHeader(date),
        footer: _buildFooter,
        build: (_) => [
          pw.SizedBox(height: 8),
          ...processedWidgets,
          pw.SizedBox(height: 12),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'relatorio_silo_sense_${_formatDateFile(date)}.pdf',
    );
  }
}
