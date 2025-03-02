import 'package:flutter/material.dart';

void main() {
  runApp(const LibrasAKilogramosApp());
}

class LibrasAKilogramosApp extends StatelessWidget {
  const LibrasAKilogramosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Convertidor de Libras a Kilos',
      theme: ThemeData(
        primarySwatch: const MaterialColor(0xFFD4CE38, {
          50: const Color(0xFFFAF9E6),
          100: const Color(0xFFF3F1C1),
          200: const Color(0xFFEBE898),
          300: const Color(0xFFE3DF6F),
          400: const Color(0xFFDDD851),
          500: const Color(0xFFD4CE38), // Your specified color
          600: const Color(0xFFCFC932),
          700: const Color(0xFFC9C22B),
          800: const Color(0xFFC3BC24),
          900: const Color(0xFFB9B017),
        }),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4CE38),
          primary: const Color(0xFFD4CE38),
        ),
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
        backgroundColor: const Color(0xFFD4CE38),
        title: const Text(
          'Convertidor de Libras a Kilogramos',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Ingrese libras',
                labelStyle: TextStyle(color: Color(0xFFD4CE38)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD4CE38)),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _convert,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4CE38),
                foregroundColor: Colors.white,
              ),
              child: const Text('Convertir'),
            ),
            const SizedBox(height: 20),
            Text(
              'Resultado: $_result kilogramos',
              style: const TextStyle(
                fontSize: 20,
                color: Color(0xFFD4CE38),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
