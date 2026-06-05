class ResumoModel {
  final String resposta;

  const ResumoModel({required this.resposta});
}

// Extensão moderna para lidar com o JSON
extension ResumoModelX on ResumoModel {
  static ResumoModel fromJson(Map<String, dynamic> json) {
    // A limpeza de caracteres escapados é feita aqui, garantindo que o objeto
    // já seja criado com o texto pronto para ser exibido.
    final rawResposta = json['resposta'] as String? ?? 'Nenhum resumo disponível.';
    return ResumoModel(
      resposta: rawResposta.replaceAll('\\n', '\n').replaceAll('\\"', '"'),
    );
  }
}
