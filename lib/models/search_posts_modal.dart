import 'package:flutter/material.dart';
import '../services/search_service.dart';
import '../screens/post_detail_page.dart';

class SearchPostsModal extends StatefulWidget {
  const SearchPostsModal({Key? key}) : super(key: key);

  @override
  State<SearchPostsModal> createState() => _SearchPostsModalState();
}

class _SearchPostsModalState extends State<SearchPostsModal> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchPosts(String query) async {
    if (query.isEmpty) {
      setState(() {
        _posts = [];
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await SearchService.searchPosts(query);

      if (mounted) {
        setState(() {
          _posts = result['posts'] ?? [];
          _isLoading = false;
          if (!result['success']) {
            _errorMessage = result['message'];
          }
          
          // Debug: Print first post structure
          if (_posts.isNotEmpty) {
            print('🔍 First post structure: ${_posts[0]}');
            if (_posts[0] is Map) {
              print('🔍 Available keys: ${(_posts[0] as Map).keys.toList()}');
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Service is starting up. Please wait and try again.';
        });
      }
    }
  }

  String _extractPostId(Map<String, dynamic> post) {
    // Try multiple possible ID field names
    final possibleIds = [
      'post_id',
    ];
    
    for (final idField in possibleIds) {
      if (post[idField] != null && post[idField].toString().isNotEmpty) {
        return post[idField].toString();
      }
    }
    
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          const Text(
            'Search Posts',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Search field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by title...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: _searchPosts,
          ),
          const SizedBox(height: 16),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Searching... This may take a moment'),
                      ],
                    ),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.orange,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () =>
                                  _searchPosts(_searchController.text),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _posts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.article_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchController.text.isEmpty
                                      ? 'Start typing to search posts'
                                      : 'No posts found',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _posts.length,
                            itemBuilder: (context, index) {
                              final post = _posts[index];
                              final title = post['title'] ?? 'Untitled';
                              final description = post['description'] ?? '';
                              final authorName =
                                  post['author']?['name'] ?? 'Unknown';
                              final imageUrl = post['imageUrl'] ?? '';

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                elevation: 2,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  leading: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: imageUrl.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Icon(
                                                Icons.article,
                                                color: Colors.blue.shade700,
                                                size: 30,
                                              ),
                                            ),
                                          )
                                        : Icon(
                                            Icons.article,
                                            color: Colors.blue.shade700,
                                            size: 30,
                                          ),
                                  ),
                                  title: Text(
                                    title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (description.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.person,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            authorName,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                  ),
                                  onTap: () {
                                    final postId = _extractPostId(post);

                                    print('🎯 Post tapped!');
                                    print('   Post ID: $postId');
                                    print('   Post keys: ${post.keys}');
                                    print('   Full post: $post');

                                    if (postId.isEmpty) {
                                      print('❌ Post ID is empty!');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Post ID not found. Available fields: ${post.keys.join(", ")}'),
                                          duration: const Duration(seconds: 3),
                                        ),
                                      );
                                      return;
                                    }

                                    print('✅ Navigating to post detail page...');

                                    try {
                                      Navigator.pop(context); // Close modal
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PostDetailPage(postId: postId),
                                        ),
                                      ).then((value) {
                                        print(
                                            '✅ Returned from post detail page');
                                      });
                                    } catch (e) {
                                      print('❌ Navigation error: $e');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
