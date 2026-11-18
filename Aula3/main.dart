import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: JogoAdivinhacao(),
  ));
}

class JogoAdivinhacao extends StatefulWidget {
  const JogoAdivinhacao({super.key});

  @override
  State<JogoAdivinhacao> createState() => _JogoAdivinhacaoState();
}

class _JogoAdivinhacaoState extends State<JogoAdivinhacao> {
  String resultado = 'Escolha um número de 1 a 5';

  void verificar(int palpite) {
    int sorteado = Random().nextInt(5) + 1;

    setState(() {
      if (palpite == sorteado) {
        resultado = 'Acertou! O número era $sorteado.';
      } else {
        resultado = 'Errou! Você escolheu $palpite e o número era $sorteado.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adivinhe o Número')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              resultado,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => verificar(1),
                  child: const Text('1'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => verificar(2),
                  child: const Text('2'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => verificar(3),
                  child: const Text('3'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => verificar(4),
                  child: const Text('4'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => verificar(5),
                  child: const Text('5'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
