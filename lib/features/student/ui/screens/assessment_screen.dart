import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/core/helpers/hive_storage.dart';

enum _AssessmentState { question, analyzing, results }

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  String? _errorMessage;
  _AssessmentState _state = _AssessmentState.question;

  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  int _totalQuestions = 0;
  Map<int, int> _answers = {};

  final Map<String, double> _dimensions = {
    'programming': 0.0,
    'math': 0.0,
    'communication': 0.0,
    'research': 0.0,
    'practical': 0.0,
    'management': 0.0,
  };

  late AnimationController _questionAnimController;
  late AnimationController _confettiController;
  late AnimationController _analyzingController;
  late Animation<double> _questionFade;
  late Animation<Offset> _questionSlide;
  bool _hasPlayedIntro = false;

  @override
  void initState() {
    super.initState();
    _questionAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _questionFade = CurvedAnimation(
      parent: _questionAnimController,
      curve: Curves.easeOut,
    );
    _questionSlide = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
          parent: _questionAnimController, curve: Curves.easeOutCubic),
    );
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _analyzingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _loadQuestions();
  }

  @override
  void dispose() {
    _questionAnimController.dispose();
    _confettiController.dispose();
    _analyzingController.dispose();
    super.dispose();
  }

  // ─── Data helpers ────────────────────────────────────────────────────────

  String _dimName(String key) => switch (key) {
        'programming' => 'البرمجة',
        'math' => 'الرياضيات',
        'communication' => 'التواصل',
        'research' => 'البحث العلمي',
        'practical' => 'العملي',
        'management' => 'الإدارة',
        _ => key,
      };

  String _dimIcon(String key) => switch (key) {
        'programming' => '💻',
        'math' => '📐',
        'communication' => '🗣️',
        'research' => '🔬',
        'practical' => '🔧',
        'management' => '📊',
        _ => '📌',
      };

  IconData _dimMaterialIcon(String key) => switch (key) {
        'programming' => Icons.code_rounded,
        'math' => Icons.calculate_rounded,
        'communication' => Icons.forum_rounded,
        'research' => Icons.science_rounded,
        'practical' => Icons.build_rounded,
        'management' => Icons.analytics_rounded,
        _ => Icons.star_rounded,
      };

  Color _dimColor(String key, AppColors c) => switch (key) {
        'programming' => c.primary,
        'math' => const Color(0xFF4953BC),
        'communication' => const Color(0xFF00414D),
        'research' => const Color(0xFF4338CA),
        'practical' => c.success,
        'management' => c.purple,
        _ => c.primary,
      };

  double get _progress =>
      _totalQuestions > 0 ? _answers.length / _totalQuestions : 0;

  // ─── Load / Save ─────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _getDefaultQuestions() {
    return [
      {
        'id': 1,
        'question_text':
            'إلى أي مدى تجد نفسك مستمتعاً عند تفكيك المشكلات المعقدة وتصميم خطوات خوارزمية لحلها؟',
        'dimension': 'programming',
      },
      {
        'id': 2,
        'question_text':
            'كم تستمتع بحل المعادلات الرياضية واستكشاف الأنماط الكمية والمنطقية؟',
        'dimension': 'math',
      },
      {
        'id': 3,
        'question_text':
            'ما مدى راحتك في التواصل مع الآخرين وتقديم الأفكار والإقناع في بيئة عمل مشتركة؟',
        'dimension': 'communication',
      },
      {
        'id': 4,
        'question_text':
            'إلى أي مدى تشعر بالفضول لاكتشاف معلومات جديدة والتحقق منها بشكل علمي منهجي؟',
        'dimension': 'research',
      },
      {
        'id': 5,
        'question_text':
            'كم تستمتع بتطبيق المعرفة عملياً وحل المشكلات الواقعية بيديك؟',
        'dimension': 'practical',
      },
      {
        'id': 6,
        'question_text':
            'ما مدى ميلك لتنظيم المهام وقيادة الفرق واتخاذ القرارات الاستراتيجية؟',
        'dimension': 'management',
      },
    ];
  }

  Future<void> _loadQuestions() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final cached = await HiveStorage.getData('assessment_cache', 'questions');
      if (cached != null && (cached as List).isNotEmpty) {
        _questions = List<Map<String, dynamic>>.from(cached);
      } else {
        _questions = _getDefaultQuestions();
        await HiveStorage.saveData('assessment_cache', 'questions', _questions);
      }
      _totalQuestions = _questions.length;
      await _loadSavedAnswers();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _updateProgress();
        });
        _playIntroAnimation();
      }
    } catch (e) {
      _questions = _getDefaultQuestions();
      _totalQuestions = _questions.length;
      if (mounted) {
        setState(() {
          _isLoading = false;
          _updateProgress();
        });
        _playIntroAnimation();
      }
    }
  }

  void _playIntroAnimation() {
    if (_hasPlayedIntro) return;
    _hasPlayedIntro = true;
    _questionAnimController.forward(from: 0);
  }

  Future<void> _loadSavedAnswers() async {
    try {
      final saved = await HiveStorage.getData('assessment_cache', 'answers');
      if (saved != null) {
        _answers = Map<int, int>.from(saved);
        if (_answers.isNotEmpty) {
          _currentQuestionIndex = _answers.keys.last;
          if (_answers.length >= _totalQuestions) {
            _currentQuestionIndex = _totalQuestions - 1;
          }
        }
      }
    } catch (_) {}
  }

  void _updateProgress() {
    _progress;
  }

  Future<void> _saveAnswers() async {
    await HiveStorage.saveData('assessment_cache', 'answers', _answers);
  }

  // ─── Actions ─────────────────────────────────────────────────────────────

  void _selectAnswer(int qIndex, int value) {
    HapticFeedback.lightImpact();
    setState(() {
      _answers[qIndex] = value;
    });
    _saveAnswers();

    if (_currentQuestionIndex < _totalQuestions - 1) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          _questionAnimController.forward(from: 0);
          setState(() => _currentQuestionIndex++);
        }
      });
    }
  }

  void _goNext() {
    if (_currentQuestionIndex < _totalQuestions - 1) {
      if (_answers.containsKey(_currentQuestionIndex)) {
        _questionAnimController.forward(from: 0);
        setState(() => _currentQuestionIndex++);
      } else {
        _showSnack('الرجاء اختيار إجابة', const Color(0xFFF59E0B));
      }
    } else if (_answers.length >= _totalQuestions) {
      _startAnalyzing();
    } else {
      _showSnack('الرجاء الإجابة على جميع الأسئلة', const Color(0xFFF59E0B));
    }
  }

  void _goPrev() {
    if (_currentQuestionIndex > 0) {
      _questionAnimController.forward(from: 0);
      setState(() => _currentQuestionIndex--);
    }
  }

  void _startAnalyzing() {
    setState(() => _state = _AssessmentState.analyzing);
    _calculateResults();
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        setState(() => _state = _AssessmentState.results);
        _confettiController.forward(from: 0);
      }
    });
  }

  void _calculateResults() {
    final Map<String, List<int>> dimAnswers = {};
    for (int i = 0; i < _questions.length; i++) {
      if (_answers.containsKey(i)) {
        final dim = _questions[i]['dimension'] ?? 'general';
        final ans = _answers[i]!;
        final score = (ans / 4) * 100;
        dimAnswers.putIfAbsent(dim, () => []).add(score.toInt());
      }
    }
    for (var e in dimAnswers.entries) {
      _dimensions[e.key] = e.value.reduce((a, b) => a + b) / e.value.length;
    }
    HiveStorage.saveData('assessment_cache', 'results', _dimensions);
    HiveStorage.saveData('assessment_cache', 'completed', true);
  }

  Future<void> _restartAssessment() async {
    await HiveStorage.deleteData('assessment_cache', 'answers');
    await HiveStorage.deleteData('assessment_cache', 'results');
    await HiveStorage.deleteData('assessment_cache', 'completed');
    if (!mounted) return;
    setState(() {
      _state = _AssessmentState.question;
      _answers.clear();
      _dimensions.updateAll((key, value) => 0.0);
      _currentQuestionIndex = 0;
    });
    _questionAnimController.forward(from: 0);
  }

  Future<void> _shareResults() async {
    final sorted = _dimensions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final summary = sorted
        .take(3)
        .map((entry) => '${_dimName(entry.key)}: ${entry.value.toInt()}%')
        .join('\n');
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: 'نتيجة التقييم الذكي في NextStep AI\n\n$summary',
          subject: 'نتيجة التقييم الذكي',
        ),
      );
    } catch (_) {
      if (!mounted) return;
      _showSnack(
          'تعذّرت مشاركة النتيجة على هذا الجهاز', const Color(0xFFDC2626));
    }
  }

  void _showExitDialog() {
    final c = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: c.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: c.danger.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child:
                    Icon(Icons.pause_circle_rounded, color: c.danger, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                'هل ترغب في التوقف مؤقتاً؟',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'لا تقلق! إجاباتك محفوظة بأمان (${_answers.length}/$_totalQuestions)، ويمكنك العودة لإكمال التقييم في أي وقت.',
                style: TextStyle(
                  fontSize: 13,
                  color: c.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('متابعة التقييم'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: c.textSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('حفظ وخروج'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: color,
          content: Text(msg,
              style: const TextStyle(color: Colors.white, fontSize: 13)),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: c.background,
        extendBodyBehindAppBar: true,
        body: _isLoading
            ? _buildLoading(c)
            : _questions.isEmpty
                ? _buildEmpty(c)
                : _state == _AssessmentState.analyzing
                    ? _buildAnalyzing(c)
                    : _state == _AssessmentState.results
                        ? _buildResults(c)
                        : _buildQuestionFlow(c),
      ),
    );
  }

  // ─── Loading / Empty ─────────────────────────────────────────────────────

  Widget _buildLoading(AppColors c) {
    return Stack(
      children: [
        _gradientBg(c),
        const Center(
          child: CircularProgressIndicator(color: Color(0xFF2A14B4)),
        ),
      ],
    );
  }

  Widget _buildEmpty(AppColors c) {
    return Stack(
      children: [
        _gradientBg(c),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.quiz_outlined, size: 64, color: c.textSecondary),
                const SizedBox(height: 16),
                Text('لا توجد أسئلة حالياً',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary)),
                const SizedBox(height: 8),
                Text(_errorMessage ?? 'يرجى المحاولة مرة أخرى',
                    style: TextStyle(fontSize: 14, color: c.textSecondary),
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadQuestions,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('إعادة المحاولة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Gradient BG ─────────────────────────────────────────────────────────

  Widget _gradientBg(AppColors c) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 200,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              c.primarySoft.withValues(alpha: 0.4),
              c.background,
            ],
          ),
        ),
      ),
    );
  }

  // ─── Custom AppBar ───────────────────────────────────────────────────────

  Widget _buildHeader(AppColors c) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
            16, MediaQuery.of(context).padding.top + 8, 16, 0),
        color: c.background.withValues(alpha: 0.85),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: c.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: c.primary.withValues(alpha: 0.06),
                        blurRadius: 8),
                  ],
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    color: c.textPrimary, size: 20),
              ),
            ),
            const Spacer(),
            Column(
              children: [
                Text(
                  'التقييم الذكي',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.cloud_done_rounded, color: c.primary, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'حفظ تلقائي للمحاولات',
                      style: TextStyle(fontSize: 10, color: c.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: _showExitDialog,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: c.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: c.primary.withValues(alpha: 0.06),
                        blurRadius: 8),
                  ],
                ),
                child:
                    Icon(Icons.close_rounded, color: c.textSecondary, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Question Flow ───────────────────────────────────────────────────────

  Widget _buildQuestionFlow(AppColors c) {
    final q = _questions[_currentQuestionIndex];
    final dim = q['dimension'] ?? 'programming';
    final selected = _answers[_currentQuestionIndex];

    return Stack(
      children: [
        _gradientBg(c),
        _buildHeader(c),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 72, 16, 24),
            child: Column(
              children: [
                _buildProgressCard(c, dim),
                const SizedBox(height: 16),
                Expanded(
                  child: FadeTransition(
                    opacity: _questionFade,
                    child: SlideTransition(
                      position: _questionSlide,
                      child: _buildQuestionCard(c, q, dim, selected),
                    ),
                  ),
                ),
                _buildNavButtons(c),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Progress Card ───────────────────────────────────────────────────────

  Widget _buildProgressCard(AppColors c, String dim) {
    final pct = (_progress * 100).toInt();
    final remaining = _totalQuestions - _answers.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: c.primary.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: c.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.quiz_rounded, color: c.primary, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'السؤال ${_currentQuestionIndex + 1} من $_totalQuestions',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: c.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (remaining > 0)
                Text(
                  'متبقي $remaining',
                  style: TextStyle(fontSize: 11, color: c.textSecondary),
                ),
              const Spacer(),
              Text(
                '$pct%',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: c.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 8,
                backgroundColor: c.surfaceAlt,
                valueColor: AlwaysStoppedAnimation(c.primary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    color: _dimColor(dim, c), shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                _dimName(dim),
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _dimColor(dim, c)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Question Card ───────────────────────────────────────────────────────

  Widget _buildQuestionCard(
      AppColors c, Map<String, dynamic> q, String dim, int? selected) {
    final dimLabel = _dimName(dim);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: c.primary.withValues(alpha: 0.04),
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _dimColor(dim, c).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_dimMaterialIcon(dim),
                    color: _dimColor(dim, c), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dimLabel,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _dimColor(dim, c)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      q['question_text'] ?? '',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary,
                          height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _likertScale(c, selected),
        ],
      ),
    );
  }

  // ─── Likert Scale ────────────────────────────────────────────────────────

  Widget _likertScale(AppColors c, int? selected) {
    const labels = [
      'أبداً / لا ينطبق عليّ',
      'قليلاً / نادراً',
      'بشكل متوسط / محايد',
      'كثيراً / غالباً',
      'جداً / يمثل شغفي',
    ];

    return Column(
      children: List.generate(5, (i) {
        final value = i + 1;
        final isSelected = selected == value;
        return GestureDetector(
          onTap: () => _selectAnswer(_currentQuestionIndex, value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? c.primary.withValues(alpha: 0.06)
                  : c.surfaceAlt.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? c.primary : c.divider,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                          color: c.primary.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 4))
                    ]
                  : [],
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: isSelected ? 28 : 24,
                  height: isSelected ? 28 : 24,
                  decoration: BoxDecoration(
                    color: isSelected ? c.primary : c.surfaceAlt,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? c.primary : c.divider,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 16)
                      : Center(
                          child: Text(
                            '$value',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: c.textSecondary),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? c.primary : c.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ─── Nav Buttons ─────────────────────────────────────────────────────────

  Widget _buildNavButtons(AppColors c) {
    final isLast = _currentQuestionIndex == _totalQuestions - 1;
    final hasAnswer = _answers.containsKey(_currentQuestionIndex);

    return Column(
      children: [
        Row(
          children: [
            if (_currentQuestionIndex > 0)
              GestureDetector(
                onTap: _goPrev,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: c.surfaceAlt,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_forward_rounded,
                          color: c.textSecondary, size: 18),
                      const SizedBox(width: 6),
                      Text('السابق',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: c.textPrimary)),
                    ],
                  ),
                ),
              ),
            if (_currentQuestionIndex > 0) const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: hasAnswer ? _goNext : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: hasAnswer
                        ? LinearGradient(
                            colors: [c.primary, c.primaryContainer])
                        : null,
                    color: hasAnswer ? null : c.surfaceAlt,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: hasAnswer
                        ? [
                            BoxShadow(
                                color: c.primary.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6))
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      isLast ? 'إرسال التقييم' : 'التالي',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: hasAnswer ? Colors.white : c.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bolt_rounded, color: c.purple, size: 14),
            const SizedBox(width: 4),
            Text(
              'يتم الانتقال تلقائياً بمجرد اختيار الدرجة',
              style: TextStyle(fontSize: 11, color: c.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  // ─── AI Analyzing Screen ─────────────────────────────────────────────────

  Widget _buildAnalyzing(AppColors c) {
    return Stack(
      children: [
        _gradientBg(c),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _analyzingController,
                        builder: (_, __) => Transform.rotate(
                          angle: _analyzingController.value * 2 * pi,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: c.primary.withValues(alpha: 0.15),
                                  width: 3),
                            ),
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _analyzingController,
                        builder: (_, __) => Transform.rotate(
                          angle: -_analyzingController.value * 2 * pi,
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: c.purple.withValues(alpha: 0.1),
                                  width: 3),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: c.primaryContainer,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: c.primary.withValues(alpha: 0.3),
                                blurRadius: 20)
                          ],
                        ),
                        child: Icon(Icons.psychology_rounded,
                            color: Colors.white, size: 36),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: c.primarySoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'محرك NextStep AI',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: c.primary),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'جاري تحليل إجاباتك بالذكاء الاصطناعي...',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'يتم احتساب النتائج محلياً على هذا الجهاز عبر 6 أبعاد تحليلية',
                  style: TextStyle(fontSize: 13, color: c.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _analyzingStep(c, Icons.check_circle_rounded,
                    'فحص المهارات التحليلية', '100%', c.primary, false),
                const SizedBox(height: 12),
                _analyzingStep(c, Icons.sync_rounded, 'ربط التفضيلات بالتخصصات',
                    '84%', c.purple, true),
                const SizedBox(height: 12),
                _analyzingStep(c, Icons.hourglass_empty_rounded,
                    'توليد الخلاصة والنتائج', '...', c.textSecondary, false),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _analyzingStep(AppColors c, IconData icon, String text, String pct,
      Color color, bool spinning) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: c.primary.withValues(alpha: 0.04), blurRadius: 8)
        ],
      ),
      child: Row(
        children: [
          spinning
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child:
                      CircularProgressIndicator(strokeWidth: 2, color: color),
                )
              : Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: c.textPrimary)),
          ),
          Text(pct,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  // ─── Results Screen ──────────────────────────────────────────────────────

  Widget _buildResults(AppColors c) {
    final sorted = _dimensions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3 = sorted.take(3).toList();

    return Stack(
      children: [
        _gradientBg(c),
        SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _celebrationBanner(c, top3),
                      const SizedBox(height: 16),
                      _topDimensionsCard(c, top3),
                      const SizedBox(height: 16),
                      _radarCard(c),
                      const SizedBox(height: 16),
                      _suggestedMajors(c),
                      const SizedBox(height: 16),
                      _resultActions(c),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_confettiController.isAnimating)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _confettiController,
                builder: (_, __) => CustomPaint(
                  painter: _ConfettiPainter(_confettiController.value),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _celebrationBanner(AppColors c, List<MapEntry<String, double>> top3) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [c.primaryContainer, c.primary, c.purple],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: c.primary.withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_rounded,
                color: Colors.white, size: 32),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'اكتمل التحليل بنجاح 🎉',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'تهانينا! 🎉',
            style: TextStyle(
                color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'أكملت التقييم الذكي بنجاح',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _topDimensionsCard(AppColors c, List<MapEntry<String, double>> top3) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: c.primary.withValues(alpha: 0.04), blurRadius: 12)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stars_rounded, color: c.primary, size: 20),
              const SizedBox(width: 6),
              Text('أبرز أبعادك',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary)),
              const Spacer(),
              Text('بناءً على ${_totalQuestions} مؤشر',
                  style: TextStyle(fontSize: 11, color: c.textSecondary)),
            ],
          ),
          const SizedBox(height: 16),
          ...top3.asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final e = entry.value;
            final color = rank == 1
                ? c.primary
                : rank == 2
                    ? c.purple
                    : c.textSecondary;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text('$rank',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_dimName(e.key),
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: c.textPrimary)),
                        Text(_dimIcon(e.key),
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  Text('${e.value.toInt()}%',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: color)),
                  const SizedBox(width: 4),
                  Icon(Icons.trending_up_rounded, color: color, size: 18),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _radarCard(AppColors c) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: c.primary.withValues(alpha: 0.04), blurRadius: 12)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('مخطط الكفاءات',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: c.primarySoft,
                    borderRadius: BorderRadius.circular(8)),
                child: Text('NextStep AI',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: c.primary)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: CustomPaint(
              size: const Size(double.infinity, 260),
              painter: _RadarChartPainter(_dimensions, c),
            ),
          ),
        ],
      ),
    );
  }

  Widget _suggestedMajors(AppColors c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: c.primary.withValues(alpha: 0.04), blurRadius: 12)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school_rounded, color: c.primary, size: 20),
              const SizedBox(width: 6),
              Text('أعلى التخصصات المقترحة',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary)),
            ],
          ),
          const SizedBox(height: 14),
          _majorChip(c, '98%', 'علوم الحاسب والذكاء الاصطناعي',
              'جامعة الملك سعود', c.primary),
          const SizedBox(height: 8),
          _majorChip(c, '94%', 'هندسة البرمجيات والأمن السيبراني',
              'جامعة الملك فهد', c.purple),
        ],
      ),
    );
  }

  Widget _majorChip(
      AppColors c, String pct, String title, String uni, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surfaceAlt.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(pct,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary)),
                Text(uni,
                    style: TextStyle(fontSize: 11, color: c.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultActions(AppColors c) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => context.push('/student/recommendations'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [c.primary, c.primaryContainer]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: c.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6))
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.rocket_launch_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'عرض التوصيات المناسبة',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _restartAssessment,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: c.surfaceAlt,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.replay_rounded,
                          color: c.textPrimary, size: 18),
                      const SizedBox(width: 6),
                      Text('إعادة التقييم',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: c.textPrimary)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: _shareResults,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: c.surfaceAlt,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.share_rounded, color: c.textPrimary, size: 18),
                      const SizedBox(width: 6),
                      Text('مشاركة النتيجة',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: c.textPrimary)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '✓ تم حفظ النتائج على هذا الجهاز',
          style: TextStyle(fontSize: 11, color: c.textSecondary),
        ),
      ],
    );
  }
}

// ─── Radar Chart Painter ─────────────────────────────────────────────────────

class _RadarChartPainter extends CustomPainter {
  final Map<String, double> dimensions;
  final AppColors c;

  _RadarChartPainter(this.dimensions, this.c);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = min(cx, cy) - 30;

    final keys = [
      'programming',
      'math',
      'communication',
      'management',
      'practical',
      'research'
    ];
    final labels = [
      'البرمجة',
      'الرياضيات',
      'التواصل',
      'الإدارة',
      'العملي',
      'البحث العلمي'
    ];
    final angles = List.generate(6, (i) => (pi / 3) * i - pi / 2);

    // Draw web
    final webPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int level = 1; level <= 4; level++) {
      final r = radius * level / 4;
      webPaint.color = c.divider.withValues(alpha: 0.5);
      final path = Path();
      for (int i = 0; i < 6; i++) {
        final x = cx + r * cos(angles[i]);
        final y = cy + r * sin(angles[i]);
        i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, webPaint);
    }

    // Draw axes
    final axisPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = c.divider.withValues(alpha: 0.3);
    for (int i = 0; i < 6; i++) {
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + radius * cos(angles[i]), cy + radius * sin(angles[i])),
        axisPaint,
      );
    }

    // Draw data polygon
    final dataPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = c.primary.withValues(alpha: 0.2);
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = c.primary;

    final dataPath = Path();
    for (int i = 0; i < 6; i++) {
      final val = (dimensions[keys[i]] ?? 50) / 100;
      final x = cx + radius * val * cos(angles[i]);
      final y = cy + radius * val * sin(angles[i]);
      i == 0 ? dataPath.moveTo(x, y) : dataPath.lineTo(x, y);
    }
    dataPath.close();
    canvas.drawPath(dataPath, dataPaint);
    canvas.drawPath(dataPath, strokePaint);

    // Draw data points
    final dotPaint = Paint()..color = c.primary;
    for (int i = 0; i < 6; i++) {
      final val = (dimensions[keys[i]] ?? 50) / 100;
      final x = cx + radius * val * cos(angles[i]);
      final y = cy + radius * val * sin(angles[i]);
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }

    // Draw labels
    final labelPainter = TextPainter(textDirection: TextDirection.rtl);
    for (int i = 0; i < 6; i++) {
      final val = (dimensions[keys[i]] ?? 50).toInt();
      final x = cx + (radius + 22) * cos(angles[i]);
      final y = cy + (radius + 22) * sin(angles[i]);

      labelPainter.text = TextSpan(
        text: '$labels[i] ($val%)',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: c.textPrimary,
          fontFamily: 'Cairo',
        ),
      );
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset(x - labelPainter.width / 2, y - labelPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter old) => true;
}

// ─── Confetti Painter ────────────────────────────────────────────────────────

class _ConfettiPainter extends CustomPainter {
  final double progress;
  _ConfettiPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42);
    final colors = [
      const Color(0xFF2A14B4),
      const Color(0xFF4338CA),
      const Color(0xFF4953BC),
      const Color(0xFF4CD7F6),
      const Color(0xFFE3DFFF),
    ];

    for (int i = 0; i < 60; i++) {
      final x = rng.nextDouble() * size.width;
      final startY = -20.0 + rng.nextDouble() * size.height * 0.3;
      final y = startY + progress * (size.height + 40);
      final r = 2.0 + rng.nextDouble() * 4;
      final color = colors[rng.nextInt(colors.length)];

      final paint = Paint()
        ..color = color.withValues(alpha: (1 - progress).clamp(0.0, 1.0));
      canvas.drawRect(
          Rect.fromCenter(center: Offset(x, y), width: r * 2, height: r),
          paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) =>
      old.progress != progress;
}
