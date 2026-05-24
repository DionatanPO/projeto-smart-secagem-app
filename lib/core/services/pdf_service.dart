import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  // ── Palette ────────────────────────────────────────────────────────────────
  static const _primary   = PdfColor.fromInt(0xFF1A2B4A);   // azul escuro
  static const _accent    = PdfColor.fromInt(0xFF2E6BE6);   // azul médio
  static const _subtle    = PdfColor.fromInt(0xFF6B7A99);   // cinza azulado
  static const _divider   = PdfColor.fromInt(0xFFDDE3EE);   // linha clara
  static const _rowAlt    = PdfColor.fromInt(0xFFF5F7FB);   // fundo zebra
  static const _white     = PdfColors.white;

  // ── Helpers ────────────────────────────────────────────────────────────────
  String _clean(String s) => s
      .replaceAll('**', '')
      .replaceAll('*', '')
      .replaceAll('__', '')
      .replaceAll('`', '');

  String _formatDateFile(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  String _formatDateDisplay(DateTime dt) {
    const months = [
      '', 'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
    ];
    return '${dt.day} de ${months[dt.month]} de ${dt.year}';
  }

  // Constrói spans com bold inline (**texto**)
  List<pw.TextSpan> _buildSpans(String text, double size,
      {PdfColor color = PdfColors.black}) {
    final parts = text.split('**');
    return [
      for (int i = 0; i < parts.length; i++)
        if (parts[i].isNotEmpty)
          pw.TextSpan(
            text: _clean(parts[i]),
            style: pw.TextStyle(
              fontSize: size,
              color: color,
              fontWeight: i.isOdd ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
    ];
  }

  // ── Decorações reutilizáveis ───────────────────────────────────────────────
  pw.Widget _sectionTitle(String text) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 14, bottom: 4),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              text.toUpperCase(),
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: _accent,
                letterSpacing: 1.2,
              ),
            ),
            pw.SizedBox(height: 3),
            pw.Container(height: 1.5, color: _accent),
          ],
        ),
      );

  pw.Widget _subTitle(String text) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 8, bottom: 2),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: _primary,
          ),
        ),
      );

  pw.Widget _h1(String text) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 10, bottom: 4),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 15,
            fontWeight: pw.FontWeight.bold,
            color: _primary,
          ),
        ),
      );

  pw.Widget _bulletItem(String content) => pw.Padding(
        padding: const pw.EdgeInsets.only(left: 8, bottom: 3),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4, right: 6),
              child: pw.Container(
                width: 4,
                height: 4,
                decoration: const pw.BoxDecoration(
                  color: _accent,
                  shape: pw.BoxShape.rectangle,
                ),
              ),
            ),
            pw.Expanded(
              child: pw.RichText(
                text: pw.TextSpan(
                  children: _buildSpans(content, 10, color: PdfColors.black),
                ),
              ),
            ),
          ],
        ),
      );

  pw.Widget _bodyText(String content) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 3),
        child: pw.RichText(
          text: pw.TextSpan(
            children: _buildSpans(content, 10, color: PdfColors.black),
          ),
        ),
      );

  // Tabela simples com zebra-striping
  pw.Widget _buildTable(List<List<String>> rows) {
    if (rows.isEmpty) return pw.SizedBox();
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Table(
        border: pw.TableBorder.all(color: _divider, width: 0.5),
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
                          horizontal: 6, vertical: 4),
                      child: pw.Text(
                        cell.trim(),
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: isHeader
                              ? pw.FontWeight.bold
                              : pw.FontWeight.normal,
                          color: isHeader ? _white : PdfColors.black,
                        ),
                      ),
                    ))
                .toList(),
          );
        }).toList(),
      ),
    );
  }

  // ── Header de página ───────────────────────────────────────────────────────
  pw.Widget _buildHeader(DateTime date) => pw.Container(
        decoration: const pw.BoxDecoration(
          border: pw.Border(
            bottom: pw.BorderSide(color: _primary, width: 2),
          ),
        ),
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'SILO SENSE',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: _primary,
                    letterSpacing: 2,
                  ),
                ),
                pw.Text(
                  'Resumo Operacional',
                  style: pw.TextStyle(fontSize: 10, color: _subtle),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  _formatDateDisplay(date),
                  style: pw.TextStyle(fontSize: 9, color: _subtle),
                ),
                pw.SizedBox(height: 2),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: pw.BoxDecoration(
                    color: _accent,
                    borderRadius: pw.BorderRadius.circular(3),
                  ),
                  child: pw.Text(
                    'CONFIDENCIAL',
                    style: pw.TextStyle(
                      fontSize: 7,
                      color: _white,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  // ── Footer de página ───────────────────────────────────────────────────────
  pw.Widget _buildFooter(pw.Context context) => pw.Column(
        children: [
          pw.Container(height: 0.5, color: _divider),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  'Gerado por Silo Sense IA · Documento autenticado pelo usuário · '
                  'Este resumo pode conter imprecisões.',
                  style: pw.TextStyle(fontSize: 7, color: _subtle),
                ),
              ),
              pw.Text(
                'Pág. ${context.pageNumber} / ${context.pagesCount}',
                style: pw.TextStyle(fontSize: 7, color: _subtle),
              ),
            ],
          ),
        ],
      );

  // ── Geração principal ──────────────────────────────────────────────────────
  Future<void> generateDashboardPdf(String text, DateTime? updated) async {
    final date = updated ?? DateTime.now();
    final pdf  = pw.Document();

    // Pré-processar linhas de tabela agrupadas
    final lines = text.split('\n');
    final processedWidgets = <pw.Widget>[];
    int i = 0;

    while (i < lines.length) {
      final trimmed = lines[i].trim();

      // Agrupar linhas de tabela
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
          padding: const pw.EdgeInsets.symmetric(vertical: 6),
          child: pw.Container(height: 0.5, color: _divider),
        ));
      } else if (trimmed.startsWith('# ')) {
        processedWidgets.add(_h1(_clean(trimmed.substring(2))));
      } else if (trimmed.startsWith('## ')) {
        processedWidgets.add(_sectionTitle(_clean(trimmed.substring(3))));
      } else if (trimmed.startsWith('### ')) {
        processedWidgets.add(_subTitle(_clean(trimmed.substring(4))));
      } else if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        processedWidgets.add(_bulletItem(trimmed.substring(2)));
      } else {
        processedWidgets.add(_bodyText(trimmed));
      }

      i++;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(40, 40, 40, 36),
        header: (_) => _buildHeader(date),
        footer: _buildFooter,
        build: (_) => processedWidgets,
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'resumo_operacional_${_formatDateFile(date)}.pdf',
    );
  }
}