import 'package:flutter/material.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class RateAppScreen extends StatefulWidget {
  const RateAppScreen({super.key});

  @override
  State<RateAppScreen> createState() => _RateAppScreenState();
}

class _RateAppScreenState extends State<RateAppScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pageCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  late final AnimationController _checkCtrl;
  late final Animation<double> _checkScaleAnim;
  late final Animation<double> _checkFadeAnim;

  int _rating = 0;
  bool _submitting = false;
  bool _submitted = false;
  String _feedbackText = '';
  final Set<String> _selectedTags = {};
  final TextEditingController _feedbackCtrl = TextEditingController();

  static const _tags = [
    {'icon': '\uD83C\uDFAF', 'label': 'دقة مسار التخصص'},
    {'icon': '\u26A1', 'label': 'سرعة التوجيه الذكي'},
    {'icon': '\uD83E\uDDED', 'label': 'وضوح الخطوات'},
    {'icon': '\uD83D\uDCA1', 'label': 'سهولة الواجهة'},
  ];

  static const _sentiments = {
    1: 'نأسف لذلك، سنعمل جاهدين على تحسين تجربتك \uD83D\uDEE0\uFE0F',
    2: 'شكراً لملاحظتك، نسعى لتقديم خدمة أفضل دائماً \uD83D\uDCC8',
    3: 'تقييم جيد! شاركنا كيف نجعل المنصة ممتازة \uD83D\uDCA1',
    4: 'سعداء بإعجابك بالتطبيق ومستعدون للمزيد \uD83D\uDE80',
    5: 'رائع جداً! يسعدنا ذلك ومستقبلنا واعد معاً \uD83C\uDF89',
  };

  static const _sentimentIcons = {
    1: Icons.sentiment_very_dissatisfied_rounded,
    2: Icons.sentiment_dissatisfied_rounded,
    3: Icons.sentiment_neutral_rounded,
    4: Icons.sentiment_satisfied_rounded,
    5: Icons.sentiment_very_satisfied_rounded,
  };

  @override
  void initState() {
    super.initState();
    _pageCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _pageCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _pageCtrl, curve: Curves.easeOutCubic));
    _pageCtrl.forward();

    _checkCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _checkScaleAnim = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut));
    _checkFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _checkCtrl, curve: const Interval(0.0, 0.5)));

    _feedbackCtrl.addListener(() {
      if (mounted) setState(() => _feedbackText = _feedbackCtrl.text);
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _checkCtrl.dispose();
    _feedbackCtrl.dispose();
    super.dispose();
  }

  bool get _isHighRating => _rating >= 4;

  Future<void> _submit() async {
    if (_rating == 0) {
      _showSnack('الرجاء اختيار تقييم أولاً', false);
      return;
    }
    setState(() => _submitting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _submitted = true;
    });
    _checkCtrl.forward();
  }

  void _showSnack(String msg, bool ok) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor:
              ok ? const Color(0xFF22C55E) : const Color(0xFFDC2626),
          content: Row(children: [
            Icon(
                ok
                    ? Icons.check_circle_outline_rounded
                    : Icons.error_outline_rounded,
                color: Colors.white,
                size: 20),
            const SizedBox(width: 10),
            Expanded(
                child: Text(msg,
                    style: const TextStyle(color: Colors.white, fontSize: 13))),
          ]),
        ),
      );
  }

  Future<void> _launchStore() async {
    final uri = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.example.nextstep_ai_app');
    if (await canLaunchUrl(uri))
      await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _launchSupport() async {
    final uri = Uri.parse('mailto:support@nextstepai.app');
    if (await canLaunchUrl(uri))
      await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: c.background,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                children: [
                  _buildHeader(c),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                      child: _submitted ? _buildThankYou(c) : _buildBody(c),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppColors c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(bottom: BorderSide(color: c.divider, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration:
                BoxDecoration(color: c.surfaceAlt, shape: BoxShape.circle),
            child: IconButton(
              icon: Icon(Icons.arrow_forward_ios_rounded,
                  color: c.primaryContainer, size: 18),
              onPressed: () => Navigator.pop(context),
              splashRadius: 24,
            ),
          ),
          const Spacer(),
          Icon(Icons.star_rounded, color: c.accent, size: 22),
          const SizedBox(width: 6),
          Text('تقييم التطبيق',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary)),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildBody(AppColors c) {
    return Column(
      children: [
        _buildHero(c),
        const SizedBox(height: 24),
        _buildStarCard(c),
        if (_rating > 0) ...[
          const SizedBox(height: 16),
          _buildSentimentBadge(c)
        ],
        const SizedBox(height: 20),
        _buildTags(c),
        const SizedBox(height: 20),
        _buildInput(c),
        const SizedBox(height: 24),
        _buildActions(c),
        const SizedBox(height: 24),
        _buildFooter(c),
      ],
    );
  }

  Widget _buildHero(AppColors c) {
    return Column(
      children: [
        SizedBox(
          height: 120,
          width: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: c.primaryContainer.withValues(alpha: 0.4),
                      blurRadius: 40,
                      spreadRadius: 10,
                    )
                  ],
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [c.gradientStart, c.gradientEnd],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.auto_awesome_rounded,
                      color: Colors.white, size: 36),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      color: c.primarySoft, shape: BoxShape.circle),
                  child: Icon(Icons.grade_rounded,
                      color: c.primaryContainer, size: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'كيف كانت تجربتك مع NextStep AI? \uD83C\uDF1F',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: c.textPrimary),
        ),
        const SizedBox(height: 6),
        Text(
          'تقييمك يساعدنا في تطوير تجربة أفضل للطلاب',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: c.textSecondary),
        ),
      ],
    );
  }

  Widget _buildStarCard(AppColors c) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final n = i + 1;
                final sel = n <= _rating;
                return GestureDetector(
                  onTap: () => setState(() => _rating = n),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: AnimatedScale(
                      scale: sel ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutBack,
                      child: Icon(
                        sel ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 36,
                        color: sel ? const Color(0xFFFBBF24) : c.divider,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _rating == 0 ? 'اضغط على النجمة لتقييم التطبيق' : '$_rating / 5',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _rating > 0 ? c.primaryContainer : c.textSecondary,
            ),
          ),
          if (_rating > 0) ...[
            const SizedBox(height: 6),
            Text(
              _sentiments[_rating] ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: c.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSentimentBadge(AppColors c) {
    final color = _rating >= 4
        ? c.success
        : _rating == 3
            ? c.accent
            : c.danger;
    final bg = _rating >= 4
        ? c.successSoft
        : _rating == 3
            ? c.accentSoft
            : c.dangerSoft;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_sentimentIcons[_rating] ?? Icons.star_rounded,
                size: 20, color: color),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _sentiments[_rating] ?? '',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTags(AppColors c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.local_offer_rounded,
                size: 18, color: c.primaryContainer),
            const SizedBox(width: 8),
            Text('ما الذي أعجبك بشكل خاص؟',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _tags.map((tag) {
            final key = tag['label']!;
            final sel = _selectedTags.contains(key);
            return GestureDetector(
              onTap: () => setState(() =>
                  sel ? _selectedTags.remove(key) : _selectedTags.add(key)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? c.primary : c.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: sel ? c.primary : c.divider, width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(tag['icon']!, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(tag['label']!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : c.textPrimary,
                        )),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInput(AppColors c) {
    final len = _feedbackText.length;
    const maxLen = 300;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text('شاركنا رأيك بالتفصيل (ما أكثر ميزة أعجبتك؟)',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary)),
            ),
            const SizedBox(width: 8),
            Text('$len/$maxLen حرف',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: len > maxLen ? c.danger : c.textSecondary,
                )),
          ]),
          const SizedBox(height: 12),
          TextField(
            controller: _feedbackCtrl,
            maxLines: 4,
            maxLength: maxLen,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 14, color: c.textPrimary, height: 1.6),
            decoration: InputDecoration(
              hintText: 'اكتب ملاحظاتك هنا...',
              hintStyle: TextStyle(color: c.divider, fontSize: 13),
              filled: true,
              fillColor: c.surfaceAlt,
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: c.primary, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Icon(Icons.verified_rounded, size: 14, color: c.success),
            const SizedBox(width: 6),
            Expanded(
              child: Text('ملاحظاتك تصل فوراً لفريق تطوير المحتوى الأكاديمي',
                  style: TextStyle(fontSize: 11, color: c.textSecondary)),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildActions(AppColors c) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _submitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: c.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: c.primary.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: c.primary.withValues(alpha: 0.3),
            ),
            child: _submitting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('\u2B50', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Text('إرسال التقييم',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ],
                  ),
          ),
        ),
        if (_isHighRating) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: _launchStore,
              style: OutlinedButton.styleFrom(
                foregroundColor: c.primaryContainer,
                side: BorderSide(color: c.divider, width: 1.2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.storefront_rounded,
                      size: 20, color: c.primaryContainer),
                  const SizedBox(width: 8),
                  Text('نشر التقييم على Google Play / App Store',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: c.primaryContainer)),
                ],
              ),
            ),
          ),
        ],
        if (!_isHighRating && _rating > 0) ...[
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _launchSupport,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.support_agent_rounded,
                    size: 16, color: c.textSecondary),
                const SizedBox(width: 6),
                Text('هل واجهت مشكلة؟ أخبرنا بها مباشرة عبر الدعم',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: c.textSecondary,
                      decoration: TextDecoration.underline,
                      decorationColor: c.textSecondary,
                    )),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFooter(AppColors c) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            color: c.surfaceAlt, borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield_rounded, size: 14, color: c.textSecondary),
            const SizedBox(width: 6),
            Text('تقييمك يُحفظ بأمان في قاعدة بيانات NextStep',
                style: TextStyle(fontSize: 11, color: c.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildThankYou(AppColors c) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        AnimatedBuilder(
          animation: _checkCtrl,
          builder: (context, child) {
            return Opacity(
              opacity: _checkFadeAnim.value,
              child: Transform.scale(
                scale: _checkScaleAnim.value,
                child: child,
              ),
            );
          },
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [c.success, const Color(0xFF059669)],
              ),
              boxShadow: [
                BoxShadow(
                  color: c.success.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: const Center(
                child:
                    Icon(Icons.check_rounded, size: 52, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 24),
        Text('شكراً لملاحظاتك!',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: c.textPrimary)),
        const SizedBox(height: 8),
        Text('تقييمك يساعدنا في بناء تجربة أفضل',
            style: TextStyle(fontSize: 14, color: c.textSecondary)),
        const SizedBox(height: 16),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final n = i + 1;
              final filled = n <= _rating;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 28,
                  color: filled ? const Color(0xFFFBBF24) : c.divider,
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: c.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: c.primary.withValues(alpha: 0.3),
            ),
            child: const Text('العودة',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: _launchStore,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.storefront_rounded,
                  size: 16, color: c.primaryContainer),
              const SizedBox(width: 6),
              Text('اكتب تقييماً في المتجر',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: c.primaryContainer,
                    decoration: TextDecoration.underline,
                    decorationColor: c.primaryContainer,
                  )),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
