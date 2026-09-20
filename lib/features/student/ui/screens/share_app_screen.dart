import 'package:flutter/material.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareAppScreen extends StatefulWidget {
  const ShareAppScreen({super.key});

  @override
  State<ShareAppScreen> createState() => _ShareAppScreenState();
}

class _ShareAppScreenState extends State<ShareAppScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final String _appLink =
      'https://play.google.com/store/apps/details?id=com.example.nextstep_ai_app';
  final String _appWebsite = 'https://nextstepai.com';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _shareApp() async {
    try {
      await Share.share(
        '🎓 اكتشف مستقبلك مع NextStep AI!\n\n'
        'منصة ذكية للإرشاد الأكاديمي والمهني بالذكاء الاصطناعي.\n'
        'ساعد طلابك في اختيار التخصص والجامعة المناسبة.\n\n'
        '📲 حمّل التطبيق الآن:\n$_appLink\n\n'
        '🌐 زور موقعنا: $_appWebsite',
        subject: 'NextStep AI - منصة الإرشاد الأكاديمي',
      );
    } catch (e) {
      _showSnackBar('حدث خطأ أثناء المشاركة', isSuccess: false);
    }
  }

  void _copyLink() {
    _showSnackBar('تم نسخ الرابط بنجاح! 📋');
  }

  void _showSnackBar(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor:
              isSuccess ? const Color(0xFF22C55E) : const Color(0xFFDC2626),
          content: Row(
            children: [
              Icon(
                isSuccess
                    ? Icons.check_circle_outline_rounded
                    : Icons.error_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      _showSnackBar('لا يمكن فتح الرابط', isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: _buildAppBar(),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildQRCodeSection(),
                  const SizedBox(height: 24),
                  _buildShareButtons(),
                  const SizedBox(height: 24),
                  _buildSocialSection(),
                  const SizedBox(height: 24),
                  _buildAppInfo(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppTheme.primaryContainer,
          ),
          onPressed: () => Navigator.pop(context),
          splashRadius: 24,
        ),
      ),
      title: const Text(
        'شارك التطبيق',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryContainer,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primaryContainer],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.25),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'شارك NextStep AI 📲',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'ساعد الآخرين في اكتشاف مسارهم الأكاديمي والمهني',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(
                Icons.share_rounded,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodeSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.qr_code_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'رمز QR للتطبيق',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200, width: 1.5),
              ),
              child: const Center(
                child: Icon(
                  Icons.qr_code_rounded,
                  size: 100,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'امسح الرمز لتحميل التطبيق مباشرة',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.share_rounded,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'مشاركة التطبيق',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildShareButton(
                  icon: Icons.share_rounded,
                  label: 'مشاركة',
                  color: const Color(0xFF3B82F6),
                  onTap: _shareApp,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildShareButton(
                  icon: Icons.copy_rounded,
                  label: 'نسخ الرابط',
                  color: const Color(0xFF8B5CF6),
                  onTap: _copyLink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1.2),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.people_rounded,
                  color: Color(0xFFF97316),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'تابعنا على وسائل التواصل',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialIcon(
                icon: Icons.facebook_rounded,
                label: 'فيسبوك',
                color: const Color(0xFF1877F2),
                onTap: () => _launchURL('https://facebook.com/nextstepai'),
              ),
              _buildSocialIcon(
                icon: Icons.message_rounded,
                label: 'تويتر',
                color: const Color(0xFF1DA1F2),
                onTap: () => _launchURL('https://twitter.com/nextstepai'),
              ),
              _buildSocialIcon(
                icon: Icons.photo_camera_back_rounded,
                label: 'انستغرام',
                color: const Color(0xFFE4405F),
                onTap: () => _launchURL('https://instagram.com/nextstepai'),
              ),
              _buildSocialIcon(
                icon: Icons.youtube_searched_for_rounded,
                label: 'يوتيوب',
                color: const Color(0xFFFF0000),
                onTap: () => _launchURL('https://youtube.com/nextstepai'),
              ),
              _buildSocialIcon(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'واتساب',
                color: const Color(0xFF25D366),
                onTap: () => _launchURL('https://wa.me/970599123456'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.info_rounded,
                  color: Color(0xFF22C55E),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'عن التطبيق',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.rocket_launch_rounded,
            label: 'الإصدار',
            value: '1.0.0',
          ),
          _buildInfoRow(
            icon: Icons.update_rounded,
            label: 'آخر تحديث',
            value: 'أغسطس 2026',
          ),
          _buildInfoRow(
            icon: Icons.download_rounded,
            label: 'حجم التطبيق',
            value: '~25 MB',
          ),
          _buildInfoRow(
            icon: Icons.language_rounded,
            label: 'الموقع الإلكتروني',
            value: 'nextstepai.com',
            isLink: true,
            onTap: () => _launchURL(_appWebsite),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isLink = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          if (isLink && onTap != null)
            InkWell(
              onTap: onTap,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.secondary,
                  decoration: TextDecoration.underline,
                ),
              ),
            )
          else
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryContainer,
              ),
            ),
        ],
      ),
    );
  }
}
