import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Treino de Tabuada',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TabuadaPage(),
    );
  }
}

class TabuadaPage extends StatefulWidget {
  const TabuadaPage({super.key});

  @override
  State<TabuadaPage> createState() => _TabuadaPageState();
}

class _TabuadaPageState extends State<TabuadaPage> {
  int _fator1 = 1;
  int _fator2 = 1;
  String _respostaUsuario = '';
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _gerarNovaOperacao();
  }

  void _gerarNovaOperacao() {
    final random = Random();
    setState(() {
      _fator1 = random.nextInt(10) + 1;
      _fator2 = random.nextInt(10) + 1;
      _respostaUsuario = '';
      _controller.clear();
    });
  }

  Widget? _obterIconeValidacao() {
    if (_respostaUsuario.isEmpty) {
      return null;
    }
    
    final respostaInt = int.tryParse(_respostaUsuario);
    final estaCorreto = respostaInt == (_fator1 * _fator2);

    if (estaCorreto) {
      return const Icon(Icons.check_circle, color: Colors.green, size: 32);
    } else {
      return const Icon(Icons.cancel, color: Colors.red, size: 32);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Treino de Tabuada'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$_fator1 x $_fator2 = ?',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: 'Sua resposta',
                border: const OutlineInputBorder(),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: _obterIconeValidacao(),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _respostaUsuario = value;
                });
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _gerarNovaOperacao,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Próxima Operação',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}