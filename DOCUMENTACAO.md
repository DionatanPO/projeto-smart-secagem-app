# Documentação de Software — Smart Secagem

---

## 1. Controle do Documento

| Versão | Data       | Autor     | Descrição                     |
|--------|------------|-----------|-------------------------------|
| 1.0    | 28/05/2026 | —         | Versão inicial da documentação |

---

## 2. Introdução

### 2.1. Propósito do Sistema

O **Smart Secagem** é uma plataforma multiplataforma desenvolvida em Flutter para monitoramento e automação do pós-colheita agrícola. O sistema transforma a gestão tradicional de silos e grãos — antes manual e reativa — em um processo inteligente, autônomo e preditivo, focado no equilíbrio higroscópico dos grãos armazenados.

### 2.2. Objetivos de Negócio

- Reduzir perdas biológicas durante o armazenamento de grãos
- Otimizar o consumo energético dos aeradores e exaustores
- Automatizar a aeração com base em dados climáticos em tempo real
- Oferecer diagnóstico preventivo sobre a massa de grãos 24h/dia
- Gerar laudos técnicos de conservação para valorização do produto

### 2.3. Público-Alvo

- Produtores rurais
- Gerentes de armazéns e silos
- Operadores de unidades de beneficiamento de grãos
- Técnicos agrícolas

---

## 3. Arquitetura do Sistema

### 3.1. Visão Geral

```
+-------------------+       +--------------------+       +--------------------+
|                   |       |                    |       |                    |
|  Flutter App      |<----->|  Django REST API   |<----->|  PostgreSQL /      |
|  (Mobile/Web/     | HTTP  |  (drf)             |       |  Sensores IoT      |
|   Desktop)        |       |                    |       |                    |
|                   |       |  apismart.secagem-  |       |                    |
+-------------------+       |  digital.com/api/   |       +--------------------+
                            +--------------------+
```

### 3.2. Arquitetura do Frontend

O app segue uma **Arquitetura Modular baseada em GetX**, derivada do padrão MVC (Model-View-Controller), com as seguintes camadas:

```
┌─────────────────────────────────────────────┐
│                  Views                       │  Widgets Flutter (telas)
├─────────────────────────────────────────────┤
│                Controllers                   │  lógica de negócio + chamadas API
├─────────────────────────────────────────────┤
│                 Models                       │  entidades de domínio (DTOs)
├─────────────────────────────────────────────┤
│                Services                      │  HTTP (Dio), Auth, PDF
├─────────────────────────────────────────────┤
│               Core / Theme                   │  utils, cores, tema M3
└─────────────────────────────────────────────┘
```

#### Padrão por Módulo

Cada funcionalidade segue a estrutura:

```
module_name/
├── controllers/
│   └── module_name_controller.dart   # GetxController
├── views/
│   └── module_name_view.dart         # GetView<Controller>
├── bindings/
│   └── module_name_binding.dart      # Injeção de dependência
└── widgets/                          # (opcional) widgets reutilizáveis
```

### 3.3. Injeção de Dependência

Gerenciada pelo GetX:
- **Bindings**: registram controllers como lazy singletons
- **Get.put() / Get.find()**: acesso direto quando necessário
- **GetView\<T\>**: acesso automático ao controller via `controller`

### 3.4. Gerenciamento de Estado

Observáveis reativos do GetX:
- `.obs` — variáveis reativas
- `Obx(() => ...)` — reconstrução automática de widgets
- `RxList` / `RxBool` — listas e booleanos reativos

---

## 4. Stack Tecnológico

| Categoria         | Tecnologia                          | Versão  |
|-------------------|-------------------------------------|---------|
| Framework         | Flutter                             | 3.5.4   |
| Linguagem         | Dart                                | ^3.5.4  |
| State Management  | GetX                                | ^4.7.3  |
| HTTP Client       | Dio                                 | ^5.9.2  |
| Armazenamento     | flutter_secure_storage (tokens)     | ^10.0.0 |
| Armazenamento     | get_storage (settings)              | ^2.1.1  |
| Tipografia        | Google Fonts                        | ^6.3.0  |
| Gráficos          | fl_chart                            | 0.69.0  |
| Vídeo             | video_player                       | ^2.9.5  |
| 3D                | model_viewer_plus                   | ^1.9.2  |
| PDF               | pdf + printing                      | —       |
| Internacionalização| flutter_localizations              | SDK     |
| Backend           | Django REST Framework               | —       |

---

## 5. Estrutura do Projeto

```
projeto_smart_secagem/
├── android/
├── assets/
│   ├── images/
│   │   ├── hero_tractor.png
│   │   ├── trator.png
│   │   ├── produtores.png
│   │   ├── silos.png
│   │   ├── lotes.png
│   │   ├── amostras.png
│   │   ├── romaneios.png
│   │   └── login_bg_agro.png
│   ├── silo3d.glb
│   └── video.mp4
├── ios/
├── lib/
│   ├── main.dart                          # Ponto de entrada
│   ├── core/
│   │   ├── middlewares/
│   │   │   └── auth_middleware.dart       # Guard de rotas
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   ├── farm_model.dart
│   │   │   ├── silo_model.dart
│   │   │   ├── batch_model.dart
│   │   │   ├── sensor_model.dart
│   │   │   ├── secador_model.dart
│   │   │   ├── processo_model.dart
│   │   │   ├── cliente_model.dart
│   │   │   └── telemetry_model.dart
│   │   ├── services/
│   │   │   ├── api_service.dart           # Dio + interceptors
│   │   │   ├── auth_service.dart          # Login/logout/token
│   │   │   └── pdf_service.dart           # Relatórios PDF
│   │   ├── theme/
│   │   │   └── app_theme.dart             # Tema M3 light/dark
│   │   └── values/
│   │       └── app_colors.dart            # Paleta de cores
│   ├── routes/
│   │   ├── app_routes.dart                # Constantes de rota
│   │   └── app_pages.dart                 # Tabela de rotas GetPage
│   └── modules/
│       ├── landing/                       # Landing page (pública)
│       │   ├── controllers/
│       │   ├── views/                     # landing, features, about, contact, pricing
│       │   ├── bindings/
│       │   └── widgets/                   # web_nav_bar, web_footer, web_drawer
│       ├── login/                         # Autenticação
│       │   ├── controllers/
│       │   ├── views/
│       │   └── bindings/
│       ├── home/                          # Shell principal (pós-login)
│       │   ├── controllers/
│       │   ├── views/
│       │   └── bindings/
│       ├── dashboard/                     # Dashboard operacional
│       │   ├── controllers/
│       │   ├── views/
│       │   └── bindings/
│       ├── farm_management/               # CRUD fazendas
│       │   ├── controllers/
│       │   ├── views/
│       │   └── bindings/
│       ├── silo_management/               # CRUD silos + telemetria
│       │   ├── controllers/
│       │   └── views/
│       ├── silo_viewer/                   # Visualizador 3D
│       │   ├── views/
│       │   └── widgets/
│       ├── batch_management/              # CRUD lotes
│       │   ├── controllers/
│       │   ├── views/
│       │   └── bindings/
│       ├── secagem/                       # CRUD secadores
│       │   ├── controllers/
│       │   ├── views/
│       │   └── bindings/
│       ├── processos/                     # CRUD processos (atividades)
│       │   ├── controllers/
│       │   ├── views/
│       │   └── bindings/
│       ├── clientes/                      # CRUD clientes
│       │   ├── controllers/
│       │   ├── views/
│       │   └── bindings/
│       ├── devices/                       # CRUD sensores
│       │   ├── controllers/
│       │   ├── views/
│       │   └── widgets/
│       ├── access_management/             # Gestão de usuários
│       │   ├── controllers/
│       │   └── views/
│       ├── profile/                       # Perfil do usuário
│       │   ├── controllers/
│       │   ├── views/
│       │   └── bindings/
│       ├── settings/                      # Configurações do app
│       │   ├── controllers/
│       │   └── views/
│       ├── notifications/                 # Central de notificações
│       │   ├── controllers/
│       │   └── views/
│       ├── support/                       # Suporte técnico
│       │   ├── controllers/
│       │   ├── views/
│       │   └── bindings/
│       └── smart_sense_ia/                # Inteligência Artificial
│           ├── controllers/
│           ├── views/
│           └── bindings/
├── test/
│   └── widget_test.dart                   # Teste básico (legado)
├── pubspec.yaml
├── DOCUMENTACAO.md                        # Este documento
└── README.md
```

---

## 6. Modelos de Dados (Entidades)

### 6.1. User (`user_model.dart`)

| Campo        | Tipo     | Descrição                              |
|--------------|----------|----------------------------------------|
| id           | int?     | Identificador único                    |
| username     | String   | Nome de usuário                        |
| email        | String   | E-mail                                 |
| password     | String?  | Senha (apenas escrita)                 |
| accountType  | String   | super_admin / admin / operador / visualizador |
| isStaff      | bool     | Se é staff (legado)                    |
| firstName    | String   | Nome                                   |
| lastName     | String   | Sobrenome                              |
| telefone     | String?  | Telefone                               |
| farm         | int?     | Fazenda vinculada (operadores)         |

### 6.2. Farm (`farm_model.dart`)

| Campo       | Tipo     | Descrição                        |
|-------------|----------|----------------------------------|
| id          | int?     | Identificador único              |
| name        | String   | Nome da fazenda                  |
| location    | String?  | Localização                      |
| description | String?  | Descrição                        |
| owner       | int?     | ID do admin proprietário        |
| createdAt   | DateTime?| Data de criação                  |

### 6.3. Silo (`silo_model.dart`)

| Campo       | Tipo     | Descrição                    |
|-------------|----------|------------------------------|
| id          | int?     | Identificador único          |
| name        | String   | Nome do silo                 |
| farm        | int      | Fazenda vinculada            |
| farmName    | String?  | Nome da fazenda (read-only)  |
| capacity    | double?  | Capacidade (kg)              |
| status      | String   | Status                       |
| description | String?  | Descrição                    |
| sensorCount | int?     | Quantidade de sensores       |

### 6.4. Batch / Lote (`batch_model.dart`)

| Campo          | Tipo     | Descrição                    |
|----------------|----------|------------------------------|
| id             | int?     | Identificador único          |
| numeroLote     | String?  | Número do lote               |
| farm           | int      | Fazenda vinculada            |
| farmName       | String?  | Nome da fazenda (read-only)  |
| cultura        | String   | Cultura (ex: soja, milho)    |
| variedade      | String?  | Variedade                    |
| safra          | String   | Safra (ex: 2025/2026)        |
| pesoInicial    | double   | Peso inicial (kg)            |
| umidadeInicial | double   | Umidade inicial (%)          |
| dataEntrada    | DateTime?| Data de entrada              |
| pesoFinal      | double?  | Peso final (kg)              |
| umidadeFinal   | double?  | Umidade final (%)            |
| dataSaida      | DateTime?| Data de saída                |
| silo           | int?     | Silo vinculado               |
| siloName       | String?  | Nome do silo (read-only)     |
| cliente        | int?     | Cliente vinculado            |
| clienteNome    | String?  | Nome do cliente (read-only)  |
| status         | String   | Status do lote               |
| observacoes    | String?  | Observações                  |

### 6.5. Secador (`secador_model.dart`)

| Campo       | Tipo     | Descrição                    |
|-------------|----------|------------------------------|
| id          | int?     | Identificador único          |
| nome        | String   | Nome do secador              |
| tipo        | String   | Tipo (contínuo / intermitente / leito fixo) |
| capacidade  | String?  | Capacidade                   |
| fonteCalor  | String?  | Fonte de calor               |
| status      | String   | Status                       |
| farm        | int?     | Fazenda vinculada            |
| farmName    | String?  | Nome da fazenda (read-only)  |

### 6.6. Processo (`processo_model.dart`)

| Campo       | Tipo     | Descrição                        |
|-------------|----------|----------------------------------|
| id          | int?     | Identificador único              |
| tipo        | String   | secagem / resfriamento / aeração |
| lote        | int      | Lote vinculado                   |
| loteNumero  | String?  | Número do lote (read-only)       |
| secador     | int?     | Secador vinculado                |
| secadorNome | String?  | Nome do secador (read-only)      |
| silo        | int?     | Silo vinculado                   |
| siloNome    | String?  | Nome do silo (read-only)         |
| dataInicio  | DateTime?| Data de início                   |
| dataFim     | DateTime?| Data de fim                      |
| status      | String   | Pendente / Iniciada / Pausada / Finalizada / Cancelada |
| observacoes | String?  | Observações                      |

### 6.7. Sensor (`sensor_model.dart`)

| Campo        | Tipo     | Descrição                    |
|--------------|----------|------------------------------|
| id           | int?     | Identificador único          |
| gatewayId    | String   | ID do gateway/hardware       |
| description  | String?  | Descrição                    |
| farm         | int?     | Fazenda vinculada            |
| farmName     | String?  | Nome da fazenda (read-only)  |
| siloId       | int?     | Silo vinculado               |
| siloName     | String?  | Nome do silo (read-only)     |
| secador      | int?     | Secador vinculado            |
| secadorNome  | String?  | Nome do secador (read-only)  |
| status       | String   | ativo / inativo              |

### 6.8. Cliente (`cliente_model.dart`)

| Campo    | Tipo     | Descrição                    |
|----------|----------|------------------------------|
| id       | int?     | Identificador único          |
| nome     | String   | Nome completo                |
| email    | String?  | E-mail                       |
| telefone | String?  | Telefone                     |
| cpfCnpj  | String?  | CPF ou CNPJ                  |
| endereco | String?  | Endereço                     |
| farm     | int?     | Fazenda vinculada            |
| farmName | String?  | Nome da fazenda (read-only)  |
| createdAt| DateTime?| Data de cadastro             |

### 6.9. Telemetria (`telemetry_model.dart`)

| Campo       | Tipo     | Descrição                    |
|-------------|----------|------------------------------|
| id          | int?     | Identificador único          |
| sensor      | int      | Sensor vinculado             |
| temperatura | double   | Temperatura (°C)             |
| umidade     | double   | Umidade (%)                  |
| timestamp   | DateTime | Data/hora da leitura         |

### 6.10. Relacionamentos entre Entidades

```
User (super_admin / admin / operador / visualizador)
│
├── farm (FK) ────────► Farm (para operadores)
│
Farm
├── owner (FK) ───────► User (admin proprietário)
├── clientes ─────────► Cliente (relacionamento reverso)
│
Silo ── farm (FK) ───► Farm
│
Batch (Lote)
├── farm (FK) ────────► Farm
├── silo (FK) ────────► Silo
└── cliente (FK) ─────► Cliente
│
Secador ── farm (FK) ─► Farm
│
Processo
├── lote (FK) ────────► Batch
├── secador (FK) ─────► Secador
└── silo (FK) ────────► Silo
│
Sensor
├── farm (FK) ────────► Farm
├── silo_id (FK) ─────► Silo
└── secador (FK) ─────► Secador
│
Telemetria ── sensor ─► Sensor
│
Cliente ── farm (FK) ─► Farm
```

---

## 7. Endpoints da API

Base URL: `https://apismart.secagemdigital.com/api/`

| Método | Endpoint              | Descrição                     | Autenticação |
|--------|-----------------------|-------------------------------|--------------|
| POST   | `/api/login/`         | Autenticação (retorna token)  | Não          |
| POST   | `/api/logout/`        | Logout                        | Sim          |
| GET    | `/api/me/`            | Dados do usuário logado       | Sim          |
| GET    | `/api/usuarios/`      | Listar usuários               | Sim (admin)  |
| POST   | `/api/usuarios/`      | Criar usuário                 | Sim (admin)  |
| PATCH  | `/api/usuarios/{id}/` | Atualizar usuário             | Sim (admin)  |
| DELETE | `/api/usuarios/{id}/` | Excluir usuário               | Sim (admin)  |
| GET    | `/api/fazendas/`      | Listar fazendas               | Sim          |
| POST   | `/api/fazendas/`      | Criar fazenda                 | Sim (admin)  |
| PUT    | `/api/fazendas/{id}/` | Atualizar fazenda             | Sim (admin)  |
| DELETE | `/api/fazendas/{id}/` | Excluir fazenda               | Sim (admin)  |
| GET    | `/api/silos/`         | Listar silos                  | Sim          |
| POST   | `/api/silos/`         | Criar silo                    | Sim          |
| PUT    | `/api/silos/{id}/`    | Atualizar silo                | Sim          |
| DELETE | `/api/silos/{id}/`    | Excluir silo                  | Sim (admin)  |
| GET    | `/api/lotes/`         | Listar lotes                  | Sim          |
| POST   | `/api/lotes/`         | Criar lote                    | Sim          |
| PUT    | `/api/lotes/{id}/`    | Atualizar lote                | Sim          |
| DELETE | `/api/lotes/{id}/`    | Excluir lote                  | Sim (admin)  |
| GET    | `/api/secadores/`     | Listar secadores              | Sim          |
| POST   | `/api/secadores/`     | Criar secador                 | Sim          |
| PUT    | `/api/secadores/{id}/`| Atualizar secador             | Sim          |
| DELETE | `/api/secadores/{id}/`| Excluir secador               | Sim (admin)  |
| GET    | `/api/processos/`     | Listar processos              | Sim          |
| POST   | `/api/processos/`     | Criar processo                | Sim          |
| PUT    | `/api/processos/{id}/`| Atualizar processo            | Sim          |
| DELETE | `/api/processos/{id}/`| Excluir processo              | Sim (admin)  |
| GET    | `/api/clientes/`      | Listar clientes               | Sim          |
| POST   | `/api/clientes/`      | Criar cliente                 | Sim          |
| PUT    | `/api/clientes/{id}/` | Atualizar cliente             | Sim          |
| DELETE | `/api/clientes/{id}/` | Excluir cliente               | Sim (admin)  |
| GET    | `/api/sensores/`      | Listar sensores               | Sim          |
| POST   | `/api/sensores/`      | Criar sensor                  | Sim          |
| PUT    | `/api/sensores/{id}/` | Atualizar sensor              | Sim          |
| DELETE | `/api/sensores/{id}/` | Excluir sensor                | Sim (admin)  |
| GET    | `/api/telemetria/`    | Listar telemetrias            | Sim          |

---

## 8. Módulos da Interface

### 8.1. Landing Page (Pública)

**Arquivos:** `lib/modules/landing/`

Seção de apresentação do produto, composta por:
- **Hero**: vídeo fullscreen com overlay gradiente, título "A inteligência que seu grão precisa.", botões "Acessar Sistema" e "Conhecer Soluções" (scroll suave para seção de features)
- **Features**: 6 cards de funcionalidades (Algoritmo Inteligente, Alertas em Real-Time, Controle Remoto, Eficiência Energética, Visão Multi-camada, Histórico e Laudos)
- **CTA**: chamada para ação "Pronto para modernizar seu pós-colheita?"
- **Footer**: links institucionais e redes sociais

**Controller:** `LandingController`
- Inicializa vídeo (`VideoPlayerController.asset('assets/video.mp4')`)
- Loop, sem áudio
- `accessSystem()` → navega para `Routes.login`

### 8.2. Login

**Arquivos:** `lib/modules/login/`

Formulário de autenticação com:
- Campo de e-mail (validação de formato)
- Campo de senha (mínimo 6 caracteres, toggle de visibilidade)
- Botão "Entrar" com loading spinner
- Links: "Esqueceu a senha?", "Fale com o administrador"

**Controller:** `LoginController`
- `login()` → `POST /api/login/` → salva token via `AuthService` → redireciona para `Routes.home`

### 8.3. Home / Dashboard (Shell Principal)

**Arquivos:** `lib/modules/home/`

Container principal pós-login com:
- Sidebar / NavigationDrawer com itens dinâmicos
- Área de conteúdo que alterna entre módulos via `selectedIndex`
- Controle de acesso: item "Gestão de Acesso" (índice 7) visível apenas para `admin` e `super_admin`

**Controller:** `HomeController`
- `_getCurrentUser()` → `GET /api/me/` → define `accountType` e `currentUserFarmId`
- Getters: `isSuperAdmin`, `isAdmin`, `isOperator`, `isViewer`, `canManageUsers`
- `changePage(index)` — bloqueia página 7 para não-admins

### 8.4. Módulos de Gestão (CRUD)

Cada módulo segue o padrão:

| Módulo           | Controller + View                | Dependências              |
|------------------|----------------------------------|---------------------------|
| Fazendas         | `FarmManagement*`                | API: fazendas/            |
| Silos            | `SiloManagement*`                | FarmManagement, Batch, API: silos/ |
| Lotes            | `BatchManagement*`               | FarmManagement, API: lotes/ |
| Secadores        | `Secagem*`                       | FarmManagement, API: secadores/ |
| Processos        | `Processos*`                     | Batch, Secagem, API: processos/ |
| Clientes         | `Clientes*`                      | API: clientes/            |
| Dispositivos     | `Devices*`                       | API: sensores/, telemetria/ |
| Gestão de Acesso | `AccessManagement*`              | API: usuarios/, fazendas/ |

### 8.5. Perfil

**Arquivos:** `lib/modules/profile/`

Exibição e edição dos dados do usuário logado:
- Foto, nome, e-mail, telefone
- Nível de acesso (read-only)
- Preferências de notificação
- Links para suporte e configurações

**Controller:** `ProfileController`
- `getProfile()` → `GET /api/me/`
- `saveProfile()` → `PATCH /api/me/`

### 8.6. Configurações

**Arquivos:** `lib/modules/settings/`

- Alternância entre tema Claro / Escuro
- Seletor de cor primária (8 opções)
- Preferências persistidas via `GetStorage`

### 8.7. Smart Sense IA

**Arquivos:** `lib/modules/smart_sense_ia/`

Painel demonstrativo do motor de inteligência artificial focado em:
- Previsão preditiva de hotspots (até 48h)
- Otimização de gasto energético
- Geração de recomendações

### 8.8. Suporte

**Arquivos:** `lib/modules/support/`

Acervo educacional com explicações sobre:
- Equilíbrio higroscópico dos grãos
- Ponto de orvalho e Delta T
- Boas práticas de aeração
- Interpretação de métricas térmicas

---

## 9. Autenticação e Autorização

### 9.1. Fluxo de Autenticação

```
Usuário → LoginView → LoginController.login()
  → POST /api/login/ {username, password}
  → Response: {token: "..."}
  → AuthService salva token no FlutterSecureStorage
  → ApiService passa token no header Authorization: Token xxx
  → Redireciona para HomeView
```

### 9.2. Interceptor de Token

`ApiService` (Dio) possui um interceptor que:
- Injeta automaticamente o token em toda requisição
- Em caso de 401, chama `AuthService.logout()` e redireciona para login

### 9.3. Guarda de Rotas

`AuthMiddleware` (GetX middleware):
- Se `!authService.isAuthenticated.value`, redireciona para `Routes.login`

### 9.4. Níveis de Acesso

#### Super Admin (`super_admin`)

| Ação                                         | Permissão |
|----------------------------------------------|:---------:|
| CRUD qualquer dado (qualquer fazenda)        | ✅         |
| Criar super_admin / admin / operador / visualizador | ✅   |
| Gerenciar todos os usuários                 | ✅         |
| Excluir qualquer registro                    | ✅         |
| Ver todas as fazendas                        | ✅         |
| Acessar painel admin (is_superuser)          | ✅         |

#### Admin (`admin`)

| Ação                                                     | Permissão |
|----------------------------------------------------------|:---------:|
| CRUD dados das próprias fazendas (silos, lotes, secadores, processos, sensores, clientes) | ✅ |
| Excluir registros das próprias fazendas                  | ✅         |
| Criar operador / visualizador (vinculados às suas fazendas) | ✅      |
| Ver/gerenciar operadores e visualizadores das suas fazendas | ✅      |
| Criar admin ou super_admin                               | ❌         |
| Ver dados de outras fazendas                             | ❌         |
| Acessar permissões de superusuário                       | ❌         |

#### Operador (`operador`)

| Ação                                                   | Permissão |
|--------------------------------------------------------|:---------:|
| Ler dados da fazenda vinculada                         | ✅         |
| Criar/editar lotes, processos, secadores, sensores, clientes | ✅     |
| Excluir qualquer registro                              | ❌         |
| Gerenciar usuários                                     | ❌         |
| Ver dados de outras fazendas                           | ❌         |

#### Visualizador (`visualizador`)

| Ação                      | Permissão |
|---------------------------|:---------:|
| Ler dados da fazenda      | ✅         |
| Criar/editar/excluir      | ❌         |
| Gerenciar usuários        | ❌         |

### 9.5. Regras de Exclusão (UI)

Operadores e visualizadores não veem botões/menus de "Excluir" em nenhuma tela. O controle é feito via `Get.find<HomeController>().isAdmin` nos PopupMenuItems e action buttons.

---

## 10. Fluxos de Navegação

### 10.1. Público (sem autenticação)

```
/[landing] → /features → /about → /contact → /pricing
           → /login → (autenticado) → /home
```

### 10.2. Autenticado

```
/home
├── /dashboard (padrão)
├── /farm-management
├── /silo-management
├── /batch-management
├── /secagem
├── /processos
├── /clientes
├── /devices
├── /access-management (admin/super_admin apenas)
├── /profile
├── /settings
├── /notifications
├── /support
├── /smart-sense-ia
└── /silo-viewer
```

### 10.3. Mapa de Rotas

| Rota                     | Classe da View             | Middleware | Binding            |
|--------------------------|----------------------------|-----------|-------------------|
| `/`                      | `LandingView`              | —         | LandingBinding    |
| `/features`              | `FeaturesView`             | —         | LandingBinding    |
| `/about`                 | `AboutView`                | —         | LandingBinding    |
| `/contact`               | `ContactView`              | —         | LandingBinding    |
| `/pricing`               | `PricingView`              | —         | LandingBinding    |
| `/login`                 | `LoginView`                | —         | LoginBinding      |
| `/home`                  | `HomeView`                 | Auth      | HomeBinding       |
| `/support`               | `SupportView`              | Auth      | SupportBinding    |
| `/smart-sense-ia`        | `SmartSenseIAView`         | Auth      | SmartSenseIABinding|
| `/batch-management`      | `BatchManagementView`      | Auth      | BatchManagementBinding|
| `/secagem`               | `SecagemView`              | Auth      | SecagemBinding    |
| `/processos`             | `ProcessosView`            | Auth      | ProcessosBinding  |
| `/clientes`              | `ClientesView`             | Auth      | ClientesBinding   |

---

## 11. Tema e Personalização

### 11.1. Sistema de Cores

O app utiliza Material Design 3 com 8 variações de cor primária:

| Cor       | Hex (Light) | Hex (Dark)    |
|-----------|-------------|---------------|
| Verde     | `#2E7D52`   | `#4CAF50`     |
| Azul      | `#1565C0`   | `#42A5F5`     |
| Roxo      | `#6A1B9A`   | `#AB47BC`     |
| Laranja   | `#E65100`   | `#FF7043`     |
| Vermelho  | `#C62828`   | `#EF5350`     |
| Teal      | `#00695C`   | `#26A69A`     |
| Rosa      | `#AD1457`   | `#EC407A`     |
| Amarelo   | `#F9A825`   | `#FFEE58`     |

### 11.2. Tema Claro / Escuro

Gerenciado pelo `SettingsController` com persistência em `GetStorage`. O tema é aplicado globalmente via `GetMaterialApp.themeMode` e alternado dinamicamente.

### 11.3. Tipografia

- **Títulos:** Outfit (Google Font)
- **Corpo:** Inter (Google Font)
- Tamanhos e pesos variam conforme contexto (display, headline, body, label)

---

## 12. Configuração do Ambiente de Desenvolvimento

### 12.1. Pré-requisitos

- Flutter SDK ^3.5.4
- Dart SDK ^3.5.4
- Editor: VS Code (recomendado) ou Android Studio
- Git

### 12.2. Configuração Inicial

```bash
# Clone o repositório
git clone <url-do-repositorio>
cd projeto_smart_secagem

# Instale as dependências
flutter pub get

# Execute a análise estática
flutter analyze

# Execute os testes
flutter test

# Execute em desenvolvimento
flutter run -d chrome    # Web
flutter run -d windows   # Windows
flutter run              # Dispositivo conectado
```

### 12.3. Estrutura de Configuração da API

URL base configurada em `lib/core/services/api_service.dart`:

```dart
// Desenvolvimento (emulador Android)
baseUrl: 'http://localhost:8000/api/'

// Produção
baseUrl: 'https://apismart.secagemdigital.com/api/'
```

---

## 13. Build e Deploy

### 13.1. Web

```bash
flutter build web --release
# Saída: build/web/
```

### 13.2. Android

```bash
flutter build apk --release
# Saída: build/app/outputs/flutter-apk/app-release.apk

flutter build appbundle --release
# Saída: build/app/outputs/bundle/release/app-release.aab
```

### 13.3. iOS

```bash
flutter build ios --release
# Saída: build/ios/iphoneos/Runner.app
```

### 13.4. Windows

```bash
flutter build windows --release
# Saída: build/windows/runner/Release/
```

### 13.5. Linux

```bash
flutter build linux --release
# Saída: build/linux/x64/release/bundle/
```

---

## 14. Testes

### 14.1. Testes Unitários e de Widget

```bash
flutter test
```

Atualmente o projeto possui apenas um teste básico em `test/widget_test.dart` (legado, referenciava `MyApp` que não existe mais — deve ser atualizado).

### 14.2. Análise Estática

```bash
flutter analyze
```

---

## 15. Considerações de Segurança

- Token de autenticação armazenado em `flutter_secure_storage` (criptografado no dispositivo)
- Interceptor do Dio renova/trata 401 automaticamente
- Botões de exclusão ocultos para usuários sem permissão
- Validação de formulários no frontend antes do envio
- Senha nunca é retornada pela API (apenas enviada no cadastro)

---

## 16. Glossário

| Termo                     | Definição                                                                 |
|---------------------------|---------------------------------------------------------------------------|
| **Aeração**               | Processo de ventilação forçada da massa de grãos para controle de temperatura e umidade |
| **Delta T**               | Diferença entre a temperatura do ar ambiente e a temperatura da massa de grãos |
| **Ponto de Orvalho**      | Temperatura na qual o ar atmosférico atinge a saturação e inicia a condensação |
| **Equilíbrio Higroscópico** | Ponto em que a umidade dos grãos entra em equilíbrio com a umidade relativa do ar |
| **Massa Estável**         | Condição ideal de armazenamento onde não há deterioração biológica dos grãos |
| **GRPS**                  | Gão Responsible Per Second — métrica do sistema                          |
| **GetX**                  | Framework Flutter para state management, rotas e injeção de dependência   |
| **Dio**                   | Cliente HTTP para Dart/Flutter com suporte a interceptors                 |
| **Material 3 (M3)**       | Sistema de design do Google com foco em personalização e acessibilidade   |

---

## 17. Referências

- Flutter Documentation: https://docs.flutter.dev/
- GetX Package: https://pub.dev/packages/get
- Dio Package: https://pub.dev/packages/dio
- Django REST Framework: https://www.django-rest-framework.org/
- Google Fonts: https://fonts.google.com/
- Material Design 3: https://m3.material.io/
