import 'package:flutter/material.dart';
import '../../../data/repositories/rates_repo.dart';

class RatesPage extends StatefulWidget {
  const RatesPage({super.key});

  @override
  State<RatesPage> createState() => _RatesPageState();
}

class _RatesPageState extends State<RatesPage> {
  Future<Map<String, double>>? future;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      error = null;
      future = RatesRepo().fetchRates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exchange Rates')),
      body: FutureBuilder<Map<String, double>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Could not load rates.\nCheck your internet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _load,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final rates = snapshot.data!;
          final entries = rates.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key));

          return ListView.separated(
            itemCount: entries.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final e = entries[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.amber.shade100,
                  child: Text(e.key[0],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                title: Text('1 RWF = ${e.value.toStringAsFixed(6)} ${e.key}'),
              );
            },
          );
        },
      ),
    );
  }
}