import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCmsJunrKaP7bAU1RZ21T67aTLDec-kUs0",
      appId: "1:1069362142791:web:a9c9e3a7597e493bd29b62",
      messagingSenderId: "1069362142791",
      projectId: "fincontrol-pro-a8176",
      authDomain: "fincontrol-pro-a8176.firebaseapp.com",
      storageBucket: "fincontrol-pro-a8176.firebasestorage.app",
    ),
  );

  runApp(const FinApp());
}

// Global User State
class UserData {
  static String nomeCompleto = '';
  static String email = '';

  static String primeiroNome() {
    if (nomeCompleto.trim().isEmpty) return 'Usuário';
    return nomeCompleto.trim().split(' ').first;
  }
}

// Models
class ReceitaItem {
  final String id;
  final String titulo;
  final double valor;
  final String frequencia;
  final String diaRecorrencia;
  final DateTime data;

  ReceitaItem({
    required this.id,
    required this.titulo,
    required this.valor,
    required this.frequencia,
    this.diaRecorrencia = '',
    required this.data,
  });
}

class DespesaItem {
  final String id;
  final String titulo;
  final double valor;
  final String frequencia;
  final String diaRecorrencia;
  DateTime dataVencimento;
  bool isPaga;

  DespesaItem({
    required this.id,
    required this.titulo,
    required this.valor,
    required this.frequencia,
    this.diaRecorrencia = '',
    required this.dataVencimento,
    this.isPaga = false,
  });
}

class MetaItem {
  String id;
  String titulo;
  double valorAlvo;
  double valorAtual;
  int? prazoMeses;
  double? aporteMensalEsperado;
  DateTime dataCriacao;

  MetaItem({
    required this.id,
    required this.titulo,
    required this.valorAlvo,
    this.valorAtual = 0.0,
    this.prazoMeses,
    this.aporteMensalEsperado,
    DateTime? dataCriacao,
  }) : dataCriacao = dataCriacao ?? DateTime.now();
}

class DividaItem {
  final String id;
  final String titulo;
  final double valorTotal;
  int parcelasTotais;
  int parcelasPagas;
  DateTime dataVencimento;
  bool exibirNaTelaInicial;
  bool isPaga;

  DividaItem({
    required this.id,
    required this.titulo,
    required this.valorTotal,
    required this.parcelasTotais,
    this.parcelasPagas = 0,
    required this.dataVencimento,
    this.exibirNaTelaInicial = true,
    this.isPaga = false,
  });

  double get valorParcela => parcelasTotais > 0 ? valorTotal / parcelasTotais : valorTotal;
  double get valorRestante => valorTotal - (valorParcela * parcelasPagas);
}

// Memory Store
class AppStore {
  static List<ReceitaItem> receitas = [];
  static List<DespesaItem> despesas = [];
  static List<MetaItem> metas = [];
  static List<DividaItem> dividas = [];
  static double investimentos = 0.0;

  static void reset() {
    receitas.clear();
    despesas.clear();
    metas.clear();
    dividas.clear();
    investimentos = 0.0;
  }
}

class FinApp extends StatelessWidget {
  const FinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinControl Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: const Color(0xFF10B981),
        cardColor: const Color(0xFF1E293B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF10B981),
          secondary: Color(0xFF6366F1),
          error: Color(0xFFEF4444),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

// ==================== TELA DE LOGIN ====================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  void _fazerLogin() {
    if (_emailController.text.isNotEmpty && _senhaController.text.isNotEmpty) {
      UserData.email = _emailController.text;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha e-mail e senha para entrar!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.account_balance_wallet_rounded, size: 70, color: Color(0xFF10B981)),
              const SizedBox(height: 16),
              const Text(
                'FinControl Pro',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Acesse sua conta para continuar',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _senhaController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _fazerLogin,
                child: const Text('ENTRAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CadastroScreen()),
                  );
                },
                child: const Text(
                  'Não tem uma conta? Crie aqui',
                  style: TextStyle(color: Color(0xFF10B981)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== TELA DE CADASTRO ====================
class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  void _salvarCadastro() {
    if (_nomeController.text.isEmpty || _emailController.text.isEmpty || _senhaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha os campos obrigatórios!')),
      );
      return;
    }

    UserData.nomeCompleto = _nomeController.text;
    UserData.email = _emailController.text;
    AppStore.reset();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Conta criada com sucesso! Faça login.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Nova Conta'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: 'Nome Completo',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'E-mail',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _senhaController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Crie uma Senha',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _salvarCadastro,
              child: const Text('CADASTRAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== TELA PRINCIPAL (Navegação) ====================
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(onUpdate: _refresh),
      ReceitasScreen(onUpdate: _refresh),
      DespesasScreen(onUpdate: _refresh),
      MetasScreen(onUpdate: _refresh),
      DividasScreen(onUpdate: _refresh),
    ];

    return Scaffold(
      drawer: AppDrawer(onUpdate: _refresh),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E293B),
        selectedItemColor: const Color(0xFF10B981),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.arrow_upward_rounded), label: 'Receitas'),
          BottomNavigationBarItem(icon: Icon(Icons.arrow_downward_rounded), label: 'Despesas'),
          BottomNavigationBarItem(icon: Icon(Icons.track_changes_rounded), label: 'Metas'),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card_off_rounded), label: 'Dívidas'),
        ],
      ),
    );
  }
}

// ==================== APP DRAWER (MENU LATERAL) ====================
class AppDrawer extends StatelessWidget {
  final VoidCallback onUpdate;
  const AppDrawer({super.key, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1E293B),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
            ),
            accountName: Text(UserData.primeiroNome(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: Text(UserData.email),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Color(0xFF10B981),
              child: Icon(Icons.person, color: Colors.white, size: 36),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.show_chart, color: Colors.indigoAccent),
            title: const Text('Panorama Geral'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PanoramaGeralScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Colors.amber),
            title: const Text('Histórico'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoricoScreen()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Sair'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          ),
        ],
      ),
    );
  }
}

// ==================== DASHBOARD / TELA INICIAL ====================
class HomeScreen extends StatefulWidget {
  final VoidCallback onUpdate;
  const HomeScreen({super.key, required this.onUpdate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _filtroGrafico = 'Mês';

  String _formatarDataHoje() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  void _marcarComoPaga(DespesaItem despesa) {
    setState(() {
      despesa.isPaga = true;
    });
    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    double totalReceitas = AppStore.receitas.fold(0.0, (sum, item) => sum + item.valor);
    double totalDespesasPagas = AppStore.despesas.where((d) => d.isPaga).fold(0.0, (sum, item) => sum + item.valor);
    double totalDespesasGeral = AppStore.despesas.fold(0.0, (sum, item) => sum + item.valor);
    double saldoTotal = totalReceitas - totalDespesasPagas;

    double receitasMes = AppStore.receitas
        .where((r) => r.data.month == now.month && r.data.year == now.year)
        .fold(0.0, (sum, item) => sum + item.valor);

    double despesasMes = AppStore.despesas
        .where((d) => d.dataVencimento.month == now.month && d.dataVencimento.year == now.year)
        .fold(0.0, (sum, item) => sum + item.valor);

    double totalMetas = AppStore.metas.fold(0.0, (sum, item) => sum + item.valorAlvo);

    final despesasPendentes = AppStore.despesas.where((d) {
      if (d.isPaga) return false;
      if (d.frequencia == 'mensal') {
        return d.dataVencimento.year < now.year ||
            (d.dataVencimento.year == now.year && d.dataVencimento.month <= now.month);
      }
      return true;
    }).toList();

    final dividasVisiveis = AppStore.dividas.where((d) => d.exibirNaTelaInicial && !d.isPaga).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 56,
        leading: Builder(
          builder: (builderContext) => IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Menu',
            onPressed: () => Scaffold.of(builderContext).openDrawer(),
          ),
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Olá, ${UserData.primeiroNome()}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('Data: ${_formatarDataHoje()}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Saldo Total Disponível', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('R\$ ${saldoTotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatItem(title: 'Receitas (Mês)', value: 'R\$ ${receitasMes.toStringAsFixed(2)}', icon: Icons.arrow_upward),
                      _StatItem(title: 'Despesas (Mês)', value: 'R\$ ${despesasMes.toStringAsFixed(2)}', icon: Icons.arrow_downward),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _MiniCard(title: 'Receitas Mês', value: 'R\$ ${receitasMes.toStringAsFixed(2)}', icon: Icons.add_circle_outline, color: Colors.green),
                _MiniCard(title: 'Despesas Mês', value: 'R\$ ${despesasMes.toStringAsFixed(2)}', icon: Icons.remove_circle_outline, color: Colors.redAccent),
                _MiniCard(title: 'Investimentos', value: 'R\$ ${AppStore.investimentos.toStringAsFixed(2)}', icon: Icons.trending_up_rounded, color: Colors.indigo),
                _MiniCard(title: 'Metas (Total)', value: 'R\$ ${totalMetas.toStringAsFixed(2)}', icon: Icons.flag_rounded, color: Colors.amber),
              ],
            ),
            const SizedBox(height: 24),

            if (dividasVisiveis.isNotEmpty) ...[
              const Text('Dívidas em Destaque', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dividasVisiveis.length,
                itemBuilder: (context, index) {
                  final div = dividasVisiveis[index];
                  return Card(
                    color: const Color(0xFF2D1B1B),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
                      title: Text(div.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Parcelas: ${div.parcelasPagas}/${div.parcelasTotais} • Parcela: R\$ ${div.valorParcela.toStringAsFixed(2)}'),
                      trailing: Text('Restante:\nR\$ ${div.valorRestante.toStringAsFixed(2)}', textAlign: TextAlign.right, style: const TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Despesas Pendentes (Pagar)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('${despesasPendentes.length} pendente(s)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            if (despesasPendentes.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
                child: const Text('Nenhuma despesa pendente no momento!', style: TextStyle(color: Colors.grey, fontSize: 13)),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: despesasPendentes.length,
                itemBuilder: (context, index) {
                  final despesa = despesasPendentes[index];
                  final dia = despesa.dataVencimento.day.toString().padLeft(2, '0');
                  final mes = despesa.dataVencimento.month.toString().padLeft(2, '0');
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(despesa.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Vence: $dia/$mes • Frequência: ${despesa.frequencia}${despesa.diaRecorrencia.isNotEmpty ? ' (${despesa.diaRecorrencia})' : ''}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('R\$ ${despesa.valor.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            ),
                            onPressed: () => _marcarComoPaga(despesa),
                            child: const Text('Pagar', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Evolução Financeira', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Mês', label: Text('Mês')),
                    ButtonSegment(value: 'Total', label: Text('Total')),
                  ],
                  selected: {_filtroGrafico},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() => _filtroGrafico = newSelection.first);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _FinancialChartCard(
              filtro: _filtroGrafico,
              receitas: _filtroGrafico == 'Mês' ? receitasMes : totalReceitas,
              despesas: _filtroGrafico == 'Mês' ? despesasMes : totalDespesasGeral,
              metas: _filtroGrafico == 'Mês' ? (totalMetas / 12) : totalMetas,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _FinancialChartCard extends StatelessWidget {
  final String filtro;
  final double receitas;
  final double despesas;
  final double metas;

  const _FinancialChartCard({
    required this.filtro,
    required this.receitas,
    required this.despesas,
    required this.metas,
  });

  @override
  Widget build(BuildContext context) {
    double maxVal = [receitas, despesas, metas, 100.0].reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Visão Geral ($filtro)', style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 16),
          _BarRow(label: 'Receitas', valor: receitas, maxVal: maxVal, color: const Color(0xFF10B981)),
          const SizedBox(height: 12),
          _BarRow(label: 'Despesas', valor: despesas, maxVal: maxVal, color: const Color(0xFFEF4444)),
          const SizedBox(height: 12),
          _BarRow(label: 'Metas', valor: metas, maxVal: maxVal, color: Colors.amber),
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final double valor;
  final double maxVal;
  final Color color;

  const _BarRow({required this.label, required this.valor, required this.maxVal, required this.color});

  @override
  Widget build(BuildContext context) {
    double pct = maxVal > 0 ? (valor / maxVal).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Text('R\$ ${valor.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(value: pct, minHeight: 10, backgroundColor: const Color(0xFF334155), color: color),
        )
      ],
    );
  }
}

// ==================== TELA RECEITAS ====================
class ReceitasScreen extends StatefulWidget {
  final VoidCallback onUpdate;
  const ReceitasScreen({super.key, required this.onUpdate});

  @override
  State<ReceitasScreen> createState() => _ReceitasScreenState();
}

class _ReceitasScreenState extends State<ReceitasScreen> {
  void _addReceita(String titulo, double valor, String freq, String diaRec) {
    setState(() {
      AppStore.receitas.add(
        ReceitaItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          titulo: titulo,
          valor: valor,
          frequencia: freq,
          diaRecorrencia: diaRec,
          data: DateTime.now(),
        ),
      );
    });
    widget.onUpdate();
  }

  void _removerReceita(ReceitaItem receita) {
    setState(() {
      AppStore.receitas.remove(receita);
    });
    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Receitas'), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _mostrarModalCadastroComDia(context, "Receita", _addReceita),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Nova Receita (Fixa/Extra)', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: AppStore.receitas.isEmpty
                  ? const Center(child: Text('Nenhuma receita cadastrada.', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: AppStore.receitas.length,
                      itemBuilder: (context, index) {
                        final r = AppStore.receitas[index];
                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.arrow_upward, color: Colors.white)),
                            title: Text(r.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Frequência: ${r.frequencia}${r.diaRecorrencia.isNotEmpty ? ' (${r.diaRecorrencia})' : ''}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('+ R\$ ${r.valor.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.undo, color: Colors.amber),
                                  tooltip: 'Desfazer / Excluir',
                                  onPressed: () => _removerReceita(r),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}

// ==================== TELA DESPESAS ====================
class DespesasScreen extends StatefulWidget {
  final VoidCallback onUpdate;
  const DespesasScreen({super.key, required this.onUpdate});

  @override
  State<DespesasScreen> createState() => _DespesasScreenState();
}

class _DespesasScreenState extends State<DespesasScreen> {
  void _addDespesa(String titulo, double valor, String freq, String diaRec) {
    setState(() {
      AppStore.despesas.add(
        DespesaItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          titulo: titulo,
          valor: valor,
          frequencia: freq,
          diaRecorrencia: diaRec,
          dataVencimento: DateTime.now().add(const Duration(days: 5)),
          isPaga: false,
        ),
      );
    });
    widget.onUpdate();
  }

  void _desfazerPagamento(DespesaItem despesa) {
    setState(() {
      despesa.isPaga = !despesa.isPaga;
    });
    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Despesas'), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _mostrarModalCadastroComDia(context, "Despesa", _addDespesa),
              icon: const Icon(Icons.remove, color: Colors.white),
              label: const Text('Nova Despesa', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: AppStore.despesas.isEmpty
                  ? const Center(child: Text('Nenhuma despesa cadastrada.', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: AppStore.despesas.length,
                      itemBuilder: (context, index) {
                        final d = AppStore.despesas[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: d.isPaga ? Colors.grey : Colors.red,
                              child: Icon(d.isPaga ? Icons.check : Icons.arrow_downward, color: Colors.white),
                            ),
                            title: Text(d.titulo, style: TextStyle(fontWeight: FontWeight.bold, decoration: d.isPaga ? TextDecoration.lineThrough : null)),
                            subtitle: Text('Status: ${d.isPaga ? 'PAGA' : 'PENDENTE'}\nFreq: ${d.frequencia}${d.diaRecorrencia.isNotEmpty ? ' (${d.diaRecorrencia})' : ''}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('- R\$ ${d.valor.toStringAsFixed(2)}', style: TextStyle(color: d.isPaga ? Colors.grey : Colors.redAccent, fontWeight: FontWeight.bold)),
                                if (d.isPaga)
                                  IconButton(
                                    icon: const Icon(Icons.undo, color: Colors.amber),
                                    tooltip: 'Desfazer Pagamento',
                                    onPressed: () => _desfazerPagamento(d),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}

// ==================== TELA METAS ====================
class MetasScreen extends StatefulWidget {
  final VoidCallback onUpdate;
  const MetasScreen({super.key, required this.onUpdate});

  @override
  State<MetasScreen> createState() => _MetasScreenState();
}

class _MetasScreenState extends State<MetasScreen> {
  void _addMeta(String titulo, double valor, int? prazo, double? aporte) {
    setState(() {
      AppStore.metas.add(MetaItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        titulo: titulo,
        valorAlvo: valor,
        prazoMeses: prazo,
        aporteMensalEsperado: aporte,
      ));
    });
    widget.onUpdate();
  }

  void _excluirMeta(MetaItem meta) {
    setState(() {
      AppStore.metas.remove(meta);
    });
    widget.onUpdate();
  }

  void _abrirAporteModal(MetaItem meta) {
    final valorCtrl = TextEditingController();
    bool ehAdicao = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateModal) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: Text('Aporte em "${meta.titulo}"'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Adicionar'),
                      selected: ehAdicao,
                      onSelected: (val) => setStateModal(() => ehAdicao = true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Retirar'),
                      selected: !ehAdicao,
                      onSelected: (val) => setStateModal(() => ehAdicao = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: valorCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Valor (R\$)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                double val = double.tryParse(valorCtrl.text.replaceAll(',', '.')) ?? 0.0;
                if (val > 0) {
                  setState(() {
                    if (ehAdicao) {
                      meta.valorAtual += val;
                    } else {
                      meta.valorAtual = (meta.valorAtual - val).clamp(0.0, double.infinity);
                    }
                  });
                  widget.onUpdate();
                }
                Navigator.pop(ctx);
              },
              child: const Text('Salvar'),
            )
          ],
        ),
      ),
    );
  }

  void _abrirEdicaoModal(MetaItem meta) {
    final tituloCtrl = TextEditingController(text: meta.titulo);
    final valorCtrl = TextEditingController(text: meta.valorAlvo.toString());
    final prazoCtrl = TextEditingController(text: meta.prazoMeses?.toString() ?? '');
    final aporteCtrl = TextEditingController(text: meta.aporteMensalEsperado?.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Editar Meta'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: tituloCtrl, decoration: const InputDecoration(labelText: 'Nome da Meta')),
              TextField(controller: valorCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Valor Objetivo (R\$)')),
              TextField(controller: prazoCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Prazo (Meses) - Opcional')),
              TextField(controller: aporteCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Aporte Mensal (R\$) - Opcional')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (tituloCtrl.text.isNotEmpty && valorCtrl.text.isNotEmpty) {
                setState(() {
                  meta.titulo = tituloCtrl.text;
                  meta.valorAlvo = double.tryParse(valorCtrl.text.replaceAll(',', '.')) ?? meta.valorAlvo;
                  meta.prazoMeses = int.tryParse(prazoCtrl.text);
                  meta.aporteMensalEsperado = double.tryParse(aporteCtrl.text.replaceAll(',', '.'));
                });
                widget.onUpdate();
              }
              Navigator.pop(ctx);
            },
            child: const Text('Atualizar'),
          )
        ],
      ),
    );
  }

  void _abrirSimuladorModal() {
    final objetivoCtrl = TextEditingController(text: '10000');
    final aporteCtrl = TextEditingController(text: '500');
    final taxaCtrl = TextEditingController(text: '1.0');
    final mesesCtrl = TextEditingController(text: '12');

    String resultado = '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateModal) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Calculadora de Rendimento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: objetivoCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Objetivo Total (R\$)')),
                TextField(controller: aporteCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Aporte Mensal (R\$)')),
                TextField(controller: taxaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Rendimento Mensal (%)')),
                TextField(controller: mesesCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Período (Meses)')),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                  onPressed: () {
                    double obj = double.tryParse(objetivoCtrl.text.replaceAll(',', '.')) ?? 0;
                    double aporte = double.tryParse(aporteCtrl.text.replaceAll(',', '.')) ?? 0;
                    double taxa = (double.tryParse(taxaCtrl.text.replaceAll(',', '.')) ?? 0) / 100;
                    int meses = int.tryParse(mesesCtrl.text) ?? 0;

                    double saldoFinal = 0;
                    for (int i = 0; i < meses; i++) {
                      saldoFinal = (saldoFinal + aporte) * (1 + taxa);
                    }

                    int mesesNecessarios = 0;
                    double tempSaldo = 0;
                    if (aporte > 0) {
                      while (tempSaldo < obj && mesesNecessarios < 1200) {
                        tempSaldo = (tempSaldo + aporte) * (1 + taxa);
                        mesesNecessarios++;
                      }
                    }

                    setStateModal(() {
                      resultado = '• Saldo em $meses meses: R\$ ${saldoFinal.toStringAsFixed(2)}\n'
                          '• Tempo para atingir R\$ ${obj.toStringAsFixed(2)}: ~$mesesNecessarios meses';
                    });
                  },
                  child: const Text('Calcular', style: TextStyle(color: Colors.white)),
                ),
                if (resultado.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)),
                    child: Text(resultado, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
                  )
                ]
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fechar')),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _calcularStatusMeta(MetaItem m) {
    if (m.valorAtual >= m.valorAlvo) {
      return {'texto': 'Concluída!', 'cor': Colors.green};
    }
    if (m.aporteMensalEsperado == null || m.aporteMensalEsperado! <= 0) {
      return {'texto': 'Em andamento', 'cor': Colors.blueAccent};
    }

    final agora = DateTime.now();
    int mesesDecorridos = ((agora.year - m.dataCriacao.year) * 12) + (agora.month - m.dataCriacao.month);
    if (mesesDecorridos < 1) mesesDecorridos = 1;

    double valorEsperado = mesesDecorridos * m.aporteMensalEsperado!;
    if (m.valorAtual >= valorEsperado) {
      return {'texto': 'Em dia', 'cor': Colors.green};
    } else {
      double defasagem = valorEsperado - m.valorAtual;
      int mesesAtraso = (defasagem / m.aporteMensalEsperado!).ceil();
      return {'texto': 'Atrasada em $mesesAtraso mês(es)', 'cor': Colors.redAccent};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Metas Financeiras'), backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _mostrarModalNovaMetaCompleta(context, _addMeta),
                    icon: const Icon(Icons.add_task, color: Colors.black),
                    label: const Text('Nova Meta', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigoAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _abrirSimuladorModal,
                    icon: const Icon(Icons.calculate, color: Colors.white),
                    label: const Text('Simulador', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Suas Metas (Clique para opções)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            AppStore.metas.isEmpty
                ? const Text('Nenhuma meta criada ainda.', style: TextStyle(color: Colors.grey))
                : Column(
                    children: AppStore.metas.map((m) {
                      double pct = m.valorAlvo > 0 ? (m.valorAtual / m.valorAlvo).clamp(0.0, 1.0) : 0.0;
                      final status = _calcularStatusMeta(m);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: const Color(0xFF1E293B),
                              builder: (ctx) => Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.account_balance_wallet, color: Colors.green),
                                    title: const Text('Fazer Aporte / Retirada'),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      _abrirAporteModal(m);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.edit, color: Colors.blue),
                                    title: const Text('Editar Meta'),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      _abrirEdicaoModal(m);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.delete, color: Colors.redAccent),
                                    title: const Text('Excluir Meta', style: TextStyle(color: Colors.redAccent)),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      _excluirMeta(m);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(m.titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: (status['cor'] as Color).withAlpha(50),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        status['texto'],
                                        style: TextStyle(color: status['cor'], fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(value: pct, backgroundColor: const Color(0xFF334155), color: const Color(0xFF10B981)),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('R\$ ${m.valorAtual.toStringAsFixed(2)} de R\$ ${m.valorAlvo.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    Text('${(pct * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}

// ==================== TELA DÍVIDAS ====================
class DividasScreen extends StatefulWidget {
  final VoidCallback onUpdate;
  const DividasScreen({super.key, required this.onUpdate});

  @override
  State<DividasScreen> createState() => _DividasScreenState();
}

class _DividasScreenState extends State<DividasScreen> {
  void _addDivida(String titulo, double valor, int parcelas, bool exibirIncio) {
    setState(() {
      AppStore.dividas.add(DividaItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        titulo: titulo,
        valorTotal: valor,
        parcelasTotais: parcelas,
        dataVencimento: DateTime.now().add(const Duration(days: 30)),
        exibirNaTelaInicial: exibirIncio,
      ));
    });
    widget.onUpdate();
  }

  void _pagarParcela(DividaItem d) {
    setState(() {
      if (d.parcelasPagas < d.parcelasTotais) {
        d.parcelasPagas++;
        if (d.parcelasPagas >= d.parcelasTotais) {
          d.isPaga = true;
        }
      }
    });
    widget.onUpdate();
  }

  void _quitarDivida(DividaItem d) {
    setState(() {
      d.parcelasPagas = d.parcelasTotais;
      d.isPaga = true;
    });
    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Controle de Dívidas'), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _mostrarModalNovaDivida(context, _addDivida),
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text('Cadastrar Dívida', style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: AppStore.dividas.isEmpty
                  ? const Center(child: Text('Nenhuma dívida registrada.', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: AppStore.dividas.length,
                      itemBuilder: (context, index) {
                        final d = AppStore.dividas[index];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor: d.isPaga ? Colors.green : Colors.orange,
                                    child: Icon(d.isPaga ? Icons.check : Icons.warning_amber_rounded, color: Colors.white),
                                  ),
                                  title: Text(d.titulo, style: TextStyle(fontWeight: FontWeight.bold, decoration: d.isPaga ? TextDecoration.lineThrough : null)),
                                  subtitle: Text('Total: R\$ ${d.valorTotal.toStringAsFixed(2)}\n'
                                      'Parcela (${d.parcelasPagas}/${d.parcelasTotais}): R\$ ${d.valorParcela.toStringAsFixed(2)}/mês'),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('Ver no início', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                      Switch(
                                        value: d.exibirNaTelaInicial,
                                        activeColor: Colors.orangeAccent,
                                        onChanged: (val) {
                                          setState(() => d.exibirNaTelaInicial = val);
                                          widget.onUpdate();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                if (!d.isPaga) ...[
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () => _pagarParcela(d),
                                        icon: const Icon(Icons.payment, size: 16),
                                        label: const Text('Pagar Parcela'),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                        onPressed: () => _quitarDivida(d),
                                        icon: const Icon(Icons.check_circle, size: 16, color: Colors.white),
                                        label: const Text('Quitar Dívida', style: TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  )
                                ]
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}

// ==================== TELA HISTÓRICO ====================
class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  DateTimeRange? _periodoSelecionado;

  @override
  Widget build(BuildContext context) {
    final receitasFiltradas = AppStore.receitas.where((r) {
      if (_periodoSelecionado == null) return true;
      return r.data.isAfter(_periodoSelecionado!.start.subtract(const Duration(days: 1))) &&
          r.data.isBefore(_periodoSelecionado!.end.add(const Duration(days: 1)));
    }).toList();

    final despesasFiltradas = AppStore.despesas.where((d) {
      if (_periodoSelecionado == null) return true;
      return d.dataVencimento.isAfter(_periodoSelecionado!.start.subtract(const Duration(days: 1))) &&
          d.dataVencimento.isBefore(_periodoSelecionado!.end.add(const Duration(days: 1)));
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico Detalhado'), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, minimumSize: const Size(double.infinity, 48)),
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  initialDateRange: _periodoSelecionado,
                );
                if (picked != null) {
                  setState(() => _periodoSelecionado = picked);
                }
              },
              icon: const Icon(Icons.date_range, color: Colors.white),
              label: Text(
                _periodoSelecionado == null
                    ? 'Filtrar por Período'
                    : 'Período: ${_periodoSelecionado!.start.day}/${_periodoSelecionado!.start.month} até ${_periodoSelecionado!.end.day}/${_periodoSelecionado!.end.month}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  const Text('Entradas (Receitas)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                  ...receitasFiltradas.map((r) => ListTile(
                        title: Text(r.titulo),
                        subtitle: Text('${r.data.day}/${r.data.month}/${r.data.year}'),
                        trailing: Text('+ R\$ ${r.valor.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      )),
                  const Divider(),
                  const Text('Saídas (Despesas)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  ...despesasFiltradas.map((d) => ListTile(
                        title: Text(d.titulo),
                        subtitle: Text('${d.dataVencimento.day}/${d.dataVencimento.month}/${d.dataVencimento.year}'),
                        trailing: Text('- R\$ ${d.valor.toStringAsFixed(2)}', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ==================== TELA PANORAMA GERAL ====================
class PanoramaGeralScreen extends StatelessWidget {
  const PanoramaGeralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double totalReceitas = AppStore.receitas.fold(0.0, (s, i) => s + i.valor);
    double totalDespesas = AppStore.despesas.fold(0.0, (s, i) => s + i.valor);

    return Scaffold(
      appBar: AppBar(title: const Text('Panorama Geral'), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Análise Comparativa Geral', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _BarRow(label: 'Ganhos Totais', valor: totalReceitas, maxVal: max(totalReceitas, totalDespesas), color: Colors.green),
                  const SizedBox(height: 16),
                  _BarRow(label: 'Gastos Totais', valor: totalDespesas, maxVal: max(totalReceitas, totalDespesas), color: Colors.redAccent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== MODAIS DE DIÁLOGO ====================
void _mostrarModalCadastroComDia(BuildContext context, String tipo, Function(String, double, String, String) onSave) {
  final tituloCtrl = TextEditingController();
  final valorCtrl = TextEditingController();
  final diaCtrl = TextEditingController();
  String freq = 'mensal';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1E293B),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cadastrar $tipo', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(controller: tituloCtrl, decoration: const InputDecoration(labelText: 'Descrição / Nome')),
            TextField(controller: valorCtrl, decoration: const InputDecoration(labelText: 'Valor (R\$)'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: freq,
              items: const [
                DropdownMenuItem(value: 'mensal', child: Text('Recorrente - Mensal')),
                DropdownMenuItem(value: 'semanal', child: Text('Recorrente - Semanal')),
                DropdownMenuItem(value: 'unica', child: Text('Específico / Único')),
              ],
              onChanged: (v) {
                if (v != null) freq = v;
              },
              decoration: const InputDecoration(labelText: 'Frequência / Tipo'),
            ),
            const SizedBox(height: 12),
            TextField(controller: diaCtrl, decoration: const InputDecoration(labelText: 'Dia do pagamento/recebimento')),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48), backgroundColor: const Color(0xFF10B981)),
              onPressed: () {
                if (tituloCtrl.text.isNotEmpty && valorCtrl.text.isNotEmpty) {
                  double val = double.tryParse(valorCtrl.text.replaceAll(',', '.')) ?? 0.0;
                  onSave(tituloCtrl.text, val, freq, diaCtrl.text);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Salvar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    ),
  );
}

void _mostrarModalNovaMetaCompleta(BuildContext context, Function(String, double, int?, double?) onSave) {
  final tituloCtrl = TextEditingController();
  final valorCtrl = TextEditingController();
  final prazoCtrl = TextEditingController();
  final aporteCtrl = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1E293B),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nova Meta Financeira', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(controller: tituloCtrl, decoration: const InputDecoration(labelText: 'Nome da Meta')),
            TextField(controller: valorCtrl, decoration: const InputDecoration(labelText: 'Valor Objetivo (R\$)'), keyboardType: TextInputType.number),
            TextField(controller: prazoCtrl, decoration: const InputDecoration(labelText: 'Prazo (em meses) - Opcional'), keyboardType: TextInputType.number),
            TextField(controller: aporteCtrl, decoration: const InputDecoration(labelText: 'Aporte Mensal (R\$) - Opcional'), keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48), backgroundColor: Colors.amber),
              onPressed: () {
                if (tituloCtrl.text.isNotEmpty && valorCtrl.text.isNotEmpty) {
                  double val = double.tryParse(valorCtrl.text.replaceAll(',', '.')) ?? 0.0;
                  int? prazo = int.tryParse(prazoCtrl.text);
                  double? aporte = double.tryParse(aporteCtrl.text.replaceAll(',', '.'));
                  onSave(tituloCtrl.text, val, prazo, aporte);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Salvar Meta', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    ),
  );
}

void _mostrarModalNovaDivida(BuildContext context, Function(String, double, int, bool) onSave) {
  final tituloCtrl = TextEditingController();
  final valorCtrl = TextEditingController();
  final parcelasCtrl = TextEditingController(text: '1');
  bool exibirInicio = true;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1E293B),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => StatefulBuilder(
      builder: (context, setStateModal) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cadastrar Dívida', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(controller: tituloCtrl, decoration: const InputDecoration(labelText: 'Título da Dívida')),
              TextField(controller: valorCtrl, decoration: const InputDecoration(labelText: 'Valor Total (R\$)'), keyboardType: TextInputType.number),
              TextField(controller: parcelasCtrl, decoration: const InputDecoration(labelText: 'Número de Parcelas'), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Exibir na Tela Inicial?'),
                  Switch(
                    value: exibirInicio,
                    activeColor: Colors.orangeAccent,
                    onChanged: (val) => setStateModal(() => exibirInicio = val),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48), backgroundColor: Colors.orangeAccent),
                onPressed: () {
                  if (tituloCtrl.text.isNotEmpty && valorCtrl.text.isNotEmpty) {
                    double val = double.tryParse(valorCtrl.text.replaceAll(',', '.')) ?? 0.0;
                    int parc = int.tryParse(parcelasCtrl.text) ?? 1;
                    onSave(tituloCtrl.text, val, parc, exibirInicio);
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Salvar Dívida', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    ),
  );
}

// Components Auxiliares
class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatItem({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(backgroundColor: color.withAlpha(50), radius: 16, child: Icon(icon, color: color, size: 18)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
