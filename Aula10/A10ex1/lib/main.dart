import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CepPage(),
    );
  }
}

class CepPage extends StatefulWidget {
  const CepPage({super.key});

  @override
  State<CepPage> createState() => _CepPageState();
}

class _CepPageState extends State<CepPage> {
  TextEditingController cepController = TextEditingController();
  TextEditingController numeroController = TextEditingController();
  
  String rua = '';
  String bairro = '';
  String cidade = '';
  String estado = '';

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  void carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      cepController.text = prefs.getString('cep') ?? '';
      numeroController.text = prefs.getString('numero') ?? '';
      rua = prefs.getString('rua') ?? '';
      bairro = prefs.getString('bairro') ?? '';
      cidade = prefs.getString('cidade') ?? '';
      estado = prefs.getString('estado') ?? '';
    });
  }

  void buscarESalvar() async {
    String cep = cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cep.length == 8) {
      final url = Uri.parse('https://viacep.com.br/ws/$cep/json/');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final dados = json.decode(response.body);
        
        if (dados['erro'] == null) {
          setState(() {
            rua = dados['logradouro'] ?? '';
            bairro = dados['bairro'] ?? '';
            cidade = dados['localidade'] ?? '';
            estado = dados['uf'] ?? '';
          });
          
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('cep', cepController.text);
          await prefs.setString('numero', numeroController.text);
          await prefs.setString('rua', rua);
          await prefs.setString('bairro', bairro);
          await prefs.setString('cidade', cidade);
          await prefs.setString('estado', estado);
        }
      }
    }
  }

  void apagarDados() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    setState(() {
      cepController.clear();
      numeroController.clear();
      rua = '';
      bairro = '';
      cidade = '';
      estado = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta CEP'),
      ),
      body: Column(
        children: [
          TextField(
            controller: cepController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'CEP'),
          ),
          TextField(
            controller: numeroController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Número da Casa'),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: buscarESalvar,
                child: const Text('Buscar e Salvar'),
              ),
              ElevatedButton(
                onPressed: apagarDados,
                child: const Text('Apagar'),
              ),
            ],
          ),
          Text('Rua: $rua'),
          Text('Bairro: $bairro'),
          Text('Cidade: $cidade'),
          Text('Estado: $estado'),
        ],
      ),
    );
  }
}