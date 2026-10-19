import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  static const String _shareText =
      'جرّب NextStep AI — منصة بتساعدك تختار تخصصك الجامعي الصح بناءً على معدلك وميولك الحقيقية! 🎓👇 https://nextstepai.app';
  static const String _appLink = 'https://nextstepai.app';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutCubic));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isSuccess = true}) {
    final c = context.appColors;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: isSuccess ? c.success : c.danger,
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
                child: Text(message,
                    style: const TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ],
          ),
        ),
      );
  }

  Future<void> _shareApp() async {
    try {
      await SharePlus.instance.share(
        ShareParams(
            text: _shareText, subject: 'NextStep AI - منصة التوجيه الذكي'),
      );
    } catch (e) {
      _showSnackBar('حدث خطأ أثناء المشاركة', isSuccess: false);
    }
  }

  Future<void> _copyLink() async {
    try {
      await Clipboard.setData(const ClipboardData(text: _appLink));
      _showSnackBar('تم نسخ الرابط بنجاح! 📋');
    } catch (e) {
      _showSnackBar('حدث خطأ أثناء النسخ', isSuccess: false);
    }
  }

  Future<void> _copyMessage() async {
    try {
      await Clipboard.setData(const ClipboardData(text: _shareText));
      _showSnackBar('تم نسخ الرسالة بنجاح! 📋');
    } catch (e) {
      _showSnackBar('حدث خطأ أثناء النسخ', isSuccess: false);
    }
  }

  Future<void> _shareViaWhatsApp() async {
    final url =
        Uri.parse('https://wa.me/?text=${Uri.encodeComponent(_shareText)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar('لا يمكن فتح واتساب', isSuccess: false);
    }
  }

  Future<void> _shareViaTelegram() async {
    final url = Uri.parse(
      'https://t.me/share/url?url=${Uri.encodeComponent(_appLink)}&text=${Uri.encodeComponent(_shareText)}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar('لا يمكن فتح تيليجرام', isSuccess: false);
    }
  }

  Future<void> _shareViaX() async {
    final url = Uri.parse(
        'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(_shareText)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar('لا يمكن فتح منصة X', isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: c.background,
        appBar: _buildAppBar(c),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                children: [
                  _buildHeroSection(c),
                  const SizedBox(height: 24),
                  _buildShareableCard(c),
                  const SizedBox(height: 24),
                  _buildQuickShareSection(c),
                  const SizedBox(height: 24),
                  _buildShareMessageCard(c),
                  const SizedBox(height: 24),
                  _buildReferralCard(c),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(AppColors c) {
    return AppBar(
      backgroundColor: c.surface,
      elevation: 0,
      leading: const SizedBox.shrink(),
      leadingWidth: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.share_rounded, color: c.primaryContainer, size: 20),
          const SizedBox(width: 8),
          Text(
            'مشاركة التطبيق',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.only(left: 12),
          decoration:
              BoxDecoration(color: c.surfaceAlt, shape: BoxShape.circle),
          child: IconButton(
            icon: Icon(Icons.arrow_forward_ios_rounded,
                color: c.primaryContainer, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection(AppColors c) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: c.primarySoft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '✨ انشر الفائدة وشارك الإلهام',
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: c.primary),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'شارك مستقبلك مع أصدقائك ✨',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w800, color: c.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          'ساعد أصدقائك في اكتشاف تخصصهم الجامعي المناسب',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: c.textSecondary),
        ),
      ],
    );
  }

  Widget _buildShareableCard(AppColors c) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: c.primary.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8)),
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          _buildBrandHeader(c),
          const SizedBox(height: 20),
          _buildTagline(c),
          const SizedBox(height: 16),
          _buildQRCodeSection(c),
          const SizedBox(height: 20),
          _buildActionButtons(c),
        ],
      ),
    );
  }

  Widget _buildBrandHeader(AppColors c) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration:
              BoxDecoration(color: c.primaryContainer, shape: BoxShape.circle),
          child: Icon(Icons.psychology_rounded, color: c.surface, size: 26),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NextStep AI',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: c.textPrimary),
              ),
              Text(
                'المستقبل يبدأ بخطوة',
                style: TextStyle(fontSize: 12, color: c.textSecondary),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: c.primarySoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'التوجيه الذكي 🎯',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: c.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildTagline(AppColors c) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [c.gradientStart, c.gradientEnd]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'اكتشف تخصصك الجامعي المناسب بالذكاء الاصطناعي 🎓',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            'تحليل ميول، استشارات تفاعلية، وقرار واثق 100%',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12, color: Colors.white.withValues(alpha: 0.85)),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodeSection(AppColors c) {
    return Column(
      children: [
        Container(
          width: 180,
          height: 180,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: c.divider.withValues(alpha: 0.5), width: 1.5),
          ),
          child: CustomPaint(
            painter: QRCodePlaceholderPainter(
                primaryColor: c.primary, secondaryColor: c.primaryContainer),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: 10),
        Text('امسح الرمز بكاميرا الجوال',
            style: TextStyle(fontSize: 12, color: c.textSecondary)),
      ],
    );
  }

  Widget _buildActionButtons(AppColors c) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _shareApp,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                  color: c.surfaceAlt, borderRadius: BorderRadius.circular(14)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_rounded, color: c.textSecondary, size: 20),
                  const SizedBox(width: 8),
                  Text('حفظ كصورة 🖼️',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: c.textSecondary)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: _copyLink,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                  color: c.primarySoft,
                  borderRadius: BorderRadius.circular(14)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.link_rounded, color: c.primary, size: 20),
                  const SizedBox(width: 8),
                  Text('نسخ الرابط 🔗',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: c.primary)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickShareSection(AppColors c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.flash_on_rounded, color: c.accent, size: 20),
            const SizedBox(width: 8),
            Text('قنوات المشاركة السريعة',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary)),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(right: 28),
          child: Text('مباشر إلى تطبيقاتك',
              style: TextStyle(fontSize: 13, color: c.textSecondary)),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildQuickShareButton(
              c: c,
              icon: Icons.chat_rounded,
              label: 'واتساب',
              iconColor: const Color(0xFF25D366),
              bgColor: c.surfaceAlt,
              onTap: _shareViaWhatsApp,
            ),
            _buildQuickShareButton(
              c: c,
              icon: Icons.telegram_rounded,
              label: 'تيليجرام',
              iconColor: c.purple,
              bgColor: c.purple.withValues(alpha: 0.1),
              onTap: _shareViaTelegram,
            ),
            _buildQuickShareButton(
              c: c,
              icon: Icons.close_rounded,
              label: 'منصة X',
              iconColor: c.textPrimary,
              bgColor: c.surfaceAlt,
              onTap: _shareViaX,
            ),
            _buildQuickShareButton(
              c: c,
              icon: Icons.more_horiz_rounded,
              label: 'المزيد',
              iconColor: c.primary,
              bgColor: c.primarySoft,
              onTap: _shareApp,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickShareButton({
    required AppColors c,
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: c.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildShareMessageCard(AppColors c) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: c.primary.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: c.primarySoft,
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.format_quote_rounded,
                    color: c.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text('رسالة المشاركة المقترحة',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary)),
              ),
              GestureDetector(
                onTap: _copyMessage,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: c.surfaceAlt,
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.copy_rounded,
                      color: c.textSecondary, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.surfaceAlt,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(_shareText,
                style:
                    TextStyle(fontSize: 13, height: 1.6, color: c.textPrimary)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _shareApp,
              style: ElevatedButton.styleFrom(
                backgroundColor: c.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 4,
                shadowColor: c.primary.withValues(alpha: 0.3),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rocket_launch_rounded, size: 20),
                  SizedBox(width: 10),
                  Text('مشاركة الآن 🚀',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCard(AppColors c) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: c.surfaceAlt, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: c.purpleSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.school_rounded, color: c.purple, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ساعد دفعتك في الثانوية',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary)),
                const SizedBox(height: 4),
                Text(
                    'شاركهم التطبيق وساعدهم في اختيار التخصص الجامعي المناسب لمستقبلهم',
                    style: TextStyle(
                        fontSize: 12, height: 1.5, color: c.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QRCodePlaceholderPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  QRCodePlaceholderPainter(
      {required this.primaryColor, required this.secondaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final double cellSize = size.width / 25;
    final Paint mainPaint = Paint()..color = primaryColor;
    final Paint accentPaint = Paint()..color = secondaryColor;

    _drawFinderPattern(canvas, 0, 0, cellSize, mainPaint);
    _drawFinderPattern(
        canvas, size.width - cellSize * 7, 0, cellSize, mainPaint);
    _drawFinderPattern(
        canvas, 0, size.height - cellSize * 7, cellSize, mainPaint);

    final List<List<int>> dataPattern = [
      [9, 2, 15, 11, 7, 18, 4, 13],
      [6, 20, 3, 16, 10, 1, 14, 8],
      [17, 5, 12, 19, 2, 9, 21, 11],
      [3, 14, 8, 22, 15, 6, 13, 1],
      [10, 23, 7, 4, 18, 12, 20, 5],
      [16, 8, 21, 1, 14, 3, 9, 17],
      [2, 11, 19, 10, 7, 22, 15, 4],
      [13, 6, 1, 17, 20, 11, 8, 12],
    ];

    for (int row = 0; row < dataPattern.length; row++) {
      for (int col = 0; col < dataPattern[row].length; col++) {
        final int val = dataPattern[row][col];
        final double x = (col + 3) * cellSize;
        final double y = (row + 3) * cellSize;
        if (val % 3 == 0) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(x, y, cellSize * 0.85, cellSize * 0.85),
                Radius.circular(cellSize * 0.15)),
            accentPaint,
          );
        } else if (val % 2 == 0) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(x, y, cellSize * 0.85, cellSize * 0.85),
                Radius.circular(cellSize * 0.2)),
            mainPaint,
          );
        }
      }
    }

    for (int row = 0; row < dataPattern.length; row++) {
      for (int col = 10; col < 18 && col < dataPattern[row].length; col++) {
        final int val = dataPattern[row][(col + 3) % dataPattern[row].length];
        final double x = (col + 3) * cellSize;
        final double y = (row + 3) * cellSize;
        if (val % 4 != 0) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(x, y, cellSize * 0.85, cellSize * 0.85),
                Radius.circular(cellSize * 0.15)),
            val % 2 == 0 ? mainPaint : accentPaint,
          );
        }
      }
    }

    for (int row = 12; row < 20; row++) {
      for (int col = 3; col < 11; col++) {
        final int val =
            dataPattern[row % dataPattern.length][col % dataPattern[0].length];
        final double x = col * cellSize;
        final double y = row * cellSize;
        if (val % 3 != 1) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(x, y, cellSize * 0.8, cellSize * 0.8),
                Radius.circular(cellSize * 0.12)),
            val % 2 == 0 ? mainPaint : accentPaint,
          );
        }
      }
    }
  }

  void _drawFinderPattern(Canvas canvas, double startX, double startY,
      double cellSize, Paint paint) {
    final double outerSize = cellSize * 7;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(startX, startY, outerSize, outerSize),
          Radius.circular(cellSize * 1.2)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(startX + cellSize * 1.2, startY + cellSize * 1.2,
            cellSize * 4.6, cellSize * 4.6),
        Radius.circular(cellSize * 0.8),
      ),
      Paint()..color = const Color(0xFFFFFFFF),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(startX + cellSize * 2, startY + cellSize * 2,
            cellSize * 2.6, cellSize * 2.6),
        Radius.circular(cellSize * 0.6),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant QRCodePlaceholderPainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}
