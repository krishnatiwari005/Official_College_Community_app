// home_screen.dart
import 'dart:ui';
import 'package:community_app/models/search_posts_modal.dart';
import 'package:community_app/providers/posts_provider.dart';
import 'package:community_app/screens/chatbot.dart';
import 'package:community_app/services/comment_service.dart';
import 'package:community_app/services/like_service.dart';
import 'package:community_app/services/dislike_service.dart';
import 'package:community_app/services/post_service.dart';
import 'package:community_app/widgets/search_users_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsProvider);

    return Scaffold(
  body: NestedScrollView(
    floatHeaderSlivers: true,
    headerSliverBuilder: (context, innerBoxIsScrolled) => [
      SliverOverlapAbsorber(
        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        sliver: SliverAppBar(
          pinned: false,
          floating: true,
          snap: true,
          elevation: 0,
          toolbarHeight: 75,
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(166, 18, 4, 143),
                  Color.fromARGB(166, 63, 11, 126),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.white, Color(0xFFE3F2FD)],
                ).createShader(bounds),
                child: const Text(
                  'CollabSpace',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                    letterSpacing: 1.5,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(1, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Image.asset(
                "assets/images/logo.png",
                height: 40,
                width: 40,
                fit: BoxFit.contain,
              ),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz, color: Colors.white, size: 28),
              onSelected: (value) {
                if (value == 'search_users') _showSearchUsersModal(context);
                else if (value == 'search_posts') _showSearchPostsModal(context);
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'search_users',
                  child: Row(
                    children: [
                      Icon(Icons.person_search, color: Colors.grey[700]),
                      const SizedBox(width: 12),
                      const Text('Search Users'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'search_posts',
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey[700]),
                      const SizedBox(width: 12),
                      const Text('Search Posts'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
    body: Builder(
      builder: (context) {
        final ScrollController innerController = PrimaryScrollController.of(context)!;
        return SafeArea(
          top: false,
          child: Stack(
            children: [
              Container(
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
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(color: Colors.white.withOpacity(0.03)),
              ),
              RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(postsProvider);
                  await Future.delayed(const Duration(milliseconds: 800));
                },
                child: CustomScrollView(
                  controller: innerController,
                  slivers: [
                    SliverOverlapInjector(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                    ),
                    SliverToBoxAdapter(
                      child: postsAsync.when(
                        data: (posts) {
                          if (posts.isEmpty) {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.7,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.post_add, size: 64, color: Colors.grey[400]),
                                    const SizedBox(height: 20),
                                    Text(
                                      'No posts yet',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[400],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: posts.length,
                            itemBuilder: (context, index) => PostCard(
                              post: posts[index],
                              onPostDeleted: () => ref.refresh(postsProvider),
                            ),
                          );
                        },
                        loading: () => const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (err, _) => SizedBox(
                          height: 200,
                          child: Center(child: Text("Error: $err")),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                ),
              ),
              const MovableChatBotButton(),
            ],
          ),
        );
      },
    ),
  ),
);


  }

  void _showSearchUsersModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const SearchUsersModal(),
    );
  }

  void _showSearchPostsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const SearchPostsModal(),
    );
  }
}

/* ---------------------------
   Helper widgets & post card
   --------------------------- */

class _BoldRefreshIcon extends StatefulWidget {
  const _BoldRefreshIcon({Key? key}) : super(key: key);

  @override
  State<_BoldRefreshIcon> createState() => _BoldRefreshIconState();
}

class _BoldRefreshIconState extends State<_BoldRefreshIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color.fromARGB(255, 37, 73, 115), Color(0xFF42A5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(2, 3))],
        ),
        child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 34),
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final dynamic post;
  final VoidCallback onPostDeleted;

  const PostCard({Key? key, required this.post, required this.onPostDeleted}) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  final TextEditingController _commentController = TextEditingController();
  bool _isCommenting = false;
  List<dynamic> comments = [];
  int totalComments = 0;
  bool showComments = false;
  bool loadingComments = false;
  int currentPage = 1;
  int totalPages = 1;

  bool _isLiked = false;
  int _likeCount = 0;
  bool _isLiking = false;

  bool _isDisliked = false;
  int _dislikeCount = 0;
  bool _isDisliking = false;

  bool _isDeleting = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    debugPrint('\n🆕 PostCard initState - Post ID: ${widget.post['_id']}');
    _getCurrentUserId();
    _initializePost();
  }

  void _getCurrentUserId() {
    try {
      final token = PostService.authToken;
      debugPrint('🔐 Token: ${token != null ? "exists" : "null"}');

      if (token == null) {
        _currentUserId = null;
        return;
      }

      try {
        Map<String, dynamic> decoded = JwtDecoder.decode(token);
        _currentUserId = decoded['userId'] ?? decoded['id'] ?? decoded['_id'];
        debugPrint('👤 CURRENT USER ID SET: $_currentUserId');

        if (mounted) setState(() {});
      } catch (e) {
        debugPrint('❌ Could not decode token: $e');
        _currentUserId = null;
      }
    } catch (e) {
      debugPrint('❌ Error getting user ID: $e');
      _currentUserId = null;
    }
  }

  String _getInitial(String? name) {
    if (name == null || name.isEmpty) return 'A';
    return name[0].toUpperCase();
  }

  String _extractPostUserId() {
    try {
      if (widget.post is Map) {
        String? userId = widget.post['userId'] ??
            widget.post['authorId'] ??
            (widget.post['author'] is Map ? widget.post['author']['_id'] : null) ??
            (widget.post['author'] is Map ? widget.post['author']['userId'] : null) ??
            (widget.post['author'] is Map ? widget.post['author']['id'] : null) ??
            '';
        return userId.toString().isEmpty ? '' : userId.toString();
      }
    } catch (e) {
      debugPrint('❌ Error extracting userId: $e');
    }
    return '';
  }

  void _initializePost() async {
    try {
      debugPrint('🔍 Initializing post: ${widget.post['_id']}');
      debugPrint('📊 Post keys: ${widget.post.keys.toList()}');

      final likes = widget.post['likes'];
      debugPrint('❤️ Likes data: $likes (type: ${likes.runtimeType})');

      if (likes is int) {
        _likeCount = likes;
        _isLiked = false;
      } else if (likes is List) {
        _likeCount = likes.length;
        if (_currentUserId != null && _currentUserId!.isNotEmpty) {
          _isLiked = likes.any((like) {
            if (like is String) return like == _currentUserId;
            if (like is Map) return (like['_id'] ?? like['userId'] ?? like['id']) == _currentUserId;
            return false;
          });
        }
      } else {
        _likeCount = 0;
        _isLiked = false;
      }

      final dislikes = widget.post['dislikes'];
      debugPrint('👎 Dislikes data: $dislikes (type: ${dislikes.runtimeType})');

      if (dislikes is int) {
        _dislikeCount = dislikes;
        _isDisliked = false;
      } else if (dislikes is List) {
        _dislikeCount = dislikes.length;
        if (_currentUserId != null && _currentUserId!.isNotEmpty) {
          _isDisliked = dislikes.any((dislike) {
            if (dislike is String) return dislike == _currentUserId;
            if (dislike is Map) return (dislike['_id'] ?? dislike['userId'] ?? dislike['id']) == _currentUserId;
            return false;
          });
        }
      } else {
        _dislikeCount = 0;
        _isDisliked = false;
      }

      if (widget.post['mediaType'] == 'video' && widget.post['mediaUrl'] != null) {
        await _initializeVideo();
      }

      final commentsData = widget.post['comments'];
      if (commentsData is List) {
        totalComments = commentsData.length;
      } else if (widget.post['totalComments'] != null) {
        totalComments = widget.post['totalComments'] is int ? widget.post['totalComments'] : 0;
      }

      if (totalComments == 0) {
        try {
          final result = await PostService.getComments(postId: widget.post['_id'], page: 1, limit: 1);
          if (mounted && result['success']) {
            setState(() {
              totalComments = result['totalComments'] ?? 0;
            });
          }
        } catch (e) {
          debugPrint('⚠️ Could not fetch comment count: $e');
        }
      }
    } catch (e) {
      debugPrint('❌ Error initializing post: $e');
      _likeCount = 0;
      _dislikeCount = 0;
      _isLiked = false;
      _isDisliked = false;
      totalComments = 0;
    }
    if (mounted) setState(() {});
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.network(widget.post['mediaUrl']);
      await _videoController!.initialize();
      if (mounted) setState(() => _isVideoInitialized = true);
    } catch (e) {
      debugPrint('❌ Video init error: $e');
    }
  }

  Future<void> loadComments() async {
    if (loadingComments) return;
    setState(() {
      loadingComments = true;
    });

    try {
      final result = await PostService.getComments(postId: widget.post['_id'], page: currentPage, limit: 10);
      if (mounted) {
        setState(() {
          if (result['success']) {
            totalComments = result['totalComments'] ?? 0;
            comments = result['comments'] ?? [];
            totalPages = result['totalPages'] ?? 1;
          }
          loadingComments = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading comments: $e');
      if (mounted) {
        setState(() {
          loadingComments = false;
        });
      }
    }
  }

  Future<void> addComment(TextEditingController controller) async {
    if (controller.text.trim().isEmpty) return;
    if (_isCommenting) return;

    setState(() {
      _isCommenting = true;
    });

    try {
      final result = await PostService.addComment(postId: widget.post['_id'], content: controller.text.trim());
      if (result['success']) {
        controller.clear();
        await loadComments();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comment added!'), backgroundColor: Colors.green, duration: Duration(seconds: 1)));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Failed to add comment'), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      debugPrint('❌ Error adding comment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCommenting = false;
        });
      }
    }
  }

  Future<void> _toggleLike() async {
    if (_isLiking || _isDisliking) return;
    setState(() => _isLiking = true);
    try {
      if (_isDisliked) {
        await DislikeService.dislikePost(widget.post['_id']);
        if (mounted) setState(() {
          _isDisliked = false;
          _dislikeCount = _dislikeCount > 0 ? _dislikeCount - 1 : 0;
        });
      }

      final result = _isLiked ? await LikeService.unlikePost(widget.post['_id']) : await LikeService.likePost(widget.post['_id']);
      if (result['success'] && mounted) {
        setState(() {
          _isLiked = !_isLiked;
          if (result['likes'] is int) _likeCount = result['likes'];
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isLiked ? '❤️ Liked!' : '👍 Removed'), backgroundColor: Colors.blue, duration: const Duration(seconds: 1)));
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
    }
    if (mounted) setState(() => _isLiking = false);
  }

  Future<void> _toggleDislike() async {
    if (_isDisliking || _isLiking) return;
    setState(() => _isDisliking = true);
    try {
      if (_isLiked) {
        await LikeService.unlikePost(widget.post['_id']);
        if (mounted) setState(() {
          _isLiked = false;
          _likeCount = _likeCount > 0 ? _likeCount - 1 : 0;
        });
      }

      final result = await DislikeService.dislikePost(widget.post['_id']);
      if (result['success'] && mounted) {
        setState(() {
          _isDisliked = !_isDisliked;
          if (result['dislikes'] is int)
            _dislikeCount = result['dislikes'];
          else
            _dislikeCount = _isDisliked ? _dislikeCount + 1 : (_dislikeCount > 0 ? _dislikeCount - 1 : 0);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isDisliked ? '👎 Disliked!' : '✅ Removed'), backgroundColor: Colors.orange, duration: const Duration(seconds: 1)));
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
    }
    if (mounted) setState(() => _isDisliking = false);
  }

  Future<void> _deletePost() async {
    final postUserId = _extractPostUserId();
    if (postUserId.isEmpty || postUserId != _currentUserId) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ You can only delete your own posts'), backgroundColor: Colors.red, duration: Duration(seconds: 2)));
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF162447),
        title: const Text('Delete Post?', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this post? This action cannot be undone.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      final postId = widget.post['_id'];
      final result = await PostService.deletePost(postId);
      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Post deleted successfully'), backgroundColor: Colors.green, duration: Duration(seconds: 2)));
          widget.onPostDeleted();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ ${result['message']}'), backgroundColor: Colors.red, duration: const Duration(seconds: 2)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red, duration: const Duration(seconds: 2)));
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Widget _buildMediaWidget() {
    final mediaUrl = widget.post['mediaUrl'];
    final mediaType = widget.post['mediaType'];

    if (mediaUrl == null || mediaUrl.toString().isEmpty) return const SizedBox.shrink();

    if (mediaType == 'video') {
      if (_isVideoInitialized && _videoController != null) {
        return AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_videoController!),
              IconButton(
                icon: Icon(_videoController!.value.isPlaying ? Icons.pause_circle_outline : Icons.play_circle_outline, size: 64, color: Colors.white.withOpacity(0.9)),
                onPressed: () {
                  setState(() {
                    _videoController!.value.isPlaying ? _videoController!.pause() : _videoController!.play();
                  });
                },
              ),
            ],
          ),
        );
      } else {
        return Container(
          height: 250,
          color: const Color.fromARGB(255, 38, 39, 40),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.video_library, size: 50, color: Colors.grey[600]),
                const SizedBox(height: 8),
                Text('Video unavailable', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        );
      }
    } else {
      return Image.network(
        mediaUrl,
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ Image load error: $error');
          return Container(
            height: 250,
            color: const Color.fromARGB(255, 38, 39, 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
                const SizedBox(height: 8),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('Image unavailable', style: TextStyle(color: const Color.fromARGB(255, 125, 130, 136), fontSize: 12), textAlign: TextAlign.center)),
              ],
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      final userName = widget.post['authorName'] ?? widget.post['author'] ?? 'Anonymous User';
      final postUserId = _extractPostUserId();
      final isOwner = (_currentUserId != null && _currentUserId!.isNotEmpty && postUserId.isNotEmpty && postUserId == _currentUserId);

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, spreadRadius: 2)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(_getInitial(userName), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(userName.isNotEmpty ? userName : 'Anonymous User', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(_formatTimestamp(widget.post['createdAt']), style: TextStyle(color: const Color.fromARGB(255, 238, 235, 235), fontSize: 12)),
                        ]),
                      ),
                      if (isOwner)
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'delete') _deletePost();
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(children: [Icon(Icons.delete, color: Colors.red[400], size: 20), const SizedBox(width: 12), const Text('Delete', style: TextStyle(color: Colors.black))]),
                            ),
                          ],
                          child: Icon(Icons.more_vert, color: _isDeleting ? Colors.grey : Colors.white, size: 20),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                ),

                // Media
                if (widget.post['mediaUrl'] != null && widget.post['mediaUrl'].toString().isNotEmpty) _buildMediaWidget(),

                // Buttons row (like, comment, dislike)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: (_isLiking || _isDisliking) ? null : _toggleLike,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(_isLiked ? Icons.favorite : Icons.favorite_border, color: _isLiked ? const Color.fromARGB(255, 190, 31, 19) : const Color.fromARGB(255, 232, 212, 212), size: 22),
                              const SizedBox(width: 8),
                              Text(_likeCount.toString(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _isLiked ? Colors.red : const Color.fromARGB(255, 232, 212, 212))),
                            ]),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => showComments = !showComments);
                            if (showComments && comments.isEmpty) loadComments();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(showComments ? Icons.comment : Icons.comment_outlined, color: const Color.fromARGB(255, 232, 212, 212), size: 22),
                              const SizedBox(width: 8),
                              Text('$totalComments', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color.fromARGB(255, 232, 212, 212))),
                            ]),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: (_isDisliking || _isLiking) ? null : _toggleDislike,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(_isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined, color: _isDisliked ? Colors.orange : const Color.fromARGB(255, 232, 212, 212), size: 22),
                              const SizedBox(width: 8),
                              Text(_dislikeCount.toString(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _isDisliked ? Colors.orange : const Color.fromARGB(255, 232, 212, 212))),
                            ]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Title + description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(widget.post['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(widget.post['description'] ?? '', style: const TextStyle(fontSize: 14, color: Colors.white70)),
                    const SizedBox(height: 12),
                  ]),
                ),

                // Comments section (collapsible)
                if (showComments) ...[
                  const Divider(height: 1, color: Colors.white24),
                  if (loadingComments)
                    Padding(padding: const EdgeInsets.all(16), child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))))
                  else if (comments.isNotEmpty)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 250),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: comments.length,
                        itemBuilder: (_, index) {
                          final comment = comments[index];
                          final userName = comment['user'] != null ? (comment['user']['name'] ?? 'Anonymous') : 'Anonymous';
                          final commentText = comment['text'] ?? '';
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  CircleAvatar(radius: 16, backgroundColor: Colors.blue, child: Text(userName[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                                      const SizedBox(height: 2),
                                      Text(commentText, style: const TextStyle(fontSize: 13, color: Colors.white70)),
                                    ]),
                                  ),
                                ]),
                                const Divider(height: 12, color: Colors.white24),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  else if (!loadingComments)
                    Padding(padding: const EdgeInsets.all(16), child: Text('No comments yet. Be the first to comment!', style: TextStyle(color: Colors.grey[400], fontSize: 13), textAlign: TextAlign.center)),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: 'Comment...',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.03),
                            ),
                            enabled: !_isCommenting,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _isCommenting
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                            : IconButton(
                                icon: const Icon(Icons.send, color: Colors.blue),
                                onPressed: _isCommenting ? null : () async {
                                  if (_commentController.text.trim().isEmpty) return;
                                  await addComment(_commentController);
                                },
                              ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      return Container(margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(16), color: Colors.white, child: Center(child: Text('Error: $e')));
    }
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return '';
    try {
      final date = DateTime.parse(timestamp);
      final diff = DateTime.now().difference(date);
      if (diff.inDays > 0) return '${diff.inDays}d ago';
      if (diff.inHours > 0) return '${diff.inHours}h ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
      return 'Just now';
    } catch (_) {
      return '';
    }
  }
}

/* ---------------------------
   Movable ChatBot Button
   - glassmorphic + floating glow
   - opens ChatBotPage as Dialog (glass popup)
   --------------------------- */

class MovableChatBotButton extends StatefulWidget {
  const MovableChatBotButton({Key? key}) : super(key: key);

  @override
  State<MovableChatBotButton> createState() => _MovableChatBotButtonState();
}

class _MovableChatBotButtonState extends State<MovableChatBotButton> with SingleTickerProviderStateMixin {
  double x = 20;
  double y = 500;
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0, end: 8).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const double buttonSize = 62;

    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Positioned(
          left: x,
          top: (y + _floatAnimation.value).clamp(0.0, screenSize.height - buttonSize - 20),
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                x = (x + details.delta.dx).clamp(0.0, screenSize.width - buttonSize);
                y = (y + details.delta.dy).clamp(0.0, screenSize.height - buttonSize - 80);
              });
            },
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: true,
                barrierColor: Colors.black.withOpacity(0.35),
                builder: (context) => const Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: EdgeInsets.all(12),
                  child: ChatBotPage(),
                ),
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow
                Container(
                  width: buttonSize + 14,
                  height: buttonSize + 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.purpleAccent.withOpacity(0.6), blurRadius: 18, spreadRadius: 4),
                      BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 22, spreadRadius: 6),
                    ],
                  ),
                ),

                // Glass button
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      width: buttonSize,
                      height: buttonSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.purple.withOpacity(0.28), Colors.blue.withOpacity(0.20)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: Colors.white.withOpacity(0.32), width: 1.6),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(4, 4))],
                      ),
                      child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
