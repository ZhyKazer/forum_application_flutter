import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:forum_application_flutter/utils/grid_background.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      body: GridBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Material(
              shape: BeveledRectangleBorder(
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(60),
                ),
                side: BorderSide(color: colors.outline),
              ),
              color: colors.surface,
              child: SizedBox(
                width: 600,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'USERNAME: ',
                            style: GoogleFonts.jetBrainsMono(
                              color: colors.onSurface,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'test name',
                            style: GoogleFonts.jetBrainsMono(
                              color: colors.onSurface,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Text(
                            'EMAIL',
                            style: GoogleFonts.jetBrainsMono(
                              color: colors.onSurface,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Test@email.com',
                            style: GoogleFonts.jetBrainsMono(
                              color: colors.onSurface,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {},
                            child: Text(
                              "Don't have an Account?",
                              style: GoogleFonts.jetBrainsMono(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w200,
                                fontSize: 10,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
