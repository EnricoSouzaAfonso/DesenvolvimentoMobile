import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Galeria Wikipedia',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const GaleriaPage(),
    );
  }
}

class GaleriaPage extends StatefulWidget {
  const GaleriaPage({super.key});

  @override
  State<GaleriaPage> createState() => _GaleriaPageState();
}

class _GaleriaPageState extends State<GaleriaPage> {
  final List<String> imagens = [
    'https://upload.wikimedia.org/wikipedia/commons/6/69/NASA-HS201427a-HubbleUltraDeepField2014-20140603.jpg?',
    'https://upload.wikimedia.org/wikipedia/commons/e/ed/WMAP_2012.png?',
    'https://upload.wikimedia.org/wikipedia/commons/6/6f/CMB_Timeline300_no_WMAP.jpg?',
    'https://upload.wikimedia.org/wikipedia/commons/0/0f/Earth%27s_Location_in_the_Universe_SMALLER_%28JPEG%29.jpg?',
    'https://upload.wikimedia.org/wikipedia/commons/3/37/Universe_expansion2.png?'
  ];

  int indiceAtual = 0;
  final Set<int> imagensGostei = {};

  void _proximaImagem() {
    if (indiceAtual < imagens.length - 1) {
      setState(() {
        indiceAtual++;
      });
    }
  }

  void _imagemAnterior() {
    if (indiceAtual > 0) {
      setState(() {
        indiceAtual--;
      });
    }
  }

  void _alternarGostei() {
    setState(() {
      if (imagensGostei.contains(indiceAtual)) {
        imagensGostei.remove(indiceAtual);
      } else {
        imagensGostei.add(indiceAtual);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Imagens da Wikipedia'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              imagens[indiceAtual],
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            IconButton(
              icon: Icon(
                imagensGostei.contains(indiceAtual)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: imagensGostei.contains(indiceAtual) ? Colors.red : null,
              ),
              iconSize: 40,
              onPressed: _alternarGostei,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: indiceAtual > 0 ? _imagemAnterior : null,
                  child: const Text('Anterior'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed:
                      indiceAtual < imagens.length - 1 ? _proximaImagem : null,
                  child: const Text('Próxima'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Imagem ${indiceAtual + 1} de ${imagens.length}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}