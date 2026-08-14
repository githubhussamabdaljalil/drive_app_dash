import 'package:driver_app_dash/features/owner_profile/presentation/screens/cubit/profile_cubit.dart';
import 'package:driver_app_dash/features/owner_profile/presentation/screens/models/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dashboard/dashboard_layout.dart';
import '../../../../core/constants/app_routes.dart';



class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      activeRoute: AppRoutes.profile,
      pageTitle: 'الملف الشخصي',

      body: BlocProvider(
        create: (_) => ProfileCubit()..loadProfile(),
        child: const _ProfileView(),
      ),
    );
  }
}

// ============================================================================
// PROFILE VIEW
// ============================================================================

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      },

      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is ProfileError) {
          return _ErrorView(
            message: state.message,
            onRetry: () {
              context.read<ProfileCubit>().loadProfile();
            },
          );
        }

        if (state is ProfileLoaded) {
          return _ProfileContent(
            profile: state.profile,
          );
        }

        return const SizedBox();
      },
    );
  }
}

// ============================================================================
// PROFILE CONTENT
// ============================================================================

class _ProfileContent extends StatelessWidget {
  final ProfileModel profile;

  const _ProfileContent({
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================================================================
          // HEADER
          // ================================================================

          const Text(
            'معلومات الحساب',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'عرض معلومات حسابك الشخصي',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 24),

          // ================================================================
          // PROFILE CARD
          // ================================================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==========================================================
                // AVATAR + NAME
                // ==========================================================

                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          profile.name.isNotEmpty
                              ? profile.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            profile.email,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    _RoleBadge(
                      role: profile.role,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                const Divider(
                  color: AppColors.border,
                ),

                const SizedBox(height: 20),

                // ==========================================================
                // INFORMATION
                // ==========================================================

                const _SectionTitle(
                  title: 'البيانات الشخصية',
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.person_outline,
                        label: 'الاسم',
                        value: profile.name,
                      ),
                    ),

                    const SizedBox(width: 20),

                    Expanded(
                      child: _InfoItem(
                        icon: Icons.email_outlined,
                        label: 'البريد الإلكتروني',
                        value: profile.email,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.phone_outlined,
                        label: 'رقم الهاتف',
                        value: profile.phone?.isNotEmpty == true
                            ? profile.phone!
                            : 'غير محدد',
                      ),
                    ),

                    const SizedBox(width: 20),

                    Expanded(
                      child: _InfoItem(
                        icon: Icons.badge_outlined,
                        label: 'الصلاحية',
                        value: profile.role,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.business_outlined,
                        label: 'رقم الشركة',
                        value: profile.companyId?.toString() ??
                            'لا يوجد',
                      ),
                    ),

                    const SizedBox(width: 20),

                    Expanded(
                      child: _InfoItem(
                        icon: Icons.lock_outline,
                        label: 'تغيير كلمة المرور',
                        value: profile.mustChangePassword
                            ? 'مطلوب'
                            : 'غير مطلوب',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ==========================================================
                // PERMISSIONS
                // ==========================================================

                const _SectionTitle(
                  title: 'الصلاحيات',
                ),

                const SizedBox(height: 14),

                if (profile.permissions.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'لا توجد صلاحيات إضافية',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: profile.permissions.map((permission) {
                      return _PermissionChip(
                        permission: permission.toString(),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SECTION TITLE
// ============================================================================

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 15,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        const SizedBox(width: 8),

        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// INFO ITEM
// ============================================================================

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 17,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ROLE BADGE
// ============================================================================

class _RoleBadge extends StatelessWidget {
  final String role;

  const _RoleBadge({
    required this.role,
  });

  String get roleText {
    switch (role) {
      case 'owner':
        return 'مالك النظام';

      case 'admin':
        return 'مدير';

      case 'manager':
        return 'مدير شركة';

      case 'driver':
        return 'سائق';

      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        roleText,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ============================================================================
// PERMISSION CHIP
// ============================================================================

class _PermissionChip extends StatelessWidget {
  final String permission;

  const _PermissionChip({
    required this.permission,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        permission,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ============================================================================
// ERROR VIEW
// ============================================================================

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.danger,
          ),

          const SizedBox(height: 12),

          const Text(
            'تعذر تحميل بيانات الملف الشخصي',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}