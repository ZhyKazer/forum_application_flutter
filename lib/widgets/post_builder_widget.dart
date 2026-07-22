import 'package:flutter/material.dart';
import 'package:forum_application_flutter/models/post_models.dart';
import 'package:forum_application_flutter/services/post_services.dart';
import 'package:google_fonts/google_fonts.dart';

class PostBuilder extends StatefulWidget {
  const PostBuilder({super.key});

  @override
  State<PostBuilder> createState() => _PostBuilderState();
}

class _PostBuilderState extends State<PostBuilder> {
  static const _pageSize = 10;
  static const _loadMoreThreshold = 240.0;

  final PostService _postService = PostService();
  final List<PostModel> _posts = [];
  final TextEditingController _postTitleController = TextEditingController();
  final TextEditingController _postDescriptionController =
      TextEditingController();

  bool _isInitialLoading = false;
  bool _isPublishingPost = false;
  bool _isLoadingMore = false;
  bool _hasMorePosts = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadNextPage();
  }

  @override
  void dispose() {
    _postTitleController.dispose();
    _postDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadNextPage() async {
    if (_isInitialLoading || _isLoadingMore || !_hasMorePosts) return;

    final isInitialLoad = _posts.isEmpty;
    setState(() {
      _loadError = null;
      if (isInitialLoad) {
        _isInitialLoading = true;
      } else {
        _isLoadingMore = true;
      }
    });

    try {
      final nextPosts = await _postService.getPosts(
        offset: _posts.length,
        limit: _pageSize,
      );

      if (!mounted) return;
      setState(() {
        _posts.addAll(nextPosts);
        _hasMorePosts = nextPosts.length == _pageSize;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadError = error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  bool _handlePostScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification &&
        notification.metrics.extentAfter < _loadMoreThreshold) {
      _loadNextPage();
    }

    return false;
  }

  Future<void> _createPost(BuildContext dialogContext) async {
    final title = _postTitleController.text.trim();
    final description = _postDescriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A post title is required.')),
      );
      return;
    }

    if (_isPublishingPost) return;
    setState(() => _isPublishingPost = true);

    try {
      final createdPost = await _postService.createPost(
        title: title,
        content: description,
      );

      if (!mounted) return;
      setState(() {
        _posts.insert(0, createdPost);
        _postTitleController.clear();
        _postDescriptionController.clear();
      });
      Navigator.of(dialogContext).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post published.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _isPublishingPost = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handlePostScroll,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: _buildPostScrollable(context),
      ),
    );
  }

  Widget _buildPostScrollable(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      shape: BeveledRectangleBorder(side: BorderSide(color: colors.outline)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'POST FEED',
                    style: GoogleFonts.jetBrainsMono(
                      color: colors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    showDialog(context: context, builder: _buildCreatePost);
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(
                    'POST',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.primary,
                    side: BorderSide(color: colors.primary),
                    shape: const BeveledRectangleBorder(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isInitialLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: colors.primary),
                ),
              )
            else if (_posts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _loadError ?? 'No posts yet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                      if (_loadError != null) ...[
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: _loadNextPage,
                          child: const Text('TRY AGAIN'),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _posts.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildPostContainer(context, _posts[index]);
                },
              ),
              const SizedBox(height: 16),
              if (_isLoadingMore)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: CircularProgressIndicator(color: colors.primary),
                  ),
                )
              else if (_loadError != null)
                Center(
                  child: TextButton(
                    onPressed: _loadNextPage,
                    child: const Text('RETRY LOADING POSTS'),
                  ),
                )
              else if (!_hasMorePosts)
                Center(
                  child: Text(
                    'END OF FEED',
                    style: GoogleFonts.jetBrainsMono(
                      color: colors.onSurfaceVariant,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPostContainer(BuildContext context, PostModel post) {
    final colors = Theme.of(context).colorScheme;
    final username = post.author?.username ?? 'unknown_user';

    return Material(
      color: colors.surfaceContainer,
      shape: BeveledRectangleBorder(
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(10)),
        side: BorderSide(color: colors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colors.primaryContainer,
                  foregroundColor: colors.onPrimaryContainer,
                  child: Text(username.substring(0, 1).toUpperCase()),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '@$username',
                    style: GoogleFonts.jetBrainsMono(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  _formatPostDate(post.createdAt),
                  style: GoogleFonts.jetBrainsMono(
                    color: colors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              post.title,
              style: GoogleFonts.jetBrainsMono(
                color: colors.onSurface,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              post.content,
              style: TextStyle(color: colors.onSurface, height: 1.4),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.favorite_border, color: colors.onSurfaceVariant),
                const SizedBox(width: 16),
                Icon(Icons.chat_bubble_outline, color: colors.onSurfaceVariant),
                const SizedBox(width: 16),
                Icon(Icons.share_outlined, color: colors.onSurfaceVariant),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatPostDate(DateTime dateTime) {
    final date = dateTime.toLocal();
    return '${date.month}/${date.day}/${date.year}';
  }

  Widget _buildCreatePost(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: colors.surface,
      shape: BeveledRectangleBorder(
        side: BorderSide(color: colors.primary),
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(36)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.edit_note, color: colors.primary, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    'CREATE POST',
                    style: GoogleFonts.jetBrainsMono(
                      color: colors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildCreatePostLabel(context, 'TITLE *'),
              const SizedBox(height: 8),
              TextField(
                controller: _postTitleController,
                textCapitalization: TextCapitalization.sentences,
                cursorColor: colors.primary,
                style: GoogleFonts.jetBrainsMono(color: colors.onSurface),
                decoration: _postInputDecoration(
                  colors: colors,
                  hintText: 'Give your post a title',
                ),
              ),
              const SizedBox(height: 18),
              _buildCreatePostLabel(context, 'DESCRIPTION (OPTIONAL)'),
              const SizedBox(height: 8),
              TextField(
                controller: _postDescriptionController,
                minLines: 4,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                cursorColor: colors.primary,
                style: TextStyle(color: colors.onSurface),
                decoration: _postInputDecoration(
                  colors: colors,
                  hintText: 'Share what is on your mind...',
                ),
              ),
              const SizedBox(height: 18),
              _buildCreatePostLabel(context, 'IMAGE (OPTIONAL)'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  border: Border.all(color: colors.outlineVariant),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      color: colors.secondary,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'NO IMAGE SELECTED',
                      style: GoogleFonts.jetBrainsMono(
                        color: colors.onSurfaceVariant,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.upload_outlined, size: 16),
                      label: const Text('CHOOSE IMAGE'),
                      style: TextButton.styleFrom(
                        foregroundColor: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'CANCEL',
                      style: GoogleFonts.jetBrainsMono(
                        color: colors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    onPressed: _isPublishingPost
                        ? null
                        : () => _createPost(context),
                    icon: const Icon(Icons.send_outlined, size: 16),
                    label: Text(
                      'PUBLISH',
                      style: GoogleFonts.jetBrainsMono(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      shape: const BeveledRectangleBorder(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreatePostLabel(BuildContext context, String label) {
    final colors = Theme.of(context).colorScheme;

    return Text(
      label,
      style: GoogleFonts.jetBrainsMono(
        color: colors.onSurface,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
  }

  InputDecoration _postInputDecoration({
    required ColorScheme colors,
    required String hintText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.jetBrainsMono(
        color: colors.onSurfaceVariant,
        fontSize: 12,
      ),
      filled: true,
      fillColor: colors.surfaceContainer,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
    );
  }
}
