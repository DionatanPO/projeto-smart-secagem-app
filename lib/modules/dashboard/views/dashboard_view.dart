import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../controllers/dashboard_controller.dart';
import '../../../core/services/pdf_service.dart';
import '../../../core/values/app_colors.dart';

class RespostaIA extends StatelessWidget {
  final String resposta;

  const RespostaIA({super.key, required this.resposta});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: MarkdownBody(
        data: resposta,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          p: GoogleFonts.inter(
            fontSize: 14,
            height: 1.6,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
          pPadding: const EdgeInsets.only(bottom: 8),
          strong: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
          em: GoogleFonts.inter(
            fontStyle: FontStyle.italic,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
          h1: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
          h2: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
          h3: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
          listBullet: GoogleFonts.inter(
            color: AppColors.primary,
            fontSize: 14,
          ),
          listBulletPadding: const EdgeInsets.only(right: 6),
          listIndent: 20,
          code: GoogleFonts.robotoMono(
            fontSize: 13,
            backgroundColor: isDark ? Colors.black45 : Colors.grey[200],
            color: AppColors.primary,
          ),
          codeblockPadding: const EdgeInsets.all(12),
          codeblockDecoration: BoxDecoration(
            color: isDark ? Colors.black45 : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          a: GoogleFonts.inter(
            color: AppColors.primary,
            decoration: TextDecoration.underline,
          ),
          blockquote: GoogleFonts.inter(
            fontStyle: FontStyle.italic,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
          blockquoteDecoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: AppColors.primary.withOpacity(0.5),
                width: 3,
              ),
            ),
          ),
          horizontalRuleDecoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.white10 : Colors.black12,
                width: 1,
              ),
            ),
          ),
          blockSpacing: 10,
        ),
        checkboxBuilder: (bool value) {
          return Transform.scale(
            scale: 0.8,
            child: Checkbox(
              value: value,
              onChanged: null,
              activeColor: AppColors.primary,
            ),
          );
        },
      ),
    );
  }
}

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: _PromptStyleDrawer(controller: controller),
      appBar: AppBar(
        title: const Text('Resumo IA'),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.tune_rounded),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
              tooltip: 'Estilo do resumo',
            ),
          ),
          Obx(() => controller.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: controller.refresh,
                  tooltip: 'Atualizar',
                )),
        ],
      ),
      body: Obx(() => _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    final hasContent = controller.modelResponse.value != null;

    if (hasContent) {
      return _buildContent(context, isStreaming: controller.isLoading);
    }

    return switch (controller.status.value) {
      DashboardStatus.loading => _buildLoading(),
      DashboardStatus.error   => _buildError(context),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Consultando o modelo...'),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 48,
                color: isDark ? Colors.white38 : Colors.red),
            const SizedBox(height: 12),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: controller.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, {bool isStreaming = false}) {
    return RefreshIndicator(
      onRefresh: () async => controller.refresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMetaInfo(context),
          if (isStreaming) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 14, height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  'Gerando resumo...',
                  style: GoogleFonts.inter(fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white38 : Colors.black45),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          if (controller.modelResponse.value != null)
            RespostaIA(resposta: controller.modelResponse.value!.resposta),
        ],
      ),
    );
  }

  Widget _buildMetaInfo(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.white38 : Colors.black45;
    final updated = controller.lastUpdated.value;

    return Row(
      children: [
        Icon(Icons.schedule, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          updated != null
              ? 'Atualizado às ${_formatTime(updated)}'
              : 'Carregando...',
          style: GoogleFonts.inter(fontSize: 12, color: color),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.picture_as_pdf, size: 18),
          color: color,
          tooltip: 'Baixar PDF',
          // Corrigido: passando string do modelo ou vazio
          onPressed: () => PdfService().generateDashboardPdf(
            controller.modelResponse.value?.resposta ?? '', 
            updated
          ),
        ),
        Icon(Icons.speed, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          controller.responseTime.value,
          style: GoogleFonts.inter(fontSize: 12, color: color),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

class _PromptStyleDrawer extends StatelessWidget {
  final DashboardController controller;
  const _PromptStyleDrawer({required this.controller});

  // ── SYSTEM PROMPTS ────────────────────────────────────────────
  static const _executivo24h = r'''### TÍTULO: Relatório Executivo — Panorama Geral das Últimas 24h

### OBJETIVO:
Gerar um resumo executivo claro e direto do estado operacional da unidade armazenadora nas últimas 24 horas. O relatório deve destacar os números mais importantes, alertas críticos e recomendações imediatas para o gestor.

### INSTRUÇÕES PARA O LLM:
1. Analise os dados de resumo_operacional e apresente os principais indicadores de forma destacada.
2. Liste os alertas que exigem ação imediata (prioridade: processo pausado > silo crítico > lote parado).
3. Identifique gargalos visíveis: muitos processos pausados, secadores indisponíveis, silos próximos do limite.
4. Se houver dados de telemetria nos sensores, mencione leituras atípicas (temperatura elevada, umidade crítica).
5. Encerre com 1-3 recomendações objetivas para o gestor.
6. Use linguagem direta, bullet points e seções claras.
7. Nao utilize emojis, emoticons ou caracteres especiais. Use apenas texto simples com marcadores (-, *, #).

### FORMATO DE SAIDA ESPERADO:
RELATORIO EXECUTIVO — {DATA_REFERENCIA}

## RESUMO DO PERIODO
- Processos ativos: {X} | Finalizados hoje: {Y}
- Secadores disponiveis: {X} | Em manutencao: {Y}
- Silos disponiveis: {X} | Ocupacao media: {Y}%
- Grao armazenado: {X.XXX} kg
- Sensores ativos: {X}

## ALERTAS CRITICOS
- {alerta mais grave}
- {alerta secundario}

## GARGALOS IDENTIFICADOS
- {descricao do gargalo}

## RECOMENDACOES
1. {recomendacao 1}
2. {recomendacao 2}''';

  static const _custosSecagem = r'''### TITULO: Relatorio de Custos de Secagem — Analise Financeira Detalhada

### OBJETIVO:
Produzir uma analise financeira completa dos custos de secagem, cruzando dados de processos finalizados, secadores utilizados e custos operacionais.

### INSTRUCOES PARA O LLM:
1. Apresente o custo total do periodo e o breakdown percentual (combustivel, energia, mao-de-obra, manutencao, depreciacao).
2. Calcule o custo medio por hora e por tonelada processada.
3. Compare o desempenho entre secadores disponiveis.
4. Identifique processos com custo muito acima da media e sugira investigacao.
5. Inclua projecao do custo acumulado no mes.
6. Nao utilize emojis, emoticons ou caracteres especiais. Use apenas texto simples com marcadores (-, *, #).

### FORMATO DE SAIDA ESPERADO:
RELATORIO DE CUSTOS DE SECAGEM

## CUSTO TOTAL DO PERIODO: R$ {X.XXX,XX}
- Combustivel: R$ {X} ({Y}%)
- Energia: R$ {X} ({Y}%)
- Mao-de-obra: R$ {X} ({Y}%)
- Manutencao: R$ {X} ({Y}%)
- Depreciacao: R$ {X} ({Y}%)

## CUSTOS MEDIOS
- Custo medio / hora: R$ {X,XX}
- Custo medio / tonelada: R$ {X,XX}

## COMPARATIVO ENTRE SECADORES
| Secador | Tipo | Combustivel | Custo/h | Horas | Custo total |

## PROCESSOS FORA DA CURVA
- {lote}: custo {X}% acima da media

## PROJECAO MENSAL
- Custo acumulado: R$ {X} | Projecao: R$ {Y} | Orcamento vs realizado: {+/-} {Z}%''';

  static const _saudeLotes = r'''### TITULO: Relatorio de Saude dos Lotes — Risco, Qualidade e Tempo de Estoque

### OBJETIVO:
Analisar todos os lotes ativos na unidade armazenadora, identificando riscos de deterioracao, lotes parados, umidade fora do padrao e necessidade de intervencao.

### INSTRUCOES PARA O LLM:
1. Classifique os lotes por nivel de risco:
   - RISCO ALTO: >45 dias sem finalizar OU umidade inicial >16%
   - RISCO MEDIO: 30-45 dias OU umidade entre 14-16%
   - RISCO BAIXO: <30 dias E umidade <14%
2. Liste lotes que deveriam ter passado por secagem mas nao tem processo associado.
3. Calcule a quebra tecnica dos lotes que passaram por secagem.
4. Agrupe por cultura e safra para visao consolidada.
5. Encerre com recomendacoes priorizadas por risco.
6. Nao utilize emojis, emoticons ou caracteres especiais. Use apenas texto simples com marcadores (-, *, #).

### FORMATO DE SAIDA ESPERADO:
RELATORIO DE SAUDE DOS LOTES

## LOTES SEGUROS (RISCO BAIXO) — {X} lotes
## ATENCAO (RISCO MEDIO) — {Y} lotes
## CRITICOS (RISCO ALTO) — {Z} lotes

## QUEBRA TECNICA NA SECAGEM
- Media geral: {X}% | Maior quebra: {Y}% | Menor quebra: {W}%

## RESUMO POR CULTURA
| Cultura | Lotes | Volume | Umidade media | Dias medio |

## RECOMENDACOES
1. {prioridade maxima} 2. {prioridade media} 3. {prioridade baixa}''';

  static const _ocupacao = r'''### TITULO: Relatorio de Ocupacao e Capacidade de Armazenagem

### OBJETIVO:
Fornecer visao completa da capacidade de armazenagem: ocupacao atual dos silos, tendencia, projecao de saturacao e recomendacoes.

### INSTRUCOES PARA O LLM:
1. Apresente o panorama geral: capacidade total vs ocupada.
2. Classifique cada silo por faixa de ocupacao (CRITICO >90%, ALERTA 75-90%, OK 50-75%, FOLGA <50%).
3. Estime a tendencia de ocupacao (subindo/estavel/descendo).
4. Projete dias até saturacao total com base no ritmo atual.
5. Identifique silos disponiveis para novos lotes.
6. Nao utilize emojis, emoticons ou caracteres especiais. Use apenas texto simples com marcadores (-, *, #).

### FORMATO DE SAIDA ESPERADO:
RELATORIO DE OCUPACAO — CAPACIDADE DE ARMAZENAGEM

## PANORAMA GERAL
- Capacidade total: {X} | Ocupado: {Y} ({Z}%) | Disponivel: {W}

## SILOS CRITICOS (>90%) | SILOS EM ALERTA (75-90%) | SILOS DISPONIVEIS (<50%)

## TENDENCIA E PROJECAO
- Saldo diario: {+/- Z} kg/dia | Dias até saturacao: {W} dias

## RECOMENDACOES
1. {rotacao de estoque} 2. {priorizar saida} 3. {avaliar expansao}''';

  static const _gargalos = r'''### TITULO: Relatorio de Gargalos Operacionais — Diagnostico de Fluxo

### OBJETIVO:
Diagnosticar gargalos no fluxo de beneficiamento, cruzando dados de processos, secadores, silos e lotes para identificar travamentos.

### INSTRUCOES PARA O LLM:
1. Identifique onde está o gargalo principal:
   a) Processos pausados (o que está travando?)
   b) Secadores ocupados vs disponiveis (fila de secagem?)
   c) Silos cheios (impedindo recebimento?)
   d) Lotes parados sem processo associado
2. Calcule o tempo medio de espera entre etapas.
3. Mapeie o fluxo: RECEPCAO → SECAGEM → ARMAZENAMENTO → EXPEDICAO
4. Sugira acoes especificas para destravar cada gargalo.
5. Nao utilize emojis, emoticons ou caracteres especiais. Use apenas texto simples com marcadores (-, *, #).

### FORMATO DE SAIDA ESPERADO:
RELATORIO DE GARGALOS OPERACIONAIS

## DIAGNOSTICO DO FLUXO
### 1. RECEPCAO | 2. SECAGEM | 3. ARMAZENAMENTO | 4. EXPEDICAO

## INDICADORES DE FLUXO
- Tempo medio entrada→secagem: {X}h | secagem→armazenamento: {Y}h
- Throughput diario: {W} kg/dia

## GARGALO PRINCIPAL: {etapa} — {descricao}

## ACOES CORRETIVAS
1. {acao 1} 2. {acao 2} 3. {acao 3}''';

  static const _presets = [
    _PromptPreset(
      Icons.assignment_returned_rounded,
      'Relatorio Executivo 24h',
      'Panorama geral da unidade com alertas e recomendacoes',
      'RESUMO DO PERIODO • ALERTAS CRITICOS • GARGALOS • RECOMENDACOES',
      _executivo24h,
    ),
    _PromptPreset(
      Icons.monetization_on_rounded,
      'Relatorio de Custos de Secagem',
      'Analise financeira detalhada por processo e secador',
      r'CUSTO TOTAL: R$ • COMPARATIVO SECADORES • PROJECAO MENSAL',
      _custosSecagem,
    ),
    _PromptPreset(
      Icons.biotech_rounded,
      'Relatorio de Saude dos Lotes',
      'Risco, qualidade e tempo de estoque dos lotes',
      'LOTES SEGUROS • ATENCAO • CRITICOS • QUEBRA TECNICA',
      _saudeLotes,
    ),
    _PromptPreset(
      Icons.inventory_rounded,
      'Relatorio de Ocupacao e Capacidade',
      'Ocupacao dos silos, tendencia e projecao de saturacao',
      'PANORAMA GERAL • SILOS CRITICOS • PROJECAO',
      _ocupacao,
    ),
    _PromptPreset(
      Icons.bug_report_rounded,
      'Relatorio de Gargalos Operacionais',
      'Diagnostico completo do fluxo de beneficiamento',
      'RECEPCAO → SECAGEM → ARMAZENAMENTO → EXPEDICAO',
      _gargalos,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Drawer(
      width: 420,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.tune_rounded,
                            color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Estilo do Resumo',
                        style: GoogleFonts.outfit(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Escolha o foco da análise',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  for (final preset in _presets) ...[
                    Obx(() {
                      final isActive =
                          controller.systemPrompt.value == preset.prompt;
                      return Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            controller.applyPrompt(preset.prompt);
                            Navigator.of(context).pop();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isActive
                                    ? AppColors.primary
                                    : (isDark ? Colors.white12 : Colors.black12),
                                width: isActive ? 2 : 1,
                              ),
                              color: isActive
                                  ? AppColors.primary.withOpacity(0.08)
                                  : null,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(preset.icon,
                                          color: AppColors.primary, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            preset.title,
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            preset.description,
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isActive)
                                      const Icon(Icons.check_circle,
                                          size: 18, color: AppColors.primary),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  preset.example,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.black45,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                  ],
                  Obx(() {
                    final isEmpty = controller.systemPrompt.value.isEmpty;
                    final isCustom = !isEmpty && !_presets.any(
                        (p) => p.prompt == controller.systemPrompt.value);
                    return Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _showCustomPrompt(context),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isCustom
                                  ? AppColors.primary
                                  : (isDark ? Colors.white12 : Colors.black12),
                              width: isCustom ? 2 : 1,
                            ),
                            color: isCustom
                                ? AppColors.primary.withOpacity(0.08)
                                : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.edit,
                                    color: AppColors.primary, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Personalizado',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Escreva seu próprio prompt',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isEmpty || isCustom)
                                Icon(Icons.check_circle,
                                    size: 18,
                                    color: isCustom
                                        ? AppColors.primary
                                        : Colors.transparent),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    controller.applyPrompt('');
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.clear, size: 18),
                  label: const Text('Usar padrão da API'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomPrompt(BuildContext context) async {
    final textController =
        TextEditingController(text: controller.systemPrompt.value);
    final result = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Prompt Personalizado',
                style: GoogleFonts.outfit(
                    fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'Digite o system prompt personalizado...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: GoogleFonts.inter(fontSize: 14),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Get.back(result: true),
                    child: const Text('Salvar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true) {
      final prompt = textController.text.trim();
      controller.applyPrompt(prompt);
      if (context.mounted) Navigator.of(context).pop();
    }
    textController.dispose();
  }
}

class _PromptPreset {
  final IconData icon;
  final String title;
  final String description;
  final String example;
  final String prompt;

  const _PromptPreset(this.icon, this.title, this.description, this.example, this.prompt);
}
