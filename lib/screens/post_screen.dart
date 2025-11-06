import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/post_provider.dart';
import '../providers/user_posts_provider.dart';
import '../providers/posts_provider.dart';
import '../providers/auth_notifier.dart';

class PostScreen extends ConsumerWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(authTokenProvider);
    final formState = ref.watch(postFormProvider);
    final formNotifier = ref.read(postFormProvider.notifier);

    print('🔍 PostScreen build - Token: ${token?.substring(0, 20) ?? "null"}...');

    if (token == null || token.isEmpty) {
      print('❌ Not logged in - showing login prompt');
      return Scaffold(
        appBar: AppBar(title: const Text('Create Post')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'Please login to create posts',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    print('✅ Logged in - showing post form');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        backgroundColor: Colors.blue,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (formState.error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        formState.error!,
                        style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            const Text('Title', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              onChanged: formNotifier.setTitle,
              decoration: InputDecoration(
                hintText: 'What\'s on your mind?',
                prefixIcon: const Icon(Icons.title, color: Colors.blue),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
                counterText: '${formState.title.length}/100',
              ),
              maxLength: 100,
              enabled: !formState.isLoading,
            ),
            const SizedBox(height: 16),

            const Text('Description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              onChanged: formNotifier.setDescription,
              decoration: InputDecoration(
                hintText: 'Tell us more...',
                prefixIcon: const Icon(Icons.description, color: Colors.blue),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
                alignLabelWithHint: true,
                counterText: '${formState.description.length}/500',
              ),
              maxLines: 5,
              maxLength: 500,
              enabled: !formState.isLoading,
            ),
            const SizedBox(height: 16),

            const Text('Category', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              onChanged: formNotifier.setCategory,
              decoration: InputDecoration(
                hintText: 'e.g., Academic, Events, General...',
                prefixIcon: const Icon(Icons.category, color: Colors.blue),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              enabled: !formState.isLoading,
            ),
            const SizedBox(height: 16),

            if (formState.mediaFile != null) ...[
              const Text('Media Preview', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(formState.mediaFile!, height: 200, width: double.infinity, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => formNotifier.setMediaFile(null),
                      child: Container(
                        decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            GestureDetector(
              onTap: () async {
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                if (pickedFile != null) {
                  formNotifier.setMediaFile(File(pickedFile.path));
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.shade300, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blue.shade50,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.blue.shade100, shape: BoxShape.circle),
                      child: Icon(Icons.add_photo_alternate, color: Colors.blue.shade700, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formState.mediaFile == null ? 'Add Photo' : 'Change Photo',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                          ),
                          Text('Choose from gallery', style: TextStyle(fontSize: 12, color: Colors.blue.shade700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: formState.isLoading
                    ? null
                    : () async {
                        final result = await formNotifier.submitPost();
                        if (!context.mounted) return;

                        if (result['success']) {
                          print('✅ Post created successfully');
 
                          ref.refresh(userPostsProvider);
                          print('🔄 User posts refreshed');
                  
                          ref.refresh(postsProvider);
                          print('🔄 Posts feed refreshed');

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Post created!'),
                              backgroundColor: Colors.green,
                            ),
                          );

                          formNotifier.resetForm();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('❌ ${result['message']}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: formState.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Post Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
