import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController salvaNome = TextEditingController();
  TextEditingController salvaIdade = TextEditingController();

  TextEditingController atualizaId = TextEditingController();
  TextEditingController atualizaNome = TextEditingController();
  TextEditingController atualizaIdade = TextEditingController();

  TextEditingController apagaId = TextEditingController();

  List<Map<String, dynamic>> listaPets = [];

  void carregarPets() async {
    final dados = await DatabaseHelper.listar();
    setState(() {
      listaPets = dados;
    });
  }

  void salvar() async {
    await DatabaseHelper.inserir({
      'nome': salvaNome.text,
      'idade': int.tryParse(salvaIdade.text) ?? 0,
    });
    salvaNome.clear();
    salvaIdade.clear();
  }

  void atualizar() async {
    final id = int.tryParse(atualizaId.text) ?? 0;
    await DatabaseHelper.atualizar(id, {
      'nome': atualizaNome.text,
      'idade': int.tryParse(atualizaIdade.text) ?? 0,
    });
    atualizaId.clear();
    atualizaNome.clear();
    atualizaIdade.clear();
  }

  void apagar() async {
    final id = int.tryParse(apagaId.text) ?? 0;
    await DatabaseHelper.apagar(id);
    apagaId.clear();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pets SQLite'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Salvar'),
              Tab(text: 'Listar'),
              Tab(text: 'Atualizar'),
              Tab(text: 'Apagar'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Column(
              children: [
                TextField(
                  controller: salvaNome,
                  decoration: const InputDecoration(labelText: 'Nome do pet'),
                ),
                TextField(
                  controller: salvaIdade,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Idade do pet'),
                ),
                ElevatedButton(
                  onPressed: salvar,
                  child: const Text('Salvar'),
                ),
              ],
            ),
            Column(
              children: [
                ElevatedButton(
                  onPressed: carregarPets,
                  child: const Text('Atualizar Lista'),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: listaPets.length,
                    itemBuilder: (context, index) {
                      final pet = listaPets[index];
                      return ListTile(
                        title: Text('ID: ${pet['id']} - Nome: ${pet['nome']}'),
                        subtitle: Text('Idade: ${pet['idade']} anos'),
                      );
                    },
                  ),
                ),
              ],
            ),
            Column(
              children: [
                TextField(
                  controller: atualizaId,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'ID do pet'),
                ),
                TextField(
                  controller: atualizaNome,
                  decoration: const InputDecoration(labelText: 'Novo nome'),
                ),
                TextField(
                  controller: atualizaIdade,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Nova idade'),
                ),
                ElevatedButton(
                  onPressed: atualizar,
                  child: const Text('Atualizar'),
                ),
              ],
            ),
            Column(
              children: [
                TextField(
                  controller: apagaId,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'ID do pet'),
                ),
                ElevatedButton(
                  onPressed: apagar,
                  child: const Text('Apagar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}