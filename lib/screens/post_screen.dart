// lib/screens/post_screen.dart
import 'dart:io';
import 'dart:ui';
import 'package:community_app/widgets/multi_select_categories_dropdown.dart';
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
  File? _mediaFile;
  bool _isLoading = false;
  String? _error;
  List<String> _selectedCategories = [];
  final _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select Image Source',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.blue, size: 26),
                        ),
                        title: const Text('Camera', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Take a new photo'),
                        onTap: () => Navigator.pop(context, ImageSource.camera),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.photo_library, color: Colors.green, size: 26),
                        ),
                        title: const Text('Gallery', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Choose from gallery'),
                        onTap: () => Navigator.pop(context, ImageSource.gallery),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );

      if (source != null) {
        final XFile? pickedFile = await _picker.pickImage(
          source: source,
          imageQuality: 80,
          maxWidth: 1920,
          maxHeight: 1080,
        );
        if (pickedFile != null) {
          setState(() {
            _mediaFile = File(pickedFile.path);
            _error = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
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
    if (_selectedCategories.isEmpty) {
      setState(() => _error = 'Please select at least one category');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final categoryString = _selectedCategories.join(', ');
      final postFormNotifier = ref.read(postFormProvider.notifier);

      postFormNotifier.setTitle(_titleController.text.trim());
      postFormNotifier.setDescription(_descriptionController.text.trim());
      postFormNotifier.setCategory(categoryString);
      if (_mediaFile != null) postFormNotifier.setMediaFile(_mediaFile);

      final result = await postFormNotifier.submitPost();

      setState(() => _isLoading = false);

      if (result['success']) {
        _titleController.clear();
        _descriptionController.clear();
        setState(() {
          _mediaFile = null;
          _selectedCategories = [];
          _error = null;
        });
        ref.refresh(postsProvider);
        ref.refresh(userPostsProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Post created successfully!'), backgroundColor: Colors.green),
          );
        }
      } else {
        final errorMsg = result['message'] ?? 'Failed to create post';
        setState(() => _error = errorMsg);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ $errorMsg'), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final token = ref.watch(authTokenProvider);

    if (token == null || token.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Create Post'), backgroundColor: const Color.fromARGB(255, 76, 44, 192)),
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('Please login to create posts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/login'), child: const Text('Go to Login')),
          ]),
        ),
      );
    }

    // Keep content below the AppBar and use purple gradient for the AppBar
    return Scaffold(
      extendBodyBehindAppBar: false, // important: body not under appbar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.only(top: 8),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(166, 18, 4, 143),
                    Color.fromARGB(166, 63, 11, 126),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                // subtle bottom border for separation
                border: Border(bottom: BorderSide(color: Colors.white24, width: 0.5)),
              ),
              child: const SafeArea(
                top: true,
                child: Center(
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
      ),

      // custom deep purple bottom nav — you can remove this if you use a global bottom nav
      bottomNavigationBar: _buildPurpleBottomBar(context),

      body: SafeArea(
        top: true,
        bottom: false,
        child: Container(
          decoration: const BoxDecoration(
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // small spacer so fields don't hug appbar
              const SizedBox(height: 4),

              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.red.shade50, border: Border.all(color: Colors.red.shade300), borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    Icon(Icons.error, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_error!, style: TextStyle(color: Colors.red.shade700))),
                  ]),
                ),
                const SizedBox(height: 16),
              ],

              const Text('Title', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              _glassTextField(controller: _titleController, hint: 'What\'s on your mind?', icon: Icons.title, maxLength: 100, maxLines: 1),
              const SizedBox(height: 16),

              const Text('Description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              _glassTextField(controller: _descriptionController, hint: 'Tell us more...', icon: Icons.description, maxLength: 500, maxLines: 5),
              const SizedBox(height: 16),

              const Text('Categories *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              MultiSelectCategoriesDropdown(selectedCategories: _selectedCategories, onChanged: (selected) => setState(() => _selectedCategories = selected)),
              const SizedBox(height: 16),

              if (_mediaFile != null) ...[
                const Text('Media Preview', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                Stack(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_mediaFile!, height: 200, width: double.infinity, fit: BoxFit.cover)),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _isLoading ? null : () => setState(() => _mediaFile = null),
                      child: Container(decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), padding: const EdgeInsets.all(8), child: const Icon(Icons.close, color: Colors.white, size: 20)),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
              ],

              GestureDetector(
                onTap: _isLoading ? null : _pickImage,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(border: Border.all(color: Colors.blue.shade300, width: 2), borderRadius: BorderRadius.circular(12), color: Colors.blue.shade50),
                  child: Row(children: [
                    Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blue.shade100, shape: BoxShape.circle), child: Icon(Icons.add_photo_alternate, color: Colors.blue.shade700, size: 22)),
                    const SizedBox(width: 16),
                    Expanded(child: Text(_mediaFile == null ? 'Add Photo' : 'Change Photo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue.shade900))),
                    Text('Choose from gallery', style: TextStyle(fontSize: 12, color: Colors.blue.shade700)),
                  ]),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.send, color: Colors.white), SizedBox(width: 8), Text('Post Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))]),
                ),
              ),

              const SizedBox(height: 20),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildPurpleBottomBar(BuildContext context) {
    // This is a simple rounded top bottom bar. Remove if you use app-level navigation.
    return Container(
      height: 82,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF4B2BBF), // deep purple
            Color(0xFF2E1A7A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          IconButton(icon: const Icon(Icons.home_outlined, color: Colors.white70), onPressed: () => Navigator.pushReplacementNamed(context, '/home')),
          IconButton(icon: const Icon(Icons.chat_bubble_outline, color: Colors.white70), onPressed: () => Navigator.pushNamed(context, '/chats')),
          // center "add" button style
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Color(0xFF7B3FF0), Color(0xFFA05CFF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              boxShadow: [BoxShadow(color: Colors.white24, blurRadius: 8, spreadRadius: 1)],
              border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.6),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white, size: 30),
              onPressed: () {}, // already on create page
            ),
          ),
          IconButton(icon: const Icon(Icons.person_outline, color: Colors.white70), onPressed: () => Navigator.pushNamed(context, '/profile')),
          IconButton(icon: const Icon(Icons.more_horiz, color: Colors.white70), onPressed: () {}),
        ]),
      ),
    );
  }

  Widget _glassBox({required Widget child, Color bgColor = Colors.white24, Color borderColor = Colors.white24}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor, width: 1.0)), child: child)),
    );
  }

  Widget _glassTextField({required TextEditingController controller, required String hint, required IconData icon, int maxLength = 100, int maxLines = 1}) {
    return _glassBox(
      child: TextField(controller: controller, maxLength: maxLength, maxLines: maxLines, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)), prefixIcon: Icon(icon, color: Colors.white70), border: InputBorder.none, counterText: '')),
      bgColor: const Color.fromARGB(255, 72, 13, 159).withOpacity(0.12),
      borderColor: Colors.white.withOpacity(0.2),
    );
  }
}

class AnimatedShimmerText extends StatefulWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;

  const AnimatedShimmerText({Key? key, required this.text, this.fontSize = 20, this.fontWeight = FontWeight.bold, this.letterSpacing = 1.0}) : super(key: key);

  @override
  State<AnimatedShimmerText> createState() => _AnimatedShimmerTextState();
}

class _AnimatedShimmerTextState extends State<AnimatedShimmerText> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _controller, builder: (context, child) {
      return ShaderMask(
        shaderCallback: (rect) {
          return LinearGradient(
            begin: Alignment(-1.0 + _controller.value * 2, 0),
            end: Alignment(1.0 + _controller.value * 2, 0),
            colors: [const Color.fromARGB(255, 246, 241, 241), Colors.blue.shade100, Colors.white],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(rect);
        },
        child: Text(widget.text, style: TextStyle(fontSize: widget.fontSize, fontWeight: widget.fontWeight, color: Colors.white, letterSpacing: widget.letterSpacing)),
      );
    });
  }
}
