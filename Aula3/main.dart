import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton( style: TextButton.styleFrom(
                padding: const EdgeInsets.all(10),
                foregroundColor: const Color.fromARGB(255, 255, 0, 0),
                textStyle: const TextStyle(fontSize: 28.00),
              ),
                onPressed: () {
                  print('Sim apertado');
                },
                child: const Text('Sim'),
              ),
              TextButton( style: TextButton.styleFrom(
                padding: const EdgeInsets.all(10),
                foregroundColor: const Color.fromARGB(255, 5, 1, 253),
                textStyle: const TextStyle(fontSize: 28.00)
                ),

                onPressed: () {
                  print('Não apertado');
                },
                child: const Text('Não'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

