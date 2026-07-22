import 'package:flutter/material.dart';
import 'package:forum_application_flutter/services/authentication_services.dart';
import 'package:forum_application_flutter/utils/grid_background.dart';
import 'package:forum_application_flutter/widgets/post_builder_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> logout() async {
    await AuthenticationService().logout();
  }

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
                    SizedBox(width: feedWidth, child: const PostBuilder()),
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
                  label: Text(
                    'PROFILE',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  style: ButtonStyle(
                    minimumSize: WidgetStateProperty.all(const Size(110, 40)),
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
                SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () async {
                    await logout();
                  },
                  label: Text(
                    'LOGOUT',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  style: ButtonStyle(
                    minimumSize: WidgetStateProperty.all(const Size(110, 40)),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    side: WidgetStatePropertyAll(
                      BorderSide(color: colors.error),
                    ),
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      return states.contains(WidgetState.hovered)
                          ? colors.error
                          : colors.surface;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      return states.contains(WidgetState.hovered)
                          ? colors.onPrimary
                          : colors.error;
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

  Widget _buildSearchProfile(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Material(
        color: colors.surface,
        shape: BeveledRectangleBorder(
          side: BorderSide(color: colors.outline),
          borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(36),
          ),
        ),
        child: SizedBox(
          height: 500,
          width: 500,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DISCOVER',
                  style: GoogleFonts.jetBrainsMono(
                    color: colors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  cursorColor: colors.primary,
                  style: GoogleFonts.jetBrainsMono(color: colors.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Search users',
                    hintStyle: GoogleFonts.jetBrainsMono(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                    prefixIcon: Icon(Icons.search, color: colors.primary),
                    filled: true,
                    fillColor: colors.surfaceContainer,
                    isDense: true,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colors.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colors.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'SUGGESTED USERS',
                  style: GoogleFonts.jetBrainsMono(
                    color: colors.onSurfaceVariant,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10),
                _buildSuggestedProfile(context, 'pixel_runner', '12 posts'),
                const SizedBox(height: 10),
                _buildSuggestedProfile(context, 'cyber_ghost', '8 posts'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestedProfile(
    BuildContext context,
    String username,
    String postCount,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: colors.secondaryContainer,
          foregroundColor: colors.onSecondaryContainer,
          child: Text(username.substring(0, 1).toUpperCase()),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '@$username',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.jetBrainsMono(
                  color: colors.onSurface,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                postCount,
                style: GoogleFonts.jetBrainsMono(
                  color: colors.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.add, color: colors.primary, size: 18),
      ],
    );
  }

  Widget _buildLogoutConfimation(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: colors.surface,
      shape: BeveledRectangleBorder(
        side: BorderSide(color: colors.error),
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(36)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.logout, color: colors.error, size: 32),
              const SizedBox(height: 16),
              Text(
                'LOG OUT?',
                style: GoogleFonts.jetBrainsMono(
                  color: colors.error,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your current session will end on this device.',
                style: TextStyle(color: colors.onSurfaceVariant, height: 1.4),
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
                  FilledButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await logout();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.error,
                      foregroundColor: colors.onError,
                      shape: const BeveledRectangleBorder(),
                    ),
                    child: Text(
                      'LOG OUT',
                      style: GoogleFonts.jetBrainsMono(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
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

}

