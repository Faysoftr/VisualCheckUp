import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/features/admin/data/admin_repository.dart';
import 'package:visualcheckup/features/admin/domain/admin_models.dart';
import 'package:visualcheckup/features/admin/presentation/screens/admin_panel_screen.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/community/data/community_image_upload_service.dart';
import 'package:visualcheckup/features/community/data/health_community_repository.dart';
import 'package:visualcheckup/features/community/presentation/screens/health_chat_screen.dart';
import 'package:visualcheckup/features/community/presentation/screens/health_community_hub_screen.dart';
import 'package:visualcheckup/features/community/presentation/screens/health_profile_detail_screen.dart';
import 'package:visualcheckup/features/community/presentation/widgets/social_profile_view.dart';
import 'package:visualcheckup/features/support/presentation/widgets/donation_support_dialog.dart';

/// Dedicated "My Profile" (Profilim) screen launched directly from the top of
/// [AppDrawer] or the Drawer account header — styled after Social Formula Bank's
/// `{ Profilim }` header with quick Donate, Messages, Community, and Admin
/// Console actions.
class MyHealthProfileScreen extends StatelessWidget {
  const MyHealthProfileScreen({
    super.key,
    required this.currentUser,
    required this.repository,
    this.adminRepository,
    this.uploadService,
    this.photoPicker,
    this.urlLauncher,
    this.onOpenAdminPanel,
  });

  final AuthUser currentUser;
  final HealthCommunityRepository repository;
  final AdminRepository? adminRepository;
  final CommunityImageUploadService? uploadService;
  final CommunityPhotoPicker? photoPicker;
  final CommunityUrlLauncher? urlLauncher;
  final VoidCallback? onOpenAdminPanel;

  void _openCommunity(BuildContext context, {int initialTabIndex = 0}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HealthCommunityHubScreen(
          currentUser: currentUser,
          repository: repository,
          adminRepository: adminRepository,
          uploadService: uploadService,
          photoPicker: photoPicker,
          urlLauncher: urlLauncher,
          initialTabIndex: initialTabIndex,
        ),
      ),
    );
  }

  void _openAdmin(BuildContext context) {
    if (onOpenAdminPanel != null) {
      onOpenAdminPanel!();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AdminPanelScreen(
          repository: adminRepository ?? AdminRepository(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isAdmin = AdminUtils.isAdmin(
      email: currentUser.email,
      uid: currentUser.id,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 6,
        backgroundColor:
            isDark ? const Color(0xFF0C1A1B) : const Color(0xFFE7F5F3),
        surfaceTintColor: Colors.transparent,
        title: Text(
          l10n.commTabMyProfile,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 19,
                letterSpacing: -0.3,
              ),
        ),
        actions: [
          if (!kIsWeb && !Platform.isIOS)
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: l10n.donateTooltip,
              onPressed: () => DonationSupportDialog.show(context),
              icon: const Icon(
                Icons.volunteer_activism_rounded,
                color: Color(0xFFE11D48),
                size: 20,
              ),
            ),
          IconButton(
            key: const Key('my_profile_messages_btn'),
            visualDensity: VisualDensity.compact,
            tooltip: l10n.sfbMyMessages,
            onPressed: () => _openCommunity(context, initialTabIndex: 3),
            icon: const Icon(Icons.mail_outline_rounded, size: 21),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 6),
            child: TextButton.icon(
              key: const Key('my_profile_open_community_btn'),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              onPressed: () => _openCommunity(context, initialTabIndex: 0),
              icon: const Icon(Icons.public_rounded, size: 16),
              label: Text(
                l10n.commOpenCommunityCta,
                maxLines: 1,
                softWrap: false,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SocialProfileView(
        currentUser: currentUser,
        repository: repository,
        uploadService: uploadService,
        photoPicker: photoPicker,
        urlLauncher: urlLauncher,
        onOpenAdminPanel: isAdmin ? () => _openAdmin(context) : null,
      ),
    );
  }
}
