import 'package:flutter/material.dart';

class StudyAcademicPage extends StatelessWidget {
  const StudyAcademicPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study & Academic'),
      ),
      body: const Center(
        child: Text('Study & Academic Features'),
      ),
    );
  }
}
