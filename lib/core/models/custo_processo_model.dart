import 'processo_model.dart';
import 'batch_model.dart';
import 'secador_model.dart';

class CustoProcessoModel {
  final ProcessoModel processo;
  final BatchModel? lote;
  final SecadorModel? secador;

  CustoProcessoModel({
    required this.processo,
    this.lote,
    this.secador,
  });
}
