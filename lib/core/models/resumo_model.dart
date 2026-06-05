import 'dart:convert';

class ResumoModel {
  final String resposta;

  const ResumoModel({required this.resposta});
}

// Extensão moderna para lidar com o JSON
extension ResumoModelX on ResumoModel {
  static ResumoModel fromJson(Map<String, dynamic> json) {
    dynamic rawResposta = json['resposta'];
    String textoFinal = 'Nenhum resumo disponível.';

    if (rawResposta is String) {
      // 1. Tentar remover possíveis escapes excessivos se for uma string JSON
      String limpo = rawResposta.replaceAll('\\n', '\n').replaceAll('\\"', '"');
      
      // 2. Se a string parece ser um JSON, tentar decodificar o conteúdo
      try {
        if (limpo.trim().startsWith('{')) {
          final nested = jsonDecode(limpo);
          if (nested is Map && nested.containsKey('text')) {
             textoFinal = nested['text'].toString();
          } else {
             textoFinal = limpo;
          }
        } else {
          textoFinal = limpo;
        }
      } catch (e) {
        textoFinal = limpo;
      }
    } else if (rawResposta != null) {
      textoFinal = rawResposta.toString();
    }

    return ResumoModel(
      resposta: textoFinal,
    );
  }
}
