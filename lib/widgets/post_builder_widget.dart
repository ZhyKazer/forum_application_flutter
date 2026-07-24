import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:forum_application_flutter/models/post_images_models.dart';
import 'package:forum_application_flutter/models/post_models.dart';
import 'package:forum_application_flutter/services/post_services.dart';
import 'package:forum_application_flutter/services/storage_services.dart';
import 'package:forum_application_flutter/widgets/post_view_builder_widget.dart';
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
  final StorageService _storageService = StorageService();
  final List<PostModel> _posts = [];
  final TextEditingController _postTitleController = TextEditingController();
  final TextEditingController _postDescriptionController =
      TextEditingController();
  final ScrollController _imagePreviewScrollController = ScrollController();
  final List<XFile> _selectedImages = [];
  final Map<String, Future<Uint8List>> _selectedImageBytes = {};
  final Map<String, Future<List<String>>> _postImageUrlSets = {};

  bool _isInitialLoading = false;
  bool _isPublishingPost = false;
  bool _isLoadingMore = false;
  bool _hasMorePosts = true;
  bool _isDraggingImages = false;
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
    _imagePreviewScrollController.dispose();
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

  Future<void> _pickImages([StateSetter? dialogSetState]) async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );

    if (!mounted || result == null) return;
    _addImages(
      result.files
          .where((file) => file.bytes != null)
          .map(
            (file) => XFile.fromData(
              file.bytes!,
              name: file.name,
              path: file.name,
            ),
          ),
      dialogSetState,
    );
  }

  void _addImages(Iterable<XFile> images, [StateSetter? dialogSetState]) {
    final selectedPaths = _selectedImages.map((image) => image.name).toSet();
    final newImages = images
        .where((image) => _isSupportedImage(image.name))
        .where((image) => selectedPaths.add(image.name))
        .toList();

    if (newImages.isEmpty) return;
    setState(() {
      _selectedImages.addAll(newImages);
      for (final image in newImages) {
        _selectedImageBytes[image.name] = image.readAsBytes();
      }
    });
    dialogSetState?.call(() {});
  }

  bool _isSupportedImage(String path) {
    const imageExtensions = {'jpg', 'jpeg', 'png'};
    final extension = path.split('.').last.toLowerCase();
    return imageExtensions.contains(extension);
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
        images: List<XFile>.of(_selectedImages),
      );

      if (!mounted) return;
      setState(() {
        _posts.insert(0, createdPost);
        _postTitleController.clear();
        _postDescriptionController.clear();
        _selectedImages.clear();
        _selectedImageBytes.clear();
      });
      if (!dialogContext.mounted) return;
      Navigator.of(dialogContext).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Post published.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
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
                _buildPostAuthorAvatar(
                  username: username,
                  avatarPath: post.author?.avatarPath,
                  colors: colors,
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
            if (post.images.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildPostImages(context, post.images),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.favorite_border, color: colors.onSurfaceVariant),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => PostViewBuilder(post: post),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline),
                  color: colors.onSurfaceVariant,
                  tooltip: 'View comments',
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 16),
                Icon(Icons.share_outlined, color: colors.onSurfaceVariant),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostAuthorAvatar({
    required String username,
    required String? avatarPath,
    required ColorScheme colors,
  }) {
    final initial = username.substring(0, 1).toUpperCase();
    if (avatarPath == null || avatarPath.isEmpty) {
      return CircleAvatar(
        backgroundColor: colors.primaryContainer,
        foregroundColor: colors.onPrimaryContainer,
        child: Text(initial),
      );
    }

    return CircleAvatar(
      backgroundColor: colors.primaryContainer,
      child: ClipOval(
        child: Image.network(
          _storageService.getAvatarUrl(avatarPath),
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Center(
            child: Text(
              initial,
              style: TextStyle(color: colors.onPrimaryContainer),
            ),
          ),
        ),
      ),
    );
  }
  Future<List<String>> _getPostImageUrls(List<PostImageModel> images) {
    final key = images.map((image) => image.storagePath).join('|');
    return _postImageUrlSets.putIfAbsent(
      key,
      () => Future.wait(
        images.map((image) => _postService.getPostImageUrl(image.storagePath)),
      ),
    );
  }

  Widget _buildPostImages(
    BuildContext context,
    List<PostImageModel> images,
  ) {
    final colors = Theme.of(context).colorScheme;

    return FutureBuilder<List<String>>(
      future: _getPostImageUrls(images),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _postImageStatus(
            colors,
            const Icon(Icons.broken_image_outlined),
          );
        }
        if (!snapshot.hasData) {
          return _postImageStatus(colors, const CircularProgressIndicator());
        }

        final urls = snapshot.data!;
        if (urls.length == 1) {
          return SizedBox(
            height: 260,
            width: double.infinity,
            child: _postImageTile(urls, 0),
          );
        }

        final rightImageCount = urls.length > 4 ? 3 : urls.length - 1;
        return SizedBox(
          height: 260,
          child: Row(
            children: [
              Expanded(flex: 2, child: _postImageTile(urls, 0)),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  children: List.generate(rightImageCount, (index) {
                    final imageIndex = index + 1;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: index == rightImageCount - 1 ? 0 : 4,
                        ),
                        child: _postImageTile(
                          urls,
                          imageIndex,
                          remainingImageCount:
                              imageIndex == 3 && urls.length > 4
                              ? urls.length - 4
                              : null,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _postImageStatus(ColorScheme colors, Widget child) {
    return SizedBox(
      height: 160,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          border: Border.all(color: colors.outline),
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _postImageTile(
    List<String> urls,
    int index, {
    int? remainingImageCount,
  }) {
    return InkWell(
      onTap: () => _showPostImagePreview(context, urls, index),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(urls[index], fit: BoxFit.cover),
          if (remainingImageCount != null)
            ColoredBox(
              color: Colors.black54,
              child: Center(
                child: Text(
                  '+',
                  style: GoogleFonts.jetBrainsMono(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showPostImagePreview(
    BuildContext context,
    List<String> urls,
    int initialIndex,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => _PostImagePreviewDialog(
        imageUrls: urls,
        initialIndex: initialIndex,
      ),
    );
  }
  String _formatPostDate(DateTime dateTime) {
    final date = dateTime.toLocal();
    return '${date.month}/${date.day}/${date.year}';
  }

  Widget _buildCreatePost(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return StatefulBuilder(
      builder: (context, dialogSetState) => Dialog(
        backgroundColor: colors.surface,
      shape: BeveledRectangleBorder(
        side: BorderSide(color: colors.primary),
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(15)),
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
              DropTarget(
                onDragEntered: (_) {
                  setState(() => _isDraggingImages = true);
                  dialogSetState(() {});
                },
                onDragExited: (_) {
                  setState(() => _isDraggingImages = false);
                  dialogSetState(() {});
                },
                onDragDone: (detail) {
                  setState(() => _isDraggingImages = false);
                  _addImages(detail.files, dialogSetState);
                },
                child: SizedBox(
                  width: double.infinity,
                  height: 120,
                  child: FilledButton.icon(
                    onPressed: () => _pickImages(dialogSetState),
                    icon: Icon(
                      Icons.add_photo_alternate_outlined,
                      color: colors.primary,
                    ),
                    label: Text(
                      _isDraggingImages
                          ? 'DROP IMAGES HERE'
                          : _selectedImages.isEmpty
                          ? 'CLICK OR DRAG IMAGES HERE'
                          : '${_selectedImages.length} IMAGE${_selectedImages.length == 1 ? '' : 'S'} SELECTED',
                      style: GoogleFonts.jetBrainsMono(
                        color: colors.onSurfaceVariant,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: _isDraggingImages
                          ? colors.primaryContainer
                          : colors.surface,
                      foregroundColor: colors.primary,
                      shape: BeveledRectangleBorder(
                        side: BorderSide(color: colors.primary),
                      ),
                    ),
                  ),
                ),
              ),
              if (_selectedImages.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 96,
                  child: Scrollbar(
                    controller: _imagePreviewScrollController,
                    thumbVisibility: true,
                    child: ListView.separated(
                      controller: _imagePreviewScrollController,
                      primary: false,
                      scrollDirection: Axis.horizontal,
                      physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _selectedImages.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final image = _selectedImages[index];
                      return SizedBox(
                        width: 96,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            FutureBuilder<Uint8List>(
                              future: _selectedImageBytes[image.name],
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                  );
                                }
                                return DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: colors.surfaceContainer,
                                    border: Border.all(color: colors.outline),
                                  ),
                                  child: Center(
                                    child: snapshot.hasError
                                        ? Icon(
                                            Icons.broken_image_outlined,
                                            color: colors.error,
                                          )
                                        : CircularProgressIndicator(
                                            color: colors.primary,
                                          ),
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: IconButton.filled(
                                onPressed: () {
                                  setState(() {
                                    _selectedImages.removeAt(index);
                                    _selectedImageBytes.remove(image.name);
                                  });
                                  dialogSetState(() {});
                                },
                                icon: const Icon(Icons.close, size: 16),
                                tooltip: 'Remove image',
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.cancel, size: 16),
                    label: Text(
                      'CANCEL',
                      style: GoogleFonts.jetBrainsMono(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.surface,
                      foregroundColor: colors.primary,
                      shape: BeveledRectangleBorder(
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(0),
                        ),
                        side: BorderSide(color: colors.primary),
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
                      shape: const BeveledRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: colors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
    );
  }
}

class _PostImagePreviewDialog extends StatefulWidget {
  const _PostImagePreviewDialog({
    required this.imageUrls,
    required this.initialIndex,
  });

  final List<String> imageUrls;
  final int initialIndex;

  @override
  State<_PostImagePreviewDialog> createState() =>
      _PostImagePreviewDialogState();
}

class _PostImagePreviewDialogState extends State<_PostImagePreviewDialog> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _moveToImage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980, maxHeight: 720),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: widget.imageUrls.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) => InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: Center(
                    child: Image.network(
                      widget.imageUrls[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: IconButton.filled(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  tooltip: 'Close image preview',
                ),
              ),
              if (_currentIndex > 0)
                Positioned(
                  left: 12,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: IconButton.filled(
                      onPressed: () => _moveToImage(_currentIndex - 1),
                      icon: const Icon(Icons.chevron_left),
                      tooltip: 'Previous image',
                    ),
                  ),
                ),
              if (_currentIndex < widget.imageUrls.length - 1)
                Positioned(
                  right: 12,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: IconButton.filled(
                      onPressed: () => _moveToImage(_currentIndex + 1),
                      icon: const Icon(Icons.chevron_right),
                      tooltip: 'Next image',
                    ),
                  ),
                ),
              Positioned(
                left: 16,
                bottom: 12,
                child: Text(
                  '${_currentIndex + 1} / ${widget.imageUrls.length}',
                  style: GoogleFonts.jetBrainsMono(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
