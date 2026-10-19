import 'package:flutter/material.dart';

import 'plan_form_screen.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plans')),
      body: const Center(child: Text('Your plans will show here.')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const PlanFormScreen())),
        icon: const Icon(Icons.add),
        label: const Text('New Plan'),
      ),
    );
  }
}
