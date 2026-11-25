import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://10.0.2.2/atividades';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AtividadesPage(),
  ));
}

class AtividadesPage extends StatefulWidget {
  const AtividadesPage({super.key});

  @override
  State<AtividadesPage> createState() => _AtividadesPageState();
}

class _AtividadesPageState extends State<AtividadesPage> {
  final diaController = TextEditingController();
  final atividadeController = TextEditingController();

  int mesSelecionado = DateTime.now().month;
  int anoSelecionado = DateTime.now().year;
  var atividades = [];

  @override
  void initState() {
    super.initState();
    carregarAtividades();
  }

  Future<void> carregarAtividades() async {
    try {
      final resposta = await http.get(
        Uri.parse('$baseUrl/listar_atividades.php?mes=$mesSelecionado&ano=$anoSelecionado'),
      );

      if (resposta.statusCode == 200) {
        setState(() {
          atividades = jsonDecode(resposta.body);
        });
      }
    } catch (_) {}
  }

  Future<void> salvarAtividade() async {
    final dia = diaController.text.trim();
    final atividade = atividadeController.text.trim();

    if (dia.isEmpty || atividade.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o dia e a atividade')),
      );
      return;
    }

    try {
      final resposta = await http.post(
        Uri.parse('$baseUrl/salvar_atividade.php'),
        body: {
          'dia': dia,
          'atividade': atividade,
        },
      );

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);
        if (dados['status'] == 'sucesso') {
          diaController.clear();
          atividadeController.clear();
          await carregarAtividades();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Atividade salva com sucesso!')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(dados['mensagem'] ?? 'Erro ao salvar')),
            );
          }
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao conectar ao servidor')),
        );
      }
    }
  }

  @override
  void dispose() {
    diaController.dispose();
    atividadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Atividades do Dia')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: diaController,
              decoration: const InputDecoration(
                labelText: 'Dia (ex: 25/11/2026 ou 25)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: atividadeController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Atividade desenvolvida',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: salvarAtividade,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(45),
              ),
              child: const Text('Salvar'),
            ),
            const Divider(height: 28),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<int>(
                    value: mesSelecionado,
                    decoration: const InputDecoration(
                      labelText: 'Mês',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Janeiro')),
                      DropdownMenuItem(value: 2, child: Text('Fevereiro')),
                      DropdownMenuItem(value: 3, child: Text('Março')),
                      DropdownMenuItem(value: 4, child: Text('Abril')),
                      DropdownMenuItem(value: 5, child: Text('Maio')),
                      DropdownMenuItem(value: 6, child: Text('Junho')),
                      DropdownMenuItem(value: 7, child: Text('Julho')),
                      DropdownMenuItem(value: 8, child: Text('Agosto')),
                      DropdownMenuItem(value: 9, child: Text('Setembro')),
                      DropdownMenuItem(value: 10, child: Text('Outubro')),
                      DropdownMenuItem(value: 11, child: Text('Novembro')),
                      DropdownMenuItem(value: 12, child: Text('Dezembro')),
                    ],
                    onChanged: (valor) {
                      if (valor != null) {
                        setState(() {
                          mesSelecionado = valor;
                        });
                        carregarAtividades();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: anoSelecionado,
                    decoration: const InputDecoration(
                      labelText: 'Ano',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (int i = 0; i < 5; i++)
                        DropdownMenuItem(
                          value: DateTime.now().year - i,
                          child: Text('${DateTime.now().year - i}'),
                        ),
                    ],
                    onChanged: (valor) {
                      if (valor != null) {
                        setState(() {
                          anoSelecionado = valor;
                        });
                        carregarAtividades();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: atividades.isEmpty
                  ? const Center(child: Text('Nenhuma atividade neste mês'))
                  : ListView.builder(
                      itemCount: atividades.length,
                      itemBuilder: (context, index) {
                        final item = atividades[index];
                        return Card(
                          child: ListTile(
                            title: Text(item['atividade'] ?? ''),
                            subtitle: Text('Data: ${item['dia_formatado'] ?? ''}'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}