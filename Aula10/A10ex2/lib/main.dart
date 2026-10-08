import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OrganizaPage(),
    );
  }
}

class OrganizaPage extends StatefulWidget {
  const OrganizaPage({super.key});

  @override
  State<OrganizaPage> createState() => _OrganizaPageState();
}

class _OrganizaPageState extends State<OrganizaPage> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    lerArquivo();
  }

  Future<String> getPastaDocumentos() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> getArquivo() async {
    final caminho = await getPastaDocumentos();
    return File('$caminho/organiza.md');
  }

  void lerArquivo() async {
    try {
      final arquivo = await getArquivo();
      final conteudo = await arquivo.readAsString();
      setState(() {
        controller.text = conteudo;
      });
    } catch (_) {
      setState(() {
        controller.text = '';
      });
    }
  }

  void salvarArquivo() async {
    final arquivo = await getArquivo();
    await arquivo.writeAsString(controller.text);
  }

  void apagarArquivo() async {
    final arquivo = await getArquivo();
    if (await arquivo.exists()) {
      await arquivo.delete();
    }
    setState(() {
      controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor organiza.md'),
      ),
      body: Column(
        children: [
          TextField(
            controller: controller,
            maxLines: 20,
            decoration: const InputDecoration(labelText: 'Escreva aqui'),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: salvarArquivo,
                child: const Text('Salvar'),
              ),
              ElevatedButton(
                onPressed: apagarArquivo,
                child: const Text('Apagar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
