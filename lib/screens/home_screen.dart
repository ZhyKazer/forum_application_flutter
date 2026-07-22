import 'package:flutter/material.dart';
import 'package:forum_application_flutter/utils/grid_background.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<_PlaceholderPost> _placeholderPosts = [
    _PlaceholderPost(
      author: 'neon_kazer',
      title: 'Welcome to the grid',
      content:
          'This is a placeholder post. Your fetched Supabase posts will appear here later.',
      imageCount: 1,
    ),
    _PlaceholderPost(
      author: 'pixel_runner',
      title: 'Late-night build session',
      content:
          'Working on the next feature under green terminal lights. The interface is starting to come alive.',
      imageCount: 0,
    ),
    _PlaceholderPost(
      author: 'cyber_ghost',
      title: 'Interface concept',
      content:
          'A clean feed card should keep the author, title, content, image, and actions easy to scan.',
      imageCount: 2,
    ),
    _PlaceholderPost(
      author: 'neon_kazer',
      title: 'Welcome to the grid',
      content:
          'This is a placeholder post. Your fetched Supabase posts will appear here later.',
      imageCount: 1,
    ),
    _PlaceholderPost(
      author: 'pixel_runner',
      title: 'Late-night build session',
      content:
          'Working on the next feature under green terminal lights. The interface is starting to come alive.',
      imageCount: 0,
    ),
    _PlaceholderPost(
      author: 'cyber_ghost',
      title: 'Interface concept',
      content:
          'A clean feed card should keep the author, title, content, image, and actions easy to scan.',
      imageCount: 2,
    ),
    _PlaceholderPost(
      author: 'neon_kazer',
      title: 'Welcome to the grid',
      content:
          'This is a placeholder post. Your fetched Supabase posts will appear here later.',
      imageCount: 1,
    ),
    _PlaceholderPost(
      author: 'pixel_runner',
      title: 'Late-night build session',
      content:
          'Working on the next feature under green terminal lights. The interface is starting to come alive.',
      imageCount: 0,
    ),
    _PlaceholderPost(
      author: 'cyber_ghost',
      title: 'Interface concept',
      content:
          'A clean feed card should keep the author, title, content, image, and actions easy to scan.',
      imageCount: 2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: GridBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            const sidePanelWidth = 220.0;
            const gap = 10.0;
            final availableFeedWidth =
                constraints.maxWidth - (sidePanelWidth * 2) - (gap * 2);
            final feedWidth = availableFeedWidth.clamp(320.0, 900.0).toDouble();

            return Center(
              child: SizedBox(
                width: (sidePanelWidth * 2) + (gap * 2) + feedWidth,
                height: constraints.maxHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: _buildProfile(context),
                    ),
                    const SizedBox(width: gap),
                    SizedBox(
                      width: feedWidth,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: _buildPostScrollable(context),
                      ),
                    ),
                    const SizedBox(width: gap),
                    SizedBox(
                      width: sidePanelWidth,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: _buildSearchProfile(context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfile(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: SizedBox(
        width: 220,
        child: Material(
          color: colors.surface,
          shape: BeveledRectangleBorder(
            side: BorderSide(color: colors.outline),
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(36),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PROFILE',
                  style: GoogleFonts.jetBrainsMono(
                    color: colors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 18),
                CircleAvatar(
                  radius: 34,
                  backgroundColor: colors.primaryContainer,
                  foregroundColor: colors.onPrimaryContainer,
                  child: const Icon(Icons.person, size: 38),
                ),
                const SizedBox(height: 12),
                Text(
                  '@neon_kazer',
                  style: GoogleFonts.jetBrainsMono(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: colors.primary, size: 10),
                    const SizedBox(width: 6),
                    Text(
                      'ONLINE',
                      style: GoogleFonts.jetBrainsMono(
                        color: colors.onSurfaceVariant,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: Text(
                    'EDIT',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  style: ButtonStyle(
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    side: WidgetStatePropertyAll(
                      BorderSide(color: colors.primary),
                    ),
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      return states.contains(WidgetState.hovered)
                          ? colors.primary
                          : colors.surface;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      return states.contains(WidgetState.hovered)
                          ? colors.onPrimary
                          : colors.primary;
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
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
            Text(
              'POST FEED',
              style: GoogleFonts.jetBrainsMono(
                color: colors.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _placeholderPosts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildPostContainer(context, _placeholderPosts[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostContainer(BuildContext context, _PlaceholderPost post) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      shape: BeveledRectangleBorder(
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(10)),
        side: BorderSide(color: colors.outline),
      ),

      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colors.primaryContainer,
                  foregroundColor: colors.onPrimaryContainer,
                  child: Text(post.author.substring(0, 1).toUpperCase()),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '@${post.author}',
                    style: GoogleFonts.jetBrainsMono(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'NOW',
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
            if (post.imageCount > 0) ...[
              const SizedBox(height: 14),
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.image_outlined, color: colors.secondary),
                      const SizedBox(height: 6),
                      Text(
                        '${post.imageCount} image placeholder${post.imageCount > 1 ? 's' : ''}',
                        style: GoogleFonts.jetBrainsMono(
                          color: colors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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

  Widget _buildSearchProfile(BuildContext context){
    return Placeholder();

  }
}

class _PlaceholderPost {
  const _PlaceholderPost({
    required this.author,
    required this.title,
    required this.content,
    required this.imageCount,
  });

  final String author;
  final String title;
  final String content;
  final int imageCount;
}




