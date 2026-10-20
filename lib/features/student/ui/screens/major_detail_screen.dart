import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nextstep_ai_app/core/helpers/hive_storage.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/core/widgets/app_dialogs.dart';
import 'package:nextstep_ai_app/core/widgets/app_snack.dart';

class MajorDetailScreen extends StatefulWidget {
  final Map<String, dynamic> majorData;

  const MajorDetailScreen({
    super.key,
    required this.majorData,
  });

  @override
  State<MajorDetailScreen> createState() => _MajorDetailScreenState();
}

class _MajorDetailScreenState extends State<MajorDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isFavorite = false;

  String get _favoriteKey {
    final id = widget.majorData['id'] ?? widget.majorData['name'] ?? 'unknown';
    return 'major_$id';
  }

  @override
  void initState() {
    super.initState();
    _loadFavorite();
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

  Future<void> _loadFavorite() async {
    try {
      final saved = await HiveStorage.getData('favorites_cache', _favoriteKey);
      if (mounted && saved == true) {
        setState(() => _isFavorite = true);
      }
    } catch (_) {
      
    }
  }

  Future<void> _toggleFavorite() async {
    final nextFavorite = !_isFavorite;
    try {
      if (nextFavorite) {
        await HiveStorage.saveData(
          'favorites_cache',
          _favoriteKey,
          true,
        );
      } else {
        await HiveStorage.deleteData('favorites_cache', _favoriteKey);
      }
      if (!mounted) return;
      setState(() => _isFavorite = nextFavorite);
      _showSnackBar(
        nextFavorite ? 'أُضيف التخصص إلى المفضلة' : 'أُزيل التخصص من المفضلة',
      );
    } catch (_) {
      if (!mounted) return;
      _showSnackBar(
        'تعذّر تحديث المفضلة على هذا الجهاز',
        isSuccess: false,
      );
    }
  }

  Future<void> _shareMajor() async {
    final title = (widget.majorData['name'] ?? 'تخصص أكاديمي').toString();
    final university =
        (widget.majorData['university'] ??
                widget.majorData['university_name'] ??
                '')
            .toString();
    final summary = university.isEmpty ? title : '$title — $university';
    try {
      await Clipboard.setData(ClipboardData(text: summary));
      if (!mounted) return;
      _showSnackBar('تم نسخ ملخص التخصص');
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('تعذّر نسخ الملخص', isSuccess: false);
    }
  }

  void _showApplicationUnavailable() {
    showAppInfoDialog(
      context,
      title: 'التقديم الإلكتروني غير متاح',
      message: 'هذه النسخة تجريبية ولم يتم ربط التقديم بالجامعة بعد. '
          'يمكنك حفظ التخصص في المفضلة أو مشاركته للرجوع إليه لاحقاً.',
    );
  }

  String _textValue(dynamic value, String fallback) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  String _durationValue(dynamic value) {
    if (value is num) {
      return value.toInt() == 1 ? 'سنة واحدة' : '${value.toInt()} سنوات';
    }
    final text = _textValue(value, '4 سنوات');
    return RegExp(r'^\d+$').hasMatch(text) ? '$text سنوات' : text;
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.majorData;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _buildAppBar(),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroHeader(data),
                  const SizedBox(height: 24),
                  _buildMatchScore(data),
                  const SizedBox(height: 24),
                  _buildOverview(data),
                  const SizedBox(height: 20),
                  _buildQuickInfoGrid(data),
                  const SizedBox(height: 20),
                  _buildDescription(data),
                  const SizedBox(height: 20),
                  _buildCareerOpportunities(data),
                  const SizedBox(height: 20),
                  _buildRequirements(data),
                  const SizedBox(height: 20),
                  _buildSimilarMajors(),
                  const SizedBox(height: 30),
                  _buildActions(),
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
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: context.appColors.shadow,
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: context.appColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
          splashRadius: 24,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.appColors.surface,
              shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: context.appColors.shadow,
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: IconButton(
            tooltip: _isFavorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
            icon: Icon(
              _isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: _isFavorite
                ? context.appColors.danger
                : context.appColors.textPrimary,
            ),
            onPressed: _toggleFavorite,
            splashRadius: 24,
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.appColors.surface,
              shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: context.appColors.shadow,
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: IconButton(
            tooltip: 'مشاركة التخصص',
            icon: Icon(
              Icons.share_rounded,
              color: context.appColors.textPrimary,
            ),
            onPressed: _shareMajor,
            splashRadius: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroHeader(Map<String, dynamic> data) {
    final category = _textValue(
      data['category'] ?? data['type'],
      'تخصص أكاديمي',
    );
    final university = _textValue(
      data['university'] ?? data['university_name'],
      'جامعة غير محددة',
    );
    final duration = _durationValue(data['duration']);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.appColors.gradientStart,
            context.appColors.gradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow,
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              category,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data['name'] ?? 'التخصص',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.location_city_rounded,
                size: 18,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  university,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildHeroStat(
                icon: Icons.people_rounded,
                value: _textValue(data['students'], '2.5K'),
                label: 'طلاب',
              ),
              const SizedBox(width: 20),
              _buildHeroStat(
                icon: Icons.school_rounded,
                value: duration,
                label: 'المدة',
              ),
              const SizedBox(width: 20),
              _buildHeroStat(
                icon: Icons.work_rounded,
                value: _textValue(data['employment_rate'], '95%'),
                label: 'توظيف',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.6)),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMatchScore(Map<String, dynamic> data) {
    final matchValue = data['match'] ?? data['compatibility'] ?? 0;
    final match =
        (matchValue is num ? matchValue : num.tryParse('$matchValue') ?? 0)
            .round();
    final color = _getMatchColor(match);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.appColors.divider, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$match%',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color,
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
                  'نسبة التوافق',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.appColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'هذا التخصص يتوافق مع ميولك بنسبة $match%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: context.appColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: match / 100,
                    backgroundColor: context.appColors.surfaceAlt,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getMatchColor(int match) {
    if (match >= 80) return context.appColors.success;
    if (match >= 60) return context.appColors.warning;
    return context.appColors.danger;
  }

  Widget _buildOverview(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.appColors.divider, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
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
                  color: context.appColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: context.appColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'نظرة عامة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data['description'] ?? 'لا يوجد وصف متاح',
            style: TextStyle(
              fontSize: 14,
              height: 1.7,
              color: context.appColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoGrid(Map<String, dynamic> data) {
    final items = [
      {
        'icon': Icons.timeline_rounded,
        'label': 'المدة',
        'value': _durationValue(data['duration']),
        'color': Colors.blue,
      },
      {
        'icon': Icons.attach_money_rounded,
        'label': 'الرسوم السنوية',
        'value': _textValue(data['fee'], '5,000 ₪'),
        'color': Colors.green,
      },
      {
        'icon': Icons.grade_rounded,
        'label': 'الحد الأدنى',
        'value': _textValue(data['minScore'], '85%'),
        'color': Colors.orange,
      },
      {
        'icon': Icons.people_rounded,
        'label': 'عدد الطلاب',
        'value': _textValue(data['students'], '2,500'),
        'color': Colors.purple,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.appColors.divider, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: context.appColors.shadow,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: item['color'] as Color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item['value'] as String,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
                ),
              ),
              Text(
                item['label'] as String,
                style: TextStyle(
                  fontSize: 11,
                  color: context.appColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDescription(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.appColors.divider, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
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
                  color: context.appColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.description_rounded,
                  color: context.appColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'الوصف التفصيلي',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _textValue(
              data['detailed_description'] ?? data['description'],
              'هذا التخصص يقدم مجموعة متكاملة من المهارات والمعرفة '
              'التي تؤهل الطالب لسوق العمل في مختلف المجالات.',
            ),
            style: TextStyle(
              fontSize: 14,
              height: 1.7,
              color: context.appColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareerOpportunities(Map<String, dynamic> data) {
    final careers = (data['career'] as String?)?.split('،') ??
        [
          'مهندس برمجيات',
          'مطور تطبيقات',
          'مهندس شبكات',
          'محلل نظم',
          'مدير مشاريع تقنية',
        ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.appColors.divider, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
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
                  color: context.appColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.work_rounded,
                  color: context.appColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'فرص العمل',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...careers.map((career) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: context.appColors.success,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        career.trim(),
                        style: TextStyle(
                          fontSize: 14,
                          color: context.appColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildRequirements(Map<String, dynamic> data) {
    final requirements = (data['requirements'] as List?) ??
        [
          'شهادة ثانوية عامة بمعدل لا يقل عن 85%',
          'اجتياز امتحان القبول في الجامعة',
          'مقابلة شخصية',
          'إتقان اللغة الإنجليزية',
        ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.appColors.divider, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
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
                  color: context.appColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.rule_rounded,
                  color: context.appColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'متطلبات القبول',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...requirements.map((req) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: context.appColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        req.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: context.appColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSimilarMajors() {
    final similar = [
      {
        'name': 'هندسة البرمجيات',
        'match': 88,
        'university': 'الجامعة الإسلامية'
      },
      {'name': 'علوم الحاسوب', 'match': 82, 'university': 'جامعة الأزهر'},
      {'name': 'نظم المعلومات', 'match': 76, 'university': 'جامعة الأقصى'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.appColors.divider, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
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
                  color: context.appColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.sync_alt_rounded,
                  color: context.appColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'تخصصات مشابهة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...similar.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.appColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.appColors.textPrimary,
                            ),
                          ),
                          Text(
                            item['university'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: context.appColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getMatchColor(item['match'] as int)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${item['match']}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _getMatchColor(item['match'] as int),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: context.appColors.textPrimary,
              side: BorderSide(color: context.appColors.divider),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'رجوع',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _showApplicationUnavailable,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.appColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.send_rounded, size: 18),
                SizedBox(width: 8),
                Text(
                  'تقديم طلب',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSnackBar(String message, {bool isSuccess = true}) {
    if (isSuccess) {
      AppSnack.success(context, message);
    } else {
      AppSnack.error(context, message);
    }
  }
}
