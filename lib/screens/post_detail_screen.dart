import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final postIdProvider = Provider.family<String, String>((ref, postId) {
  return postId;
});

class PostDetailScreen extends ConsumerWidget {
  final String postId;

  const PostDetailScreen({Key? key, required this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
      ),
      body: Center(
        child: Text(
          'Showing details for post:\n$postId',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
