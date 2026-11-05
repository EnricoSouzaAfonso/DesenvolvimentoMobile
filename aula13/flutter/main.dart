import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GaleriaXuitterPage(),
    );
  }
}

class GaleriaXuitterPage extends StatefulWidget {
  const GaleriaXuitterPage({super.key});

  @override
  State<GaleriaXuitterPage> createState() => _GaleriaXuitterPageState();
}

class _GaleriaXuitterPageState extends State<GaleriaXuitterPage> {
  final baseUrl = 'http://10.0.2.2/xuitter';
  final controllerDescricao = TextEditingController();
  final picker = ImagePicker();

  File? imagemLocal;
  List<dynamic> fotos = [];
  int indiceFotoAtual = 0;

  Future<void> capturarFoto() async {
    try {
      final foto = await picker.pickImage(source: ImageSource.camera);
      if (foto != null) {
        setState(() {
          imagemLocal = File(foto.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissao de camara recusada')),
        );
      }
    }
  }

  Future<void> enviarPostagem() async {
    if (imagemLocal == null || controllerDescricao.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tire uma foto e digite uma descricao')),
      );
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/salvar_postagem.php'),
    );

    request.fields['descricao'] = controllerDescricao.text.trim();
    request.files.add(
      await http.MultipartFile.fromPath('foto', imagemLocal!.path),
    );

    var resposta = await request.send();

    if (resposta.statusCode == 200) {
      setState(() {
        imagemLocal = null;
        controllerDescricao.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publicacao enviada com sucesso')),
        );
      }
      carregarTodasFotos();
    }
  }

  Future<void> carregarTodasFotos() async {
    try {
      final resposta = await http
          .get(Uri.parse('$baseUrl/listar_todas_fotos.php'))
          .timeout(const Duration(seconds: 5));

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);
        if (mounted) {
          setState(() {
            fotos = dados;
            if (indiceFotoAtual >= fotos.length) {
              indiceFotoAtual = fotos.isEmpty ? 0 : fotos.length - 1;
            }
          });
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao contactar o servidor')),
        );
      }
    }
  }

  void fotoAnterior() {
    if (indiceFotoAtual > 0) {
      setState(() {
        indiceFotoAtual--;
      });
    }
  }

  void fotoProxima() {
    if (indiceFotoAtual < fotos.length - 1) {
      setState(() {
        indiceFotoAtual++;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    carregarTodasFotos();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Xuitter Fotos'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Enviar Foto'),
              Tab(text: 'Visualizar Fotos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    imagemLocal != null
                        ? Image.file(
                            imagemLocal!,
                            height: 240,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: 240,
                            width: double.infinity,
                            color: Colors.grey[200],
                            alignment: Alignment.center,
                            child: const Text('Nenhuma foto capturada'),
                          ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: capturarFoto,
                      child: const Text('Tirar Foto'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controllerDescricao,
                      decoration: const InputDecoration(
                        labelText: 'Descricao da foto',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: enviarPostagem,
                      child: const Text('Enviar ao Servidor'),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: fotos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Nenhuma foto encontrada no servidor'),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: carregarTodasFotos,
                            child: const Text('Recarregar'),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Foto ${indiceFotoAtual + 1} de ${fotos.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Image.network(
                          '$baseUrl/uploads/${fotos[indiceFotoAtual]['arquivo']}',
                          height: 260,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 80),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          fotos[indiceFotoAtual]['descricao'] ?? '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: indiceFotoAtual > 0 ? fotoAnterior : null,
                              child: const Text('Anterior'),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: indiceFotoAtual < fotos.length - 1 ? fotoProxima : null,
                              child: const Text('Proxima'),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}