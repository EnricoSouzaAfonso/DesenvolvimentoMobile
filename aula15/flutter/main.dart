import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = 'http://10.0.2.2/trufas';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ChecaSessaoPage(),
  ));
}

class ChecaSessaoPage extends StatefulWidget {
  const ChecaSessaoPage({super.key});

  @override
  State<ChecaSessaoPage> createState() => _ChecaSessaoPageState();
}

class _ChecaSessaoPageState extends State<ChecaSessaoPage> {
  @override
  void initState() {
    super.initState();
    verificarLogin();
  }

  Future<void> verificarLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final senha = prefs.getString('senha');
    final perfil = prefs.getString('perfil');

    if (email != null && senha != null && perfil != null && email.isNotEmpty) {
      if (mounted) {
        navegarPorPerfil(context, perfil);
      }
    } else {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

void navegarPorPerfil(BuildContext context, String perfil) {
  Widget destino;
  if (perfil == 'produtor') {
    destino = const ProdutorPage();
  } else if (perfil == 'vendedor') {
    destino = const VendedorPage();
  } else {
    destino = const GerentePage();
  }

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => destino),
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  Future<void> logar() async {
    final email = emailController.text.trim();
    final senha = senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha e-mail e senha')),
      );
      return;
    }

    try {
      final resposta = await http.post(
        Uri.parse('$baseUrl/login.php'),
        body: {'email': email, 'senha': senha},
      );

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);
        if (dados['status'] == 'sucesso') {
          final usuario = dados['usuario'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('email', email);
          await prefs.setString('senha', senha);
          await prefs.setInt('usuario_id', int.parse(usuario['id'].toString()));
          await prefs.setString('nome', usuario['nome']);
          await prefs.setString('perfil', usuario['perfil']);

          if (mounted) {
            navegarPorPerfil(context, usuario['perfil']);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(dados['mensagem'] ?? 'Erro no login')),
            );
          }
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao conectar ao servidor')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login - Trufas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: senhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: logar,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Entrar'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CadastroPage()),
                  );
                },
                child: const Text('Não tem conta? Cadastre-se'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  String perfilSelecionado = 'produtor';

  Future<void> cadastrar() async {
    final nome = nomeController.text.trim();
    final email = emailController.text.trim();
    final senha = senhaController.text.trim();

    if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    try {
      final resposta = await http.post(
        Uri.parse('$baseUrl/cadastrar.php'),
        body: {
          'nome': nome,
          'email': email,
          'senha': senha,
          'perfil': perfilSelecionado,
        },
      );

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);
        if (dados['status'] == 'sucesso') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cadastro realizado! Faça login.')),
            );
            Navigator.pop(context);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(dados['mensagem'] ?? 'Erro no cadastro')),
            );
          }
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao conectar ao servidor')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro - Trufas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: senhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: perfilSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Perfil',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'produtor', child: Text('Produtor')),
                  DropdownMenuItem(value: 'vendedor', child: Text('Vendedor')),
                ],
                onChanged: (valor) {
                  if (valor != null) {
                    setState(() {
                      perfilSelecionado = valor;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: cadastrar,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProdutorPage extends StatefulWidget {
  const ProdutorPage({super.key});

  @override
  State<ProdutorPage> createState() => _ProdutorPageState();
}

class _ProdutorPageState extends State<ProdutorPage> {
  final quantidadeController = TextEditingController();
  final valorUnitarioController = TextEditingController();

  int produtorId = 0;
  String nomeProdutor = '';
  double comissao = 0.0;
  double valorTotal = 0.0;
  double valorComDesconto = 0.0;

  @override
  void initState() {
    super.initState();
    inicializar();
  }

  Future<void> inicializar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      produtorId = prefs.getInt('usuario_id') ?? 0;
      nomeProdutor = prefs.getString('nome') ?? '';
    });
    buscarComissao();
  }

  Future<void> buscarComissao() async {
    try {
      final resposta = await http.get(Uri.parse('$baseUrl/obter_comissao.php'));
      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);
        setState(() {
          comissao = double.tryParse(dados['comissao'].toString()) ?? 0.0;
        });
        calcularValores();
      }
    } catch (_) {}
  }

  void calcularValores() {
    final qtd = int.tryParse(quantidadeController.text.trim()) ?? 0;
    final unitario = double.tryParse(
          valorUnitarioController.text.trim().replaceAll(',', '.'),
        ) ??
        0.0;

    setState(() {
      valorTotal = qtd * unitario;
      valorComDesconto = valorTotal - (valorTotal * (comissao / 100));
    });
  }

  Future<void> registrarProducao() async {
    final qtd = int.tryParse(quantidadeController.text.trim()) ?? 0;
    final unitario = double.tryParse(
          valorUnitarioController.text.trim().replaceAll(',', '.'),
        ) ??
        0.0;

    if (qtd <= 0 || unitario <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe quantidade e valor unitário válidos')),
      );
      return;
    }

    try {
      final resposta = await http.post(
        Uri.parse('$baseUrl/registrar_producao.php'),
        body: {
          'produtor_id': produtorId.toString(),
          'quantidade': qtd.toString(),
          'valor_unitario': unitario.toString(),
        },
      );

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);
        if (dados['status'] == 'sucesso') {
          quantidadeController.clear();
          valorUnitarioController.clear();
          setState(() {
            valorTotal = 0.0;
            valorComDesconto = 0.0;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Produção registrada com sucesso!')),
            );
          }
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao registrar produção')),
        );
      }
    }
  }

  Future<void> deslogar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtor de Trufas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: deslogar,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Produtor: $nomeProdutor',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Comissão atual do sistema: ${comissao.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: quantidadeController,
                keyboardType: TextInputType.number,
                onChanged: (_) => calcularValores(),
                decoration: const InputDecoration(
                  labelText: 'Quantidade de trufas',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: valorUnitarioController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => calcularValores(),
                decoration: const InputDecoration(
                  labelText: 'Valor unitário (R\$)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Valor total (antes do desconto): R\$ ${valorTotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Valor final (após desconto): R\$ ${valorComDesconto.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: registrarProducao,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Registrar Produção'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VendedorPage extends StatefulWidget {
  const VendedorPage({super.key});

  @override
  State<VendedorPage> createState() => _VendedorPageState();
}

class _VendedorPageState extends State<VendedorPage> {
  int vendedorId = 0;
  String nomeVendedor = '';
  double comissao = 0.0;
  List<dynamic> producoes = [];
  final Map<int, TextEditingController> qtdControllers = {};

  @override
  void initState() {
    super.initState();
    inicializar();
  }

  Future<void> inicializar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      vendedorId = prefs.getInt('usuario_id') ?? 0;
      nomeVendedor = prefs.getString('nome') ?? '';
    });
    await buscarComissao();
    await carregarProducoes();
  }

  Future<void> buscarComissao() async {
    try {
      final resposta = await http.get(Uri.parse('$baseUrl/obter_comissao.php'));
      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);
        setState(() {
          comissao = double.tryParse(dados['comissao'].toString()) ?? 0.0;
        });
      }
    } catch (_) {}
  }

  Future<void> carregarProducoes() async {
    try {
      final resposta = await http.get(Uri.parse('$baseUrl/listar_producoes.php'));
      if (resposta.statusCode == 200) {
        setState(() {
          producoes = jsonDecode(resposta.body);
        });
      }
    } catch (_) {}
  }

  Future<void> comprar(int producaoId, int estoque) async {
    final controller = qtdControllers[producaoId];
    final qtd = int.tryParse(controller?.text.trim() ?? '') ?? 0;

    if (qtd <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe uma quantidade válida')),
      );
      return;
    }

    if (qtd > estoque) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantidade maior que o estoque disponível')),
      );
      return;
    }

    try {
      final resposta = await http.post(
        Uri.parse('$baseUrl/comprar_trufas.php'),
        body: {
          'vendedor_id': vendedorId.toString(),
          'producao_id': producaoId.toString(),
          'quantidade': qtd.toString(),
        },
      );

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);
        if (dados['status'] == 'sucesso') {
          controller?.clear();
          await carregarProducoes();

          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Dados da Compra'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Produtor: ${dados['produtor_nome']}'),
                    Text('Quantidade: ${dados['quantidade']} trufas'),
                    Text('Valor unitário: R\$ ${double.parse(dados['valor_unitario'].toString()).toStringAsFixed(2)}'),
                    Text('Subtotal: R\$ ${double.parse(dados['subtotal'].toString()).toStringAsFixed(2)}'),
                    Text('Comissão aplicada: ${double.parse(dados['comissao'].toString()).toStringAsFixed(1)}%'),
                    const Divider(),
                    Text(
                      'Valor total com comissão: R\$ ${double.parse(dados['valor_total'].toString()).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(dados['mensagem'] ?? 'Erro na compra')),
            );
          }
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao conectar ao servidor')),
        );
      }
    }
  }

  Future<void> deslogar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendedor de Trufas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: deslogar,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vendedor: $nomeVendedor | Comissão: ${comissao.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: carregarProducoes,
                child: producoes.isEmpty
                    ? const Center(child: Text('Nenhuma produção disponível'))
                    : ListView.builder(
                        itemCount: producoes.length,
                        itemBuilder: (context, index) {
                          final item = producoes[index];
                          final producaoId = int.parse(item['id'].toString());
                          final estoque = int.parse(item['quantidade'].toString());
                          final valorUnitario = double.parse(item['valor_unitario'].toString());

                          if (!qtdControllers.containsKey(producaoId)) {
                            qtdControllers[producaoId] = TextEditingController();
                          }

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Produtor: ${item['produtor_nome']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Estoque: $estoque trufas'),
                                  Text('Valor unitário: R\$ ${valorUnitario.toStringAsFixed(2)}'),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: qtdControllers[producaoId],
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: 'Quantidade',
                                            isDense: true,
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      ElevatedButton(
                                        onPressed: () => comprar(producaoId, estoque),
                                        child: const Text('Comprar'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GerentePage extends StatefulWidget {
  const GerentePage({super.key});

  @override
  State<GerentePage> createState() => _GerentePageState();
}

class _GerentePageState extends State<GerentePage> {
  final comissaoController = TextEditingController();

  String nomeGerente = '';
  double comissaoAtual = 0.0;
  int totalGeradas = 0;
  int totalVendidas = 0;
  double lucroMes = 0.0;

  @override
  void initState() {
    super.initState();
    inicializar();
  }

  Future<void> inicializar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nomeGerente = prefs.getString('nome') ?? '';
    });
    await carregarDadosGerente();
  }

  Future<void> carregarDadosGerente() async {
    try {
      final resposta = await http.get(Uri.parse('$baseUrl/dados_gerente.php'));
      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);
        setState(() {
          comissaoAtual = double.tryParse(dados['comissao'].toString()) ?? 0.0;
          totalGeradas = int.tryParse(dados['total_geradas'].toString()) ?? 0;
          totalVendidas = int.tryParse(dados['total_vendidas'].toString()) ?? 0;
          lucroMes = double.tryParse(dados['lucro_mes'].toString()) ?? 0.0;
        });
      }
    } catch (_) {}
  }

  Future<void> atualizarComissao() async {
    final valor = double.tryParse(
      comissaoController.text.trim().replaceAll(',', '.'),
    );

    if (valor == null || valor < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um percentual válido')),
      );
      return;
    }

    try {
      final resposta = await http.post(
        Uri.parse('$baseUrl/atualizar_comissao.php'),
        body: {'comissao': valor.toString()},
      );

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);
        if (dados['status'] == 'sucesso') {
          comissaoController.clear();
          await carregarDadosGerente();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Comissão atualizada para novas vendas!')),
            );
          }
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao atualizar comissão')),
        );
      }
    }
  }

  Future<void> deslogar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerente do Sistema'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: carregarDadosGerente,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: deslogar,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Gerente: $nomeGerente',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total de trufas geradas: $totalGeradas',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total de trufas vendidas: $totalVendidas',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Divider(height: 24),
                      Text(
                        'Lucro da empresa no mês: R\$ ${lucroMes.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Comissão atual: ${comissaoAtual.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: comissaoController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Novo percentual de comissão (%)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: atualizarComissao,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Atualizar Comissão'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}