import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theming/app_theme.dart';
import 'app_buttons.dart';

/// Empty state with a clear next step. Never show a fake button.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: c.primarySoft,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: c.primary.withValues(alpha: 0.18),
                  ),
                ),
                child: Icon(icon, size: 38, color: c.primary),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                textAlign: TextAlign.center,
                style: context.textStyles.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                message,
                textAlign: TextAlign.center,
                style: context.textStyles.bodyMedium?.copyWith(
                  color: c.textSecondary,
                  height: 1.65,
                ),
              ),
              if (actionLabel != null && onAction != null) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: 220,
                  child: AppPrimaryButton(
                    label: actionLabel!,
                    onPressed: onAction,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Error state with retry. The retry callback is always functional.
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    required this.message,
    this.title = 'تعذّر تحميل البيانات',
    this.onRetry,
    this.retryLabel = 'إعادة المحاولة',
  });

  final String message;
  final String title;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: c.dangerSoft,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: c.danger.withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(
                  Icons.cloud_off_rounded,
                  size: 38,
                  color: c.danger,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                textAlign: TextAlign.center,
                style: context.textStyles.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                message,
                textAlign: TextAlign.center,
                style: context.textStyles.bodyMedium?.copyWith(
                  color: c.textSecondary,
                  height: 1.65,
                ),
              ),
              if (onRetry != null) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: 220,
                  child: AppPrimaryButton(
                    label: retryLabel,
                    icon: Icons.refresh_rounded,
                    onPressed: onRetry,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Centered loading state that keeps the user oriented.
class AppLoadingState extends StatelessWidget {
  const AppLoadingState({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(strokeWidth: 2.6),
            ),
            if (message != null) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: context.textStyles.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Single skeleton block with a shimmer that adapts to the theme.
class AppSkeleton extends StatelessWidget {
  const AppSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.radius = AppRadius.sm,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    return Shimmer.fromColors(
      baseColor: c.surfaceAlt,
      highlightColor: c.surface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: c.surfaceAlt,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// Standard list skeleton used while a collection is loading.
class AppListSkeleton extends StatelessWidget {
  const AppListSkeleton({super.key, this.itemCount = 5, this.itemHeight = 92});

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: context.pagePadding,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, __) => AppSkeleton(
        height: itemHeight,
        radius: AppRadius.lg,
      ),
    );
  }
}
