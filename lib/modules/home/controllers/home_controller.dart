import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../core/services/auth_service.dart';

class HomeController extends GetxController {
  final selectedIndex = 0.obs;

  // Variáveis da IA do Dashboard
  final isAnalyzing = true.obs;
  
  final aiSummary = 'Analisando os trilhões de dados da sua planta...'.obs;
  
  final activeAlerts = <Map<String, dynamic>>[].obs;
  
  final kpiPredictions = <Map<String, dynamic>>[].obs;
  
  final chatMessages = <Map<String, dynamic>>[
    {
      'isUser': false,
      'text': 'Olá! Sou a Sense IA de controle da sua Dashboard. As condições térmicas estão estáveis. Como posso ajudar com sua operação hoje?'
    }
  ].obs;
  
  final chatController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    analyzeData();
  }

  void analyzeData() async {
    isAnalyzing.value = true;
    await Future.delayed(const Duration(seconds: 2));
    
    aiSummary.value = 'Bom dia, Alexandre. A sua planta está 100% operacional. Durante a noite, detectei uma queda de temperatura externa e ativei automaticamente a aeração no Silo 2, economizando cerca de R\$ 45,00 em energia fora de horário de pico. A previsão climática demanda atenção preventiva.';
    
    activeAlerts.assignAll([
      {
        'title': 'Atenção Preventiva de Secagem',
        'description': 'A previsão para os próximos 3 dias é de muita umidade relativa do ar. Recomendo focar a secagem preventiva no Silo 1. Clique para enviar comando para a gestão.',
        'color': Colors.orange,
        'icon': Icons.water_drop_rounded,
      }
    ]);
    
    kpiPredictions.assignAll([
      {
        'title': 'Previsão de Umidade (48h)',
        'value': '13.8%',
        'status': 'Silo 1 Estável',
        'icon': Icons.grain_rounded,
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'Projeção de Custo Energético',
        'value': '-12%',
        'status': 'Otimizado',
        'icon': Icons.electric_bolt_rounded,
        'color': const Color(0xFF3B82F6),
      }
    ]);
    
    isAnalyzing.value = false;
  }

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    chatMessages.add({
      'isUser': true,
      'text': text,
    });
    chatController.clear();
    
    await Future.delayed(const Duration(seconds: 1));
    
    chatMessages.add({
      'isUser': false,
      'text': 'Analisando o histórico de umidade e os gráficos do Silo...'
    });

    await Future.delayed(const Duration(seconds: 2));

    chatMessages.removeLast(); // Remove the "thinking" message

    chatMessages.add({
      'isUser': false,
      'text': 'Aqui está: A umidade no Silo 1 estava em 14%. O risco de fungos aumentou devido às chuvas, mas a nossa compensação com os exaustores de teto já dissipou o foco de calor. Recomendo mantermos assim por 48 horas.'
    });
  }

  final RxMap<String, dynamic> userData = RxMap<String, dynamic>({
    'name': 'Alexandre Dias',
    'email': 'alexandre.dias@empresa.com',
    'role': 'Administrador',
    'avatar': 'AD',
  });

  final notifications = <Map<String, dynamic>>[
    {
      'id': 1,
      'title': 'Novo usuário cadastrado',
      'time': '2 min atrás',
      'read': false,
      'icon': Icons.person_add_rounded,
      'color': Colors.blue
    },
    {
      'id': 2,
      'title': 'Pagamento aprovado - R\$ 2.450,00',
      'time': '15 min atrás',
      'read': false,
      'icon': Icons.payment_rounded,
      'color': Colors.green
    },
    {
      'id': 3,
      'title': 'Chamado de suporte resolvido',
      'time': '1 hora atrás',
      'read': true,
      'icon': Icons.support_agent_rounded,
      'color': Colors.orange
    },
    {
      'id': 4,
      'title': 'Backup automático concluído',
      'time': '3 horas atrás',
      'read': true,
      'icon': Icons.backup_rounded,
      'color': Colors.purple
    },
  ].obs;

  final stats = <Map<String, dynamic>>[
    {
      'title': 'Total de Usuários',
      'value': '1,847',
      'subtitle': '+12% este mês',
      'icon': Icons.people_alt_rounded,
      'color': const Color(0xFF3B82F6),
      'gradient': [
        const Color(0xFF3B82F6).withOpacity(0.15),
        const Color(0xFF3B82F6).withOpacity(0.05)
      ],
    },
    {
      'title': 'Receita Mensal',
      'value': 'R\$ 127.450',
      'subtitle': '+8.2% vs mês anterior',
      'icon': Icons.trending_up_rounded,
      'color': const Color(0xFF10B981),
      'gradient': [
        const Color(0xFF10B981).withOpacity(0.15),
        const Color(0xFF10B981).withOpacity(0.05)
      ],
    },
    {
      'title': 'Chamados Abertos',
      'value': '23',
      'subtitle': '5 urgentes',
      'icon': Icons.support_agent_rounded,
      'color': const Color(0xFFF59E0B),
      'gradient': [
        const Color(0xFFF59E0B).withOpacity(0.15),
        const Color(0xFFF59E0B).withOpacity(0.05)
      ],
    },
    {
      'title': 'Taxa de Conversão',
      'value': '34.8%',
      'subtitle': '+2.4% esta semana',
      'icon': Icons.speed_rounded,
      'color': const Color(0xFF8B5CF6),
      'gradient': [
        const Color(0xFF8B5CF6).withOpacity(0.15),
        const Color(0xFF8B5CF6).withOpacity(0.05)
      ],
    },
  ].obs;

  final recentActivities = <Map<String, dynamic>>[
    {
      'id': 1,
      'action': 'Novo usuário cadastrado',
      'user': 'Marina Santos',
      'module': 'Usuários',
      'time': '2 min atrás',
      'avatar': 'MS',
      'color': Colors.blue
    },
    {
      'id': 2,
      'action': 'Assinatura premium renovada',
      'user': 'Ricardo Oliveira',
      'module': 'Financeiro',
      'time': '12 min atrás',
      'avatar': 'RO',
      'color': Colors.green
    },
    {
      'id': 3,
      'action': 'Chamado #452 criado',
      'user': 'Fernanda Lima',
      'module': 'Suporte',
      'time': '25 min atrás',
      'avatar': 'FL',
      'color': Colors.orange
    },
    {
      'id': 4,
      'action': 'Relatório mensal gerado',
      'user': 'Sistema',
      'module': 'Relatórios',
      'time': '1 hora atrás',
      'avatar': 'SI',
      'color': Colors.purple
    },
    {
      'id': 5,
      'action': 'Pagamento recusado',
      'user': 'Carlos Mendes',
      'module': 'Financeiro',
      'time': '2 horas atrás',
      'avatar': 'CM',
      'color': Colors.red
    },
    {
      'id': 6,
      'action': 'Usuário bloqueado por segurança',
      'user': 'Sistema',
      'module': 'Segurança',
      'time': '3 horas atrás',
      'avatar': 'SE',
      'color': Colors.red
    },
    {
      'id': 7,
      'action': 'Configuração atualizada',
      'user': 'Administrador',
      'module': 'Configurações',
      'time': '4 horas atrás',
      'avatar': 'AD',
      'color': Colors.blue
    },
  ].obs;

  final topSellingProducts = <Map<String, dynamic>>[
    {
      'name': 'Plano Enterprise',
      'sales': 156,
      'revenue': 'R\$ 46.800',
      'growth': '+15%'
    },
    {
      'name': 'Plano Professional',
      'sales': 98,
      'revenue': 'R\$ 19.600',
      'growth': '+8%'
    },
    {
      'name': 'Consultoria UI/UX',
      'sales': 34,
      'revenue': 'R\$ 17.000',
      'growth': '+22%'
    },
    {
      'name': 'Integração API',
      'sales': 28,
      'revenue': 'R\$ 14.000',
      'growth': '+5%'
    },
  ].obs;

  final supportTickets = <Map<String, dynamic>>[
    {
      'id': '#452',
      'subject': 'Erro na exportação de PDF',
      'status': 'urgent',
      'priority': 'urgent',
      'user': 'Fernanda Lima',
      'date': '2024-01-19',
      'responses': 0
    },
    {
      'id': '#451',
      'subject': 'Dúvida sobre integração',
      'status': 'open',
      'priority': 'high',
      'user': 'Marina Santos',
      'date': '2024-01-19',
      'responses': 2
    },
    {
      'id': '#450',
      'subject': 'Problema de login',
      'status': 'in_progress',
      'priority': 'high',
      'user': 'Ricardo Oliveira',
      'date': '2024-01-18',
      'responses': 4
    },
    {
      'id': '#449',
      'subject': 'Sugestão de funcionalidade',
      'status': 'open',
      'priority': 'low',
      'user': 'Carlos Mendes',
      'date': '2024-01-18',
      'responses': 1
    },
  ].obs;

  final monthlyRevenue = <Map<String, dynamic>>[
    {'month': 'Jul', 'value': 85000},
    {'month': 'Ago', 'value': 92000},
    {'month': 'Set', 'value': 88000},
    {'month': 'Out', 'value': 105000},
    {'month': 'Nov', 'value': 118000},
    {'month': 'Dez', 'value': 127450},
  ].obs;

  void changePage(int index) {
    selectedIndex.value = index;
  }

  void logout() async {
    final authService = Get.find<AuthService>();
    await authService.logout();
    Get.offAllNamed(Routes.login);
  }

  String getStatusText(String status) {
    switch (status) {
      case 'open':
        return 'Aberto';
      case 'in_progress':
        return 'Em Andamento';
      case 'closed':
        return 'Fechado';
      case 'urgent':
        return 'Urgente';
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'open':
        return Colors.green;
      case 'in_progress':
        return Colors.orange;
      case 'closed':
        return Colors.grey;
      case 'urgent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getPriorityText(String priority) {
    switch (priority) {
      case 'low':
        return 'Baixa';
      case 'normal':
        return 'Normal';
      case 'high':
        return 'Alta';
      case 'urgent':
        return 'Urgente';
      default:
        return priority;
    }
  }

  Color getPriorityColor(String priority) {
    switch (priority) {
      case 'low':
        return Colors.green;
      case 'normal':
        return Colors.blue;
      case 'high':
        return Colors.orange;
      case 'urgent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
