import 'package:flutter/cupertino.dart';

class FormulaPage extends StatelessWidget {
  const FormulaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground,
        border: null,
        padding: EdgeInsetsDirectional.zero,
        middle: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Guía de Conversión',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildFormulaCard(
                title: 'Libras a Kilogramos',
                formula: 'kg = lb × 0.453592',
                example: '100 lb = 100 × 0.453592 = 45.3592 kg',
              ),
              const SizedBox(height: 20),
              _buildFormulaCard(
                title: 'Kilogramos a Libras',
                formula: 'lb = kg × 2.20462',
                example: '1 kg = 1 × 2.20462 = 2.20462 lb',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormulaCard({
    required String title,
    required String formula,
    required String example,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.systemGrey4),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD4CE38), // Changed from systemGreen to #d4ce38
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Fórmula:',
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formula,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Ejemplo:',
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            example,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
