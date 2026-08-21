import 'package:flutter/material.dart';

void main() {
  runApp(const DespensaApp());
}

class DespensaApp extends StatelessWidget {
  const DespensaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Despensa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F6B48)),
        useMaterial3: true,
      ),
      home: const ProjectSetupScreen(),
    );
  }
}

class ProjectSetupScreen extends StatelessWidget {
  const ProjectSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Despensa')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.kitchen_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Tu hogar, mejor organizado',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Gestiona el inventario doméstico, controla las fechas de '
                'caducidad y comparte la cesta de la compra.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
              const Text('Proyecto base configurado correctamente.'),
            ],
          ),
        ),
      ),
    );
  }
}
