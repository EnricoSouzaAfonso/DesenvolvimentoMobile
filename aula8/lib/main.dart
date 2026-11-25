import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: GaleriaWikiPage(),
  ));
}

class GaleriaWikiPage extends StatefulWidget {
  const GaleriaWikiPage({super.key});

  @override
  State<GaleriaWikiPage> createState() => _GaleriaWikiPageState();
}

class _GaleriaWikiPageState extends State<GaleriaWikiPage> {
  final List<String> imagens = [
    'assets/foto1.jpg',
    'assets/foto2.jpg',
    'assets/foto3.jpg',
    'assets/foto4.jpg',
    'assets/foto5.jpg',
  ];

  final List<String> aprovadas = [];

  Future<void> abrirAvaliacao(String caminho) async {
    final bool? resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AvaliarFotoPage(caminho: caminho),
      ),
    );

    if (resultado != null) {
      setState(() {
        if (resultado) {
          if (!aprovadas.contains(caminho)) {
            aprovadas.add(caminho);
          }
        } else {
          aprovadas.remove(caminho);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galeria Wiki'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FotosAprovadasPage(aprovadas: aprovadas),
                ),
              );
            },
            icon: const Icon(Icons.check_circle),
            label: Text('Aprovadas (${aprovadas.length})'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          itemCount: imagens.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final caminho = imagens[index];
            final foiAprovada = aprovadas.contains(caminho);

            return GestureDetector(
              onTap: () => abrirAvaliacao(caminho),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      caminho,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image),
                    ),
                  ),
                  if (foiAprovada)
                    const Positioned(
                      top: 4,
                      right: 4,
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 22,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class AvaliarFotoPage extends StatelessWidget {
  final String caminho;

  const AvaliarFotoPage({super.key, required this.caminho});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Avaliar Foto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  caminho,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 80),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: const Icon(Icons.check),
                    label: const Text('APROVAR'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: const Icon(Icons.close),
                    label: const Text('REPROVAR'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FotosAprovadasPage extends StatelessWidget {
  final List<String> aprovadas;

  const FotosAprovadasPage({super.key, required this.aprovadas});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fotos Aprovadas')),
      body: aprovadas.isEmpty
          ? const Center(child: Text('Nenhuma foto aprovada ainda'))
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: GridView.builder(
                itemCount: aprovadas.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      aprovadas[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image),
                    ),
                  );
                },
              ),
            ),
    );
  }
}