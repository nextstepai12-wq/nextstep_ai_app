
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/core/helpers/hive_storage.dart';
import 'package:nextstep_ai_app/core/networking/supabase_service.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

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

  double _progress = 0.0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<Map<String, dynamic>> _getDefaultQuestions() {
    return [
      {
        'id': 1,
        'question_text': 'هل تستمتع بحل المشاكل المنطقية والمعادلات الرياضية؟',
        'dimension': 'math',
        'options': ['نعم جداً', 'أحياناً', 'لا أبداً'],
      },
      {
        'id': 2,
        'question_text': 'هل تهتم بمعرفة كيفية عمل البرامج والتطبيقات؟',
        'dimension': 'programming',
        'options': ['نعم جداً', 'أحياناً', 'لا أبداً'],
      },
      {
        'id': 3,
        'question_text': 'هل تفضل العمل في فريق أم بشكل فردي؟',
        'dimension': 'communication',
        'options': ['فريق دائماً', 'مزيج', 'فردي دائماً'],
      },
      {
        'id': 4,
        'question_text': 'هل تستمع بتجربة الأشياء عملياً بدلاً من القراءة النظرية؟',
        'dimension': 'practical',
        'options': ['نعم جداً', 'أحياناً', 'لا أبداً'],
      },
      {
        'id': 5,
        'question_text': 'هل لديك فضول لاستكشاف مواضيع جديدة خارج مجال دراستك؟',
        'dimension': 'research',
        'options': ['نعم جداً', 'أحياناً', 'لا أبداً'],
      },
      {
        'id': 6,
        'question_text': 'هل تجد نفسك تنظّم المهام وتقود الآخرين؟',
        'dimension': 'management',
        'options': ['نعم جداً', 'أحياناً', 'لا أبداً'],
      },
    ];
  }

  String _getDimensionName(String key) {
    switch (key) {
      case 'programming':
        return 'برمجة';
      case 'math':
        return 'رياضيات';
      case 'communication':
        return 'تواصل';
      case 'research':
        return 'بحث علمي';
      case 'practical':
        return 'عملي';
      case 'management':
        return 'إدارة';
      default:
        return key;
    }
  }

  String _getDimensionIcon(String key) {
    switch (key) {
      case 'programming':
        return '💻';
      case 'math':
        return '📐';
      case 'communication':
        return '🗣️';
      case 'research':
        return '🔬';
      case 'practical':
        return '🔧';
      case 'management':
        return '📊';
      default:
        return '📌';
    }
  }

  void _updateProgress() {
    if (_totalQuestions > 0) {
      _progress = _answers.length / _totalQuestions;
    } else {
      _progress = 0.0;
    }
  }

  void _debugPrintQuestions() {
    for (int i = 0; i < _questions.length; i++) {
    }
  }

  void _selectAnswer(int questionIndex, int optionIndex) {
    setState(() {
      _answers[questionIndex] = optionIndex;
      _updateProgress();
    });

    HiveStorage.saveData('assessment_cache', 'answers', _answers);

    if (_currentQuestionIndex < _totalQuestions - 1) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          setState(() {
            _currentQuestionIndex++;
          });
        }
      });
    }
  }

  void _calculateResults() {
    final Map<String, List<int>> dimensionAnswers = {};

    for (int i = 0; i < _questions.length; i++) {
      if (_answers.containsKey(i)) {
        final dimension = _questions[i]['dimension'] ?? 'general';
        final answer = _answers[i]!;
        final maxOptions = (_questions[i]['options'] as List).length;
        final score = maxOptions > 1 ? (answer / (maxOptions - 1)) * 100 : 50;

        if (!dimensionAnswers.containsKey(dimension)) {
          dimensionAnswers[dimension] = [];
        }
        dimensionAnswers[dimension]!.add(score.toInt());
      }
    }

    final Map<String, double> results = {};
    for (var entry in dimensionAnswers.entries) {
      final scores = entry.value;
      final average = scores.reduce((a, b) => a + b) / scores.length;
      results[entry.key] = average;
    }

    setState(() {
      _dimensions.updateAll((key, value) => results[key] ?? 50.0);
    });

  }

  Future<void> _loadSavedAnswers() async {
    try {
      final saved = await HiveStorage.getData('assessment_cache', 'answers');
      if (saved != null) {
        _answers = Map<int, int>.from(saved);
        _updateProgress();
      }
    } catch (_) {}
  }

  Future<void> _loadQuestions() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {

      try {
        final cached = await HiveStorage.getData('assessment_cache', 'questions');
        if (cached != null && (cached as List).isNotEmpty) {
          _questions = List<Map<String, dynamic>>.from(cached);
          _totalQuestions = _questions.length;
          await _loadSavedAnswers();

          if (mounted) {
            setState(() {
              _isLoading = false;
              _updateProgress();
              _errorMessage = null;
            });
            _debugPrintQuestions();
            return;
          }
        }
      } catch (e) {
      }

      final supabase = SupabaseService();
      final response = await supabase.client
          .from('survey_questions')
          .select('*')
          .eq('is_active', true)
          .order('order_index')
          .timeout(const Duration(seconds: 10));

      if (response != null && response.isNotEmpty) {
        final questions = List<Map<String, dynamic>>.from(response);

        _questions = questions.map((q) {
          List<String> options = ['نعم جداً', 'أحياناً', 'لا أبداً'];

          if (q['options'] != null) {
            if (q['options'] is List) {
              options = List<String>.from(q['options']);
            } else if (q['options'] is String) {
              try {
                final parsed = q['options'] as String;
                if (parsed.startsWith('[')) {
                  final List<dynamic> parsedList = jsonDecode(parsed);
                  options = parsedList.map((e) => e.toString()).toList();
                } else {
                  options = parsed.split(',').map((s) => s.trim()).toList();
                }
              } catch (_) {
                options = ['نعم جداً', 'أحياناً', 'لا أبداً'];
              }
            }
          }

          if (options.isEmpty) {
            options = ['نعم جداً', 'أحياناً', 'لا أبداً'];
          }

          String dimension = 'general';
          if (q['interest_id'] != null) {
            dimension = 'interest';
          } else if (q['type'] != null) {
            dimension = q['type'].toString();
          }

          return {
            'id': q['id'],
            'question_text': q['question_text'] ?? 'سؤال',
            'dimension': dimension,
            'options': options,
            'order_index': q['order_index'] ?? 0,
          };
        }).toList();

        _totalQuestions = _questions.length;

        try {
          await HiveStorage.saveData('assessment_cache', 'questions', _questions);
        } catch (e) {
        }

        await _loadSavedAnswers();

        if (mounted) {
          setState(() {
            _isLoading = false;
            _updateProgress();
            _errorMessage = null;
          });
          _debugPrintQuestions();
        }
      } else {
        _questions = _getDefaultQuestions();
        _totalQuestions = _questions.length;

        try {
          await HiveStorage.saveData('assessment_cache', 'questions', _questions);
        } catch (_) {}

        if (mounted) {
          setState(() {
            _isLoading = false;
            _updateProgress();
            _errorMessage = 'لا توجد أسئلة - عرض أسئلة افتراضية';
          });
          _debugPrintQuestions();
        }
      }
    } catch (e) {

      _questions = _getDefaultQuestions();
      _totalQuestions = _questions.length;

      if (mounted) {
        setState(() {
          _isLoading = false;
          _updateProgress();
          _errorMessage = 'فشل تحميل الأسئلة - عرض أسئلة افتراضية';
        });
        _debugPrintQuestions();
      }
    }
  }

  Future<void> _submitAssessment() async {
    if (_answers.length < _totalQuestions) {
      _showSnackBar(
        '⚠️ الرجاء الإجابة على جميع الأسئلة (${_answers.length}/$_totalQuestions)',
        Colors.orange,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      _calculateResults();

      await HiveStorage.saveData('assessment_cache', 'results', _dimensions);

      final supabase = SupabaseService();
      final user = supabase.currentUser;

      if (user != null) {
        await supabase.client.from('student_profiles').upsert({
          'user_id': user.id,
          'assessment_results': _dimensions,
          'completed_at': DateTime.now().toIso8601String(),
        });
      }

      await HiveStorage.saveData('assessment_cache', 'completed', true);

      _showSnackBar('✅ تم إكمال التقييم بنجاح!', Colors.green);

      context.pushReplacement('/student/recommendations');
    } catch (e) {
      _showSnackBar('❌ خطأ: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

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

    _loadQuestions();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildBody() {

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    if (_questions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.quiz_outlined, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'لا توجد أسئلة حالياً',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryContainer,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'يرجى المحاولة مرة أخرى',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadQuestions,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildProgressBar(),
        Expanded(
          child: _currentQuestionIndex < _totalQuestions
              ? _buildQuestionCard()
              : _buildResultsCard(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'التقييم الذكي',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryContainer,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.primaryContainer),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'التقدم',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '${(_progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'السؤال ${_currentQuestionIndex + 1} من $_totalQuestions',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) {
      return const Center(
        child: Text('لا توجد أسئلة'),
      );
    }

    final question = _questions[_currentQuestionIndex];
    final options = List<String>.from(question['options'] ?? ['نعم جداً', 'أحياناً', 'لا أبداً']);
    final selectedIndex = _answers[_currentQuestionIndex];

    final dimension = question['dimension'] ?? 'general';
    final dimensionIcon = _getDimensionIcon(dimension);
    final dimensionName = _getDimensionName(dimension);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'السؤال ${_currentQuestionIndex + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$dimensionIcon $dimensionName',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question['question_text'] ?? 'سؤال',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryContainer,
                  ),
                ),
                const SizedBox(height: 20),
                ...options.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  final isSelected = selectedIndex == index;

                  return GestureDetector(
                    onTap: () => _selectAnswer(_currentQuestionIndex, index),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary.withValues(alpha: 0.08)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppTheme.primary : Colors.grey.shade200,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primary : Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: isSelected
                                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                                  : Text(
                                      String.fromCharCode(65 + index),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected ? AppTheme.primary : AppTheme.primaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (_currentQuestionIndex > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _currentQuestionIndex--;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryContainer,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('السابق'),
                  ),
                ),
              if (_currentQuestionIndex > 0) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _currentQuestionIndex == _totalQuestions - 1
                      ? _submitAssessment
                      : () {
                          if (_answers.containsKey(_currentQuestionIndex)) {
                            setState(() {
                              _currentQuestionIndex++;
                            });
                          } else {
                            _showSnackBar('⚠️ الرجاء اختيار إجابة', Colors.orange);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    _currentQuestionIndex == _totalQuestions - 1
                        ? 'إرسال التقييم'
                        : 'التالي',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsCard() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primary, AppTheme.primaryContainer],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                const Text(
                  '🎉 تهانينا!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'لقد أكملت التقييم الذكي بنجاح',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'نتائج التقييم (الأبعاد الستة)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryContainer,
            ),
          ),
          const SizedBox(height: 12),
          ..._dimensions.keys.map((key) {
            final value = _dimensions[key] ?? 0;
            final name = _getDimensionName(key);
            final icon = _getDimensionIcon(key);
            final color = value >= 70
                ? Colors.green
                : value >= 40
                    ? Colors.orange
                    : Colors.red;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200, width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$icon $name',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryContainer,
                        ),
                      ),
                      Text(
                        '${value.toInt()}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: value / 100,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      color: color,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitAssessment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'عرض التوصيات',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: color,
          content: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}
