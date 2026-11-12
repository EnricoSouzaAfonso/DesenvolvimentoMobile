import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = 'http://10.0.2.2/xuitter';

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

    if (email != null &&
        senha != null &&
        email.isNotEmpty &&
        senha.isNotEmpty) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FeedPage()),
        );
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
          await prefs.setString('arroba', usuario['arroba']);

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const FeedPage()),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(dados['mensagem'] ?? 'Credenciais inválidas')),
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
      appBar: AppBar(title: const Text('Login - Xuitter')),
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
                    MaterialPageRoute(
                        builder: (context) => const CadastroPage()),
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
  final arrobaController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  Future<void> cadastrar() async {
    final nome = nomeController.text.trim();
    final arroba = arrobaController.text.trim();
    final email = emailController.text.trim();
    final senha = senhaController.text.trim();

    if (nome.isEmpty || arroba.isEmpty || email.isEmpty || senha.isEmpty) {
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
          'arroba': arroba,
          'email': email,
          'senha': senha,
        },
      );

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);
        if (dados['status'] == 'sucesso') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Cadastro concluído! Faça seu login.')),
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
      appBar: AppBar(title: const Text('Cadastro - Xuitter')),
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
                controller: arrobaController,
                decoration: const InputDecoration(
                  labelText: '@ (usuário)',
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

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  int usuarioId = 0;
  List<dynamic> posts = [];
  final Map<int, TextEditingController> comentarioControllers = {};

  @override
  void initState() {
    super.initState();
    carregarUsuarioECarregarFeed();
  }

  Future<void> carregarUsuarioECarregarFeed() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      usuarioId = prefs.getInt('usuario_id') ?? 0;
    });
    carregarFeed();
  }

  Future<void> carregarFeed() async {
    try {
      final resposta = await http.get(
        Uri.parse('$baseUrl/listar_feed.php?usuario_id=$usuarioId'),
      );
      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);
        setState(() {
          posts = dados;
        });
      }
    } catch (_) {}
  }

  Future<void> alternarCurtida(int postId) async {
    try {
      final resposta = await http.post(
        Uri.parse('$baseUrl/curtir.php'),
        body: {
          'postagem_id': postId.toString(),
          'usuario_id': usuarioId.toString(),
        },
      );
      if (resposta.statusCode == 200) {
        carregarFeed();
      }
    } catch (_) {}
  }

  Future<void> enviarComentario(int postId) async {
    final controller = comentarioControllers[postId];
    if (controller == null || controller.text.trim().isEmpty) return;

    final texto = controller.text.trim();

    try {
      final resposta = await http.post(
        Uri.parse('$baseUrl/comentar.php'),
        body: {
          'postagem_id': postId.toString(),
          'usuario_id': usuarioId.toString(),
          'texto': texto,
        },
      );

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);
        if (dados['status'] == 'sucesso') {
          controller.clear();
          carregarFeed();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(dados['mensagem'] ?? 'Erro')),
            );
          }
        }
      }
    } catch (_) {}
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
        title: const Text('Xuitter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      BuscarUsuariosPage(usuarioId: usuarioId),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CriarPostagemPage()),
              );
              carregarFeed();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: deslogar,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: carregarFeed,
        child: posts.isEmpty
            ? const Center(child: Text('Nenhuma postagem ainda'))
            : ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  final postId = int.parse(post['id'].toString());
                  final curtiu = post['curtiu'] == true;
                  final totalCurtidas = post['total_curtidas'] ?? 0;
                  final comentarios =
                      post['comentarios'] as List<dynamic>? ?? [];

                  if (!comentarioControllers.containsKey(postId)) {
                    comentarioControllers[postId] = TextEditingController();
                  }

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${post['nome'] ?? 'Usuário'} (${post['arroba'] ?? ''})',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          if (post['texto'] != null &&
                              post['texto'].toString().isNotEmpty)
                            Text(post['texto'].toString()),
                          if (post['foto'] != null &&
                              post['foto'].toString().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Image.network(
                              '$baseUrl/uploads/${post['foto']}',
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, size: 50),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  curtiu
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: curtiu ? Colors.red : null,
                                ),
                                onPressed: () => alternarCurtida(postId),
                              ),
                              Text('$totalCurtidas'),
                            ],
                          ),
                          const Divider(),
                          if (comentarios.isNotEmpty) ...[
                            ...comentarios.map((c) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2),
                                  child: Text(
                                    '${c['nome'] ?? c['arroba']}: ${c['texto']}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                )),
                            const SizedBox(height: 8),
                          ],
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: comentarioControllers[postId],
                                  decoration: const InputDecoration(
                                    hintText: 'Comentar (apenas amigos)...',
                                    isDense: true,
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.send),
                                onPressed: () => enviarComentario(postId),
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
    );
  }
}

class BuscarUsuariosPage extends StatefulWidget {
  final int usuarioId;
  const BuscarUsuariosPage({super.key, required this.usuarioId});

  @override
  State<BuscarUsuariosPage> createState() => _BuscarUsuariosPageState();
}

class _BuscarUsuariosPageState extends State<BuscarUsuariosPage> {
  final buscaController = TextEditingController();
  List<dynamic> resultados = [];

  Future<void> buscar() async {
    final termo = buscaController.text.trim();
    if (termo.isEmpty) return;

    try {
      final url = Uri.parse(
        '$baseUrl/buscar_usuarios.php?busca=${Uri.encodeComponent(termo)}&usuario_id=${widget.usuarioId}',
      );

      final resposta = await http.get(url);

      if (resposta.statusCode == 200) {
        setState(() {
          resultados = jsonDecode(resposta.body);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao buscar')),
        );
      }
    }
  }

  Future<void> adicionarAmigo(int amigoId) async {
    try {
      final resposta = await http.post(
        Uri.parse('$baseUrl/adicionar_amigo.php'),
        body: {
          'usuario_id': widget.usuarioId.toString(),
          'amigo_id': amigoId.toString(),
        },
      );
      if (resposta.statusCode == 200) {
        buscar();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Usuários')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: buscaController,
                    decoration: const InputDecoration(
                      labelText: 'Buscar por nome ou @',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: buscar,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: resultados.length,
                itemBuilder: (context, index) {
                  final user = resultados[index];
                  final amigoId = int.parse(user['id'].toString());
                  final saoAmigos = user['sao_amigos'] == true;

                  return ListTile(
                    title: Text(user['nome'] ?? ''),
                    subtitle: Text(user['arroba'] ?? ''),
                    trailing: saoAmigos
                        ? const Text('Amigos',
                            style: TextStyle(color: Colors.green))
                        : ElevatedButton(
                            onPressed: () => adicionarAmigo(amigoId),
                            child: const Text('Adicionar'),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CriarPostagemPage extends StatefulWidget {
  const CriarPostagemPage({super.key});

  @override
  State<CriarPostagemPage> createState() => _CriarPostagemPageState();
}

class _CriarPostagemPageState extends State<CriarPostagemPage> {
  final textoController = TextEditingController();
  final picker = ImagePicker();

  String nomeUsuario = '';
  String arrobaUsuario = '';
  int usuarioId = 0;
  File? imagemSelecionada;

  @override
  void initState() {
    super.initState();
    carregarDadosUsuario();
  }

  Future<void> carregarDadosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nomeUsuario = prefs.getString('nome') ?? '';
      arrobaUsuario = prefs.getString('arroba') ?? '';
      usuarioId = prefs.getInt('usuario_id') ?? 0;
    });
  }

  Future<void> tirarFoto() async {
    try {
      final foto = await picker.pickImage(source: ImageSource.camera);
      if (foto != null) {
        setState(() {
          imagemSelecionada = File(foto.path);
        });
      }
    } catch (_) {}
  }

  Future<void> publicar() async {
    final texto = textoController.text.trim();

    if (texto.isEmpty && imagemSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione um texto ou tire uma foto')),
      );
      return;
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/salvar_postagem.php'),
      );

      request.fields['usuario_id'] = usuarioId.toString();
      request.fields['texto'] = texto;

      if (imagemSelecionada != null) {
        request.files.add(
          await http.MultipartFile.fromPath('foto', imagemSelecionada!.path),
        );
      }

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode == 200) {
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Logado como: $nomeUsuario ($arrobaUsuario)',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textoController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'O que está acontecendo?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (imagemSelecionada != null) ...[
                Center(
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Image.file(
                        imagemSelecionada!,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            imagemSelecionada = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: tirarFoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Foto (Opcional)'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: publicar,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Publicar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
