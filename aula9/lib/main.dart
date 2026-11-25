import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: BuscaCepPage(),
  ));
}

class BuscaCepPage extends StatefulWidget {
  const BuscaCepPage({super.key});

  @override
  State<BuscaCepPage> createState() => _BuscaCepPageState();
}

class _BuscaCepPageState extends State<BuscaCepPage> {
  final cepController = TextEditingController();

  String rua = '';
  String bairro = '';
  String cidade = '';
  String estado = '';
  String mensagem = '';

  Future<void> buscarCep() async {
    final cep = cepController.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (cep.length != 8) {
      setState(() {
        mensagem = 'Digite um CEP válido com 8 números.';
        rua = '';
        bairro = '';
        cidade = '';
        estado = '';
      });
      return;
    }

    try {
      final resposta = await http.get(
        Uri.parse('https://viacep.com.br/ws/$cep/json/'),
      );

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);

        if (dados['erro'] == true || dados['erro'] == 'true') {
          setState(() {
            mensagem = 'CEP não encontrado.';
            rua = '';
            bairro = '';
            cidade = '';
            estado = '';
          });
        } else {
          setState(() {
            mensagem = '';
            rua = dados['logradouro'] ?? '';
            bairro = dados['bairro'] ?? '';
            cidade = dados['localidade'] ?? '';
            estado = dados['uf'] ?? '';
          });
        }
      } else {
        setState(() {
          mensagem = 'Erro ao consultar o CEP.';
        });
      }
    } catch (_) {
      setState(() {
        mensagem = 'Erro de conexão.';
      });
    }
  }

  @override
  void dispose() {
    cepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consulta CEP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: cepController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'CEP (ex: 01001000)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: buscarCep,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Buscar'),
            ),
            const SizedBox(height: 20),
            if (mensagem.isNotEmpty)
              Text(
                mensagem,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            if (rua.isNotEmpty || cidade.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rua: $rua', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Bairro: $bairro', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Cidade: $cidade', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Estado: $estado', style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}