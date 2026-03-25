# 🌱 Smart Secagem | Aeração Inteligente 2.0

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart)
![GetX](https://img.shields.io/badge/GetX-State_Management-FF2D55?style=for-the-badge&logo=flutter)

O **Smart Secagem** é uma plataforma inovadora e completa em Flutter voltada para o monitoramento e automação do pós-colheita agrícola. Ele atua transformando a gestão tradicional de silos e grãos de uma atividade manual e reativa para um processo **inteligente, autônomo e preditivo**.

---

## 🚀 Sobre o Projeto

Garantir a qualidade do grão armazenado (Massa Estável) minimiza perdas biológicas e maximiza o lucro da colheita. O Smart Secagem foi concebido para entregar uma experiência premium a produtores agrícolas, integrando uma Landing Page imersiva com um Dashboard restrito e um **Assistente de Inteligência Artificial**, focado em **equilíbrio higroscópico**, métricas térmicas (Delta T) e pontos de orvalho.

### 🎯 Principais Objetivos
- Reduzir dores de cabeça com controle manual dos aeradores e exaustores.
- Evitar consumo exagerado de energia ao ligar motores apenas em condições climáticas absolutamente ideais.
- Entregar um diagnóstico preventivo e seguro sobre a saúde da massa de grãos 24 horas por dia.

---

## 🛠️ Tecnologias Utilizadas

O desenvolvimento segue as melhores práticas para escalabilidade e design responsivo, suportando perfeitamente Web, Desktop e Mobile com interfaces fluídas e adaptativas ao "Dark/Light Mode".

- **Framework:** Flutter (Web/Mobile/Desktop)
- **Linguagem:** Dart
- **State Management & Routing:** GetX (`get`)
- **Storage Local:** GetStorage (`get_storage`)
- **Tipografia:** Google Fonts (`google_fonts`)
- **Arquitetura:** MVC Modificado (Focado em Módulos & Responsabilidade Única com Bindings do GetX)

---

## 🎨 Arquitetura de Módulos (Features)

A aplicação foi rigorosamente dividida em módulos escaláveis:

*   🌐 **Landing Page Responsiva:** Portfólio de funcionalidades, precificação e informações institucionais, integrando redirecionamento inteligente.
*   🛤️ **Onboarding Interativo:** Fluxo educacional projetado em *cards e ilustrações* voltadas ao Agro que explicam a importância da aeração inteligente antes do usuário realizar o primeiro acesso. Redirecionamento de sessão em cache (One-time viewing).
*   🔐 **Login Premium:** Autenticação limpa com validação UI/UX avançada.
*   📊 **Dashboard Central (Área Restrita):** Container mestre contendo navegação unificada por Drawer Lateral para acessar:
    *   **Gestão de Silos**: Parametrização dos silos da fazenda.
    *   **Dispositivos**: Hubs, estações meteorológicas e termo-sensores.
    *   **Notificações**: Central de alertas e métricas.
    *   **Centro de Suporte (Lógica Avançada)**: Acervo educacional nativo explicando os pilares biológicos da Inteligência de Aeração do sistema.
    *   **Meu Perfil**: Gestão restrita de dados cadastrais e opções ativas em UI (2FA, Nível de Acesso e Alertas).
    *   **Configurações do Sistema**: Troca de esquemas de Cores, Dark/Light mode dinâmico global.
*   🧠 **Smart Sense IA:** Painel demonstrativo do motor lógico avançado focado na previsão preditiva de até 48h de hotspots e otimização total de gasto energético.

---

## 📂 Estrutura de Pastas

A organização em árvore reflete a separação de escopos e injeção de dependência via Bindings:

```text
lib/
├── core/                   # Utilitários, Tema e Cores globais
│   ├── theme/app_theme.dart
│   └── values/app_colors.dart
├── modules/                # Módulos Funcionais Exclusivos (MVC)
│   ├── home/               # Painel Dashboard, Sidebar e Rotting Interno
│   ├── landing/            # Landing Page Comercial
│   ├── login/              # Interface de Acesso
│   ├── onboarding/         # Onboarding do App 
│   ├── profile/            # Gestão Pessoal e 2FA 
│   ├── settings/           # Personalização Visual e Configurações
│   ├── smart_sense_ia/     # Painel de Otimização Analítica (Motor IA)
│   └── support/            # Onboarding Técnico (Regras de aeração)
├── routes/                 # Registro e Padronização das Rotas (GetPage)
│   ├── app_pages.dart
│   └── app_routes.dart
└── main.dart               # Ponto Inicial, Bootstrapping de Injeções e GetMaterialApp
```

---

## ⚙️ Como Executar o Projeto

**1. Clone o repositório:**
```bash
git clone https://github.com/SeuUsuario/projeto_smart_secagem.git
cd projeto_smart_secagem
```

**2. Instale as dependências:**
```bash
flutter pub get
```

**3. Teste o projeto rodando na Web (Chrome):**
```bash
flutter run -d chrome
```

---

## 📝 Próximos Passos e Integrações Planejadas
- Conexão do módulo `Smart Sense IA` diretamente com a API do **Gemini 1.5 Flash (Google Generative AI)** para geração de laudos em linguagem natural.
- Migração de estado mockado para chamadas reais de backend APIs/WebSockets lidando com sensores na fazenda.

---

**Desenvolvido com dedicação para a Revolução do Agro-Tech.** 🌱
