import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const HomeMaterial(),
    );
  }
}

class HomeMaterial extends StatefulWidget {
  const HomeMaterial({super.key});

  @override
  State<HomeMaterial> createState() => _HomeMaterialState();
}

class _HomeMaterialState extends State<HomeMaterial> {
  late Future<Map<String, dynamic>> dadosCotacoes;

  @override
  void initState() {
    super.initState();
    dadosCotacoes = getDadosCotacoes();
  }

  Future<Map<String, dynamic>> getDadosCotacoes() async {
    try {
      final res = await http.get(
        Uri.parse('http://api.hgbrasil.com/finance/quotations?key=715292eb'),
      );

      if (res.statusCode != HttpStatus.ok) {
        throw 'Erro ao buscar dados: ${res.statusCode}';
      }

      final data = jsonDecode(res.body);
      return data;
    } catch (e) {
      throw 'Ocorreu um erro: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cotações Brasil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                dadosCotacoes = getDadosCotacoes();
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: dadosCotacoes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: Text("Sem dados no momento."),
            );
          }

          final data = snapshot.data!;
          final results = data["results"] ?? {};
          final currencies = results["currencies"] ?? {};
          final stocks = results["stocks"] ?? {};

          final usd = currencies["USD"] ?? {};
          final usdName = usd["name"] ?? "Dollar";
          final usdBuy = usd["buy"] ?? 0.0;
          final usdVariation = usd["variation"] ?? 0.0;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            usdName,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "R\$ ${usdBuy.toStringAsFixed(4)}",
                            style: const TextStyle(fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            usdVariation >= 0
                                ? "+${usdVariation.toStringAsFixed(3)}"
                                : usdVariation.toStringAsFixed(3),
                            style: const TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  'Outras moedas',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildCurrencyCard("EUR", currencies),
                        const SizedBox(width: 8),
                        _buildCurrencyCard("GBP", currencies),
                        const SizedBox(width: 8),
                        _buildCurrencyCard("ARS", currencies),
                        const SizedBox(width: 8),
                        _buildCurrencyCard("JPY", currencies),
                        const SizedBox(width: 8),
                        _buildCurrencyCard("CNY", currencies),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  'Bolsa de Valores',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStockColumn("IBOVESPA", stocks),
                    _buildStockColumn("IBOVESPA", stocks),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrencyCard(String code, Map<String, dynamic> currencies) {
    final Map<String, dynamic>? currency = currencies[code];
    if (currency == null) {
      return Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: SizedBox(
          width: 130,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text(
                  "N/A",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  "null",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  "0.0",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final name = currency["name"] ?? code;
    final buy = currency["buy"];
    final variation = currency["variation"] ?? 0.0;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        width: 130,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                buy != null ? buy.toStringAsFixed(4) : "null",
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                variation >= 0
                    ? "+${variation.toStringAsFixed(3)}"
                    : variation.toStringAsFixed(3),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockColumn(String code, Map<String, dynamic> stocks) {
    final Map<String, dynamic>? stock = stocks[code];
    if (stock == null) {
      return Column(
        children: const [
          Text("N/A"),
          SizedBox(height: 8),
          Text("No location"),
          Text("0.0"),
        ],
      );
    }

    final location = stock["location"] ?? "Unknown";
    final variation = stock["variation"] ?? 0.0;

    return Column(
      children: [
        Text(
          code,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          location,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          variation.toStringAsFixed(2),
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
