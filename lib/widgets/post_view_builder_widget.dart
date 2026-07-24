import 'package:flutter/material.dart';
import 'package:forum_application_flutter/models/comment_models.dart';
import 'package:forum_application_flutter/models/post_models.dart';
import 'package:forum_application_flutter/services/comment_services.dart';
import 'package:forum_application_flutter/services/storage_services.dart';
import 'package:google_fonts/google_fonts.dart';

class PostViewBuilder extends StatefulWidget {
  const PostViewBuilder({super.key, required this.post});

  final PostModel post;

  @override
  State<PostViewBuilder> createState() => _PostViewBuilderState();
}

class _PostViewBuilderState extends State<PostViewBuilder> {
  final _comments = CommentService();
  final _storage = StorageService();
  final _controller = TextEditingController();
  late Future<List<CommentModel>> _commentsFuture;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _commentsFuture = _comments.getCommentsByPostId(widget.post.postId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _reload() => setState(() => _commentsFuture = _comments.getCommentsByPostId(widget.post.postId));

  Future<void> _submit() async {
    final content = _controller.text.trim();
    if (content.isEmpty || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final comment = await _comments.createComment(postId: widget.post.postId, content: content);
      if (!mounted) return;
      _controller.clear();
      setState(() => _commentsFuture = _commentsFuture.then((comments) => [...comments, comment]));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final post = widget.post;
    final username = post.author?.username ?? 'unknown_user';
    return Dialog(
      backgroundColor: colors.surface,
      insetPadding: const EdgeInsets.all(20),
      shape: BeveledRectangleBorder(
        side: BorderSide(color: colors.primary),
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(14)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 760),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('POST', style: GoogleFonts.jetBrainsMono(color: colors.primary, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const Spacer(),
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close), tooltip: 'Close post'),
            ]),
            const Divider(),
            Row(children: [
              _avatar(username, post.author?.avatarPath, colors),
              const SizedBox(width: 10),
              Expanded(child: Text('@$username', style: GoogleFonts.jetBrainsMono(color: colors.primary, fontWeight: FontWeight.bold))),
              Text(_date(post.createdAt), style: GoogleFonts.jetBrainsMono(color: colors.onSurfaceVariant, fontSize: 10)),
            ]),
            const SizedBox(height: 14),
            Text(post.title, style: GoogleFonts.jetBrainsMono(color: colors.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
            if (post.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(post.content, style: TextStyle(color: colors.onSurface, height: 1.4)),
            ],
            const SizedBox(height: 18),
            Text('COMMENTS', style: GoogleFonts.jetBrainsMono(color: colors.primary, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 8),
            Expanded(child: _buildComments(colors)),
            const Divider(),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: 'Write a comment...',
                  filled: true,
                  fillColor: colors.surfaceContainer,
                  border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: colors.outline)),
                ),
              )),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send_outlined),
                tooltip: 'Post comment',
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _buildComments(ColorScheme colors) => FutureBuilder<List<CommentModel>>(
    future: _commentsFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: colors.primary));
      if (snapshot.hasError) return Center(child: TextButton(onPressed: _reload, child: const Text('RETRY LOADING COMMENTS')));
      final comments = snapshot.data ?? const <CommentModel>[];
      if (comments.isEmpty) return Center(child: Text('No comments yet. Start the conversation.', style: TextStyle(color: colors.onSurfaceVariant)));
      return ListView.separated(
        itemCount: comments.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final comment = comments[index];
          final username = comment.author?.username ?? 'unknown_user';
          return DecoratedBox(
            decoration: BoxDecoration(color: colors.surfaceContainer, border: Border.all(color: colors.outline)),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _avatar(username, comment.author?.avatarPath, colors, size: 32),
                const SizedBox(width: 9),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('@$username', style: GoogleFonts.jetBrainsMono(color: colors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(comment.content),
                ])),
                const SizedBox(width: 8),
                Text(_date(comment.createdAt), style: GoogleFonts.jetBrainsMono(color: colors.onSurfaceVariant, fontSize: 9)),
              ]),
            ),
          );
        },
      );
    },
  );

  Widget _avatar(String username, String? avatarPath, ColorScheme colors, {double size = 40}) {
    final initial = username.substring(0, 1).toUpperCase();
    if (avatarPath == null || avatarPath.isEmpty) {
      return CircleAvatar(radius: size / 2, backgroundColor: colors.primaryContainer, foregroundColor: colors.onPrimaryContainer, child: Text(initial));
    }
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: colors.primaryContainer,
      child: ClipOval(child: Image.network(
        _storage.getAvatarUrl(avatarPath), width: size, height: size, fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Center(child: Text(initial)),
      )),
    );
  }

  String _date(DateTime dateTime) {
    final date = dateTime.toLocal();
    return '${date.month}/${date.day}/${date.year}';
  }
}