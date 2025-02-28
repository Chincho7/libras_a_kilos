import 'package:flutter/material.dart';

void main() {
  runApp(const LibrasAKilogramosApp());
}

class LibrasAKilogramosApp extends StatelessWidget {
  const LibrasAKilogramosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Convertidor de Libras a Kilogramos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LibrasAKilogramosHomePage(),
    );
  }
}

class LibrasAKilogramosHomePage extends StatefulWidget {
  const LibrasAKilogramosHomePage({super.key});

  @override
  _LibrasAKilogramosHomePageState createState() =>
      _LibrasAKilogramosHomePageState();
}

class _LibrasAKilogramosHomePageState extends State<LibrasAKilogramosHomePage> {
  final TextEditingController _controller = TextEditingController();
  double _result = 0.0;

  void _convert() {
    setState(() {
      double pounds = double.tryParse(_controller.text) ?? 0.0;
      _result = pounds * 0.453592;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Convertidor de Libras a Kilogramos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Ingrese libras',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _convert,
              child: const Text('Convertir'),
            ),
            const SizedBox(height: 20),
            Text(
              'Resultado: $_result kilogramos',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
