import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/post_provider.dart';
import '../providers/posts_provider.dart';
import '../providers/user_posts_provider.dart' hide userPostsProvider;
import '../providers/auth_notifier.dart';

class PostScreen extends ConsumerStatefulWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends ConsumerState<PostScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  File? _mediaFile;
  bool _isLoading = false;
  String? _error;

  final _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _mediaFile = File(pickedFile.path);
          _error = null;
        });
        print('📸 Image selected: ${pickedFile.name}');
      }
    } catch (e) {
      print('❌ Error picking image: $e');
    }
  }

  Future<void> _submitPost() async {
    if (_titleController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter a title');
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter a description');
      return;
    }

    if (_categoryController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter a category');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final postFormNotifier = ref.read(postFormProvider.notifier);

      postFormNotifier.setTitle(_titleController.text.trim());
      postFormNotifier.setDescription(_descriptionController.text.trim());
      postFormNotifier.setCategory(_categoryController.text.trim());

      if (_mediaFile != null) {
        postFormNotifier.setMediaFile(_mediaFile);
      }

      final result = await postFormNotifier.submitPost();

      setState(() => _isLoading = false);

      if (result['success']) {
        _titleController.clear();
        _descriptionController.clear();
        _categoryController.clear();

        setState(() {
          _mediaFile = null;
          _error = null;
        });
        ref.refresh(postsProvider);
        ref.refresh(userPostsProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Post created successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        String errorMsg = result['message'] ?? 'Failed to create post';
        setState(() => _error = errorMsg);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ $errorMsg'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final token = ref.watch(authTokenProvider);

    if (token == null || token.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Create Post'),
          backgroundColor: const Color.fromARGB(255, 76, 44, 192),
        ),
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                    color: Colors.white.withOpacity(0.2), width: 1.0),
              ),
              child: const Center(
                child: AnimatedShimmerText(
                  text: 'Create Post',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
                      Color.fromARGB(255, 0, 0, 0),
                      Color.fromARGB(255, 76, 48, 191),
                      Color.fromARGB(255, 0, 0, 0),
                    ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_error != null) ...[
                _glassBox(
                  child: Row(
                    children: [
                     
                      
                      
                    ],
                  ),
                  borderColor: Colors.red.shade300,
                  bgColor: const Color.fromARGB(255, 216, 207, 223).withOpacity(0.2),
                ),
                const SizedBox(height: 60),
              ],

              const Text('Title',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 10),
              _glassTextField(
                controller: _titleController,
                hint: 'What\'s on your mind?',
                icon: Icons.title,
                maxLength: 100,
                maxLines: 1,
              ),
              const SizedBox(height: 5),

              const Text('Description',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 8),
              _glassTextField(
                controller: _descriptionController,
                hint: 'Tell us more...',
                icon: Icons.description,
                maxLength: 500,
                maxLines: 5,
              ),
              const SizedBox(height: 16),

              const Text('Category',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 8),
              _glassTextField(
                controller: _categoryController,
                hint: 'e.g., Academic, Events, General...',
                icon: Icons.category,
                maxLines: 1,
              ),
              const SizedBox(height: 16),

              if (_mediaFile != null) ...[
                const Text('Media Preview',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _mediaFile!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: _isLoading
                            ? null
                            : () => setState(() => _mediaFile = null),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              GestureDetector(
                onTap: _isLoading ? null : _pickImage,
                child: _glassBox(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add_photo_alternate,
                          color: Colors.blue.shade700,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _mediaFile == null ? 'Add Photo' : 'Change Photo',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Choose from gallery',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
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
                  onPressed: _isLoading ? null : _submitPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 100, 32, 195),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Post Now',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 250),
            ],
          ),
        ),
      ),
    );
  }

  // Glassmorphic container helper
  Widget _glassBox({
    required Widget child,
    Color bgColor = Colors.white24,
    Color borderColor = Colors.white24,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _glassTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLength = 100,
    int maxLines = 1,
  }) {
    return _glassBox(
      child: TextField(
        controller: controller,
        maxLength: maxLength,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: Icon(icon, color: Colors.white70),
          border: InputBorder.none,
          counterText: '',
        ),
      ),
      bgColor: const Color.fromARGB(255, 72, 13, 159).withOpacity(0.1),
      borderColor: Colors.white.withOpacity(0.3),
    );
  }
}

class AnimatedShimmerText extends StatefulWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;

  const AnimatedShimmerText({
    Key? key,
    required this.text,
    this.fontSize = 20,
    this.fontWeight = FontWeight.bold,
    this.letterSpacing = 1.0,
  }) : super(key: key);

  @override
  State<AnimatedShimmerText> createState() => _AnimatedShimmerTextState();
}

class _AnimatedShimmerTextState extends State<AnimatedShimmerText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment(-1.0 + _controller.value * 2, 0),
              end: Alignment(1.0 + _controller.value * 2, 0),
              colors: [
                const Color.fromARGB(255, 246, 241, 241),
                Colors.blue.shade100,
                Colors.white,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(rect);
          },
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: widget.fontWeight,
              color: Colors.white,
              letterSpacing: widget.letterSpacing,
            ),
          ),
        );
      },
    );
  }
}
