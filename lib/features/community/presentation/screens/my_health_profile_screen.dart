import 'package:flutter/material.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/features/admin/data/admin_repository.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/community/data/community_image_upload_service.dart';
import 'package:visualcheckup/features/community/data/health_community_repository.dart';
import 'package:visualcheckup/features/community/presentation/screens/health_chat_screen.dart';
import 'package:visualcheckup/features/community/presentation/screens/health_community_hub_screen.dart';
import 'package:visualcheckup/features/community/presentation/screens/health_profile_detail_screen.dart';
import 'package:visualcheckup/features/community/presentation/widgets/social_profile_view.dart';

/// Dedicated "My Profile" (Profilim) screen launched directly from the top of
/// [AppDrawer] or the Drawer account card — modeled after Social Formula Bank's
/// top-level Profile entry with instant one-tap jump into the Global Health
/// Community.
class MyHealthProfileScreen extends StatelessWidget {
  const MyHealthProfileScreen({
    super.key,
    required this.currentUser,
    required this.repository,
    this.adminRepository,
    this.uploadService,
    this.photoPicker,
    this.urlLauncher,
  });

  final AuthUser currentUser;
  final HealthCommunityRepository repository;
  final AdminRepository? adminRepository;
  final CommunityImageUploadService? uploadService;
  final CommunityPhotoPicker? photoPicker;
  final CommunityUrlLauncher? urlLauncher;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.commTabMyProfile),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 10),
            child: TextButton.icon(
              key: const Key('my_profile_open_community_btn'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => HealthCommunityHubScreen(
                      currentUser: currentUser,
                      repository: repository,
                      adminRepository: adminRepository,
                      uploadService: uploadService,
                      photoPicker: photoPicker,
                      urlLauncher: urlLauncher,
                      initialTabIndex: 0,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.public_rounded, size: 18),
              label: Text(l10n.commOpenCommunityCta),
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
      ),
    );
  }
}
