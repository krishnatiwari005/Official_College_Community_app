import 'package:flutter/material.dart';

class MentalHealthPage extends StatelessWidget {
  const MentalHealthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mental Health & Wellness'),
      ),
      body: const Center(
        child: Text('Mental Health & Wellness Features'),
      ),
    );
  }
}
