import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/core/helpers/token_manager.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  List<_ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isTyping = false;
  bool _showScrollToBottom = false;
  String _userName = '';

  late AnimationController _typingDotController;
  late AnimationController _onlineDotController;

  List<String> _currentSuggestions = [
    'ما هو أفضل تخصص يناسبني؟',
    'كيف أختار جامعتي؟',
    'ما هي مجالات العمل المستقبلية؟',
    'نصائح للنجاح في الدراسة الجامعية',
  ];

  @override
  void initState() {
    super.initState();
    _typingDotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _onlineDotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _scrollController.addListener(_onScroll);
    _loadChatHistory();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final atBottom = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 80;
    if (atBottom != _showScrollToBottom) {
      setState(() => _showScrollToBottom = atBottom);
    }
  }

  Future<void> _loadChatHistory() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final cachedData = await TokenManager.getUserData();
      if (cachedData['name'] != null && cachedData['name']!.isNotEmpty) {
        _userName = cachedData['name']!;
      }
    } catch (_) {}

    _messages = [
      _ChatMessage(
        isUser: false,
        text: _getWelcomeMessage(),
        time: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
    ];

    if (mounted) {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  String _getWelcomeMessage() {
    final name = _userName.isNotEmpty ? ' $_userName' : '';
    return 'مرحباً$name! 👋\nأنا مساعدك الأكاديمي الذكي من NextStep.\nيمكنني مساعدتك في اكتشاف التخصصات، اختيار الجامعات، والتخطيط لمسارك الأكاديمي.\n\nاسألني أي شيء وسأكون سعيداً بمساعدتك! 🎓';
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = _ChatMessage(
      isUser: true,
      text: text.trim(),
      time: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _messageController.clear();
      _isTyping = true;
    });
    _scrollToBottom();
    _updateSuggestions(text.trim());

    try {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      final response = _generateAIResponse(text.trim());

      setState(() {
        _messages.add(response);
        _isTyping = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(
          isUser: false,
          text: 'عذراً، حدث خطأ. يرجى المحاولة مرة أخرى.',
          time: DateTime.now(),
        ));
        _isTyping = false;
      });
    }
  }

  void _updateSuggestions(String lastUserMessage) {
    final msg = lastUserMessage.toLowerCase();
    List<String> newSuggestions;

    if (msg.contains('تخصص') || msg.contains('مسار')) {
      newSuggestions = [
        'أخبرني المزيد عن هندسة الحاسوب',
        'ما هو تخصص الذكاء الاصطناعي؟',
        'مقارنة بين تخصصات التقنية',
        'كيف أعرف تخصصي المناسب؟',
      ];
    } else if (msg.contains('جامعة') || msg.contains('كلية')) {
      newSuggestions = [
        'مقارنة الجامعات الفلسطينية',
        'شروط القبول في الجامعة الإسلامية',
        'أفضل جامعات للهندسة',
        'الفرق بين الجامعات الحكومية والخاصة',
      ];
    } else if (msg.contains('عمل') ||
        msg.contains('وظيفة') ||
        msg.contains('مستقبل')) {
      newSuggestions = [
        'مجالات العمل في الذكاء الاصطناعي',
        'أكثر الوظائف طلباً في المستقبل',
        'كيف أبدأ مسيرتي المهنية؟',
        'نصائح للتقديم على وظائف تقنية',
      ];
    } else if (msg.contains('دراسة') ||
        msg.contains('نصيحة') ||
        msg.contains('نجاح')) {
      newSuggestions = [
        'كيف أنظم وقتي بشكل أفضل؟',
        'نصائح للجامعة الأولى',
        'كيف أرفع معدلي الدراسي؟',
        'الجمع بين الدراسة والعمل',
      ];
    } else {
      newSuggestions = [
        'ما هو أفضل تخصص يناسبني؟',
        'كيف أختار جامعتي؟',
        'ما هي مجالات العمل المستقبلية؟',
        'نصائح للنجاح في الدراسة الجامعية',
      ];
    }

    setState(() => _currentSuggestions = newSuggestions);
  }

  _ChatMessage _generateAIResponse(String message) {
    final msg = message.toLowerCase();

    if (msg.contains('تخصص') || msg.contains('مسار')) {
      return _ChatMessage(
        isUser: false,
        text:
            'بناءً على اهتماماتك، أقترح عليك التخصصات التالية:\n\n📌 هندسة الحاسوب - مناسب لمحبي التكنولوجيا والبرمجة\n📌 الذكاء الاصطناعي - لمحبي الابتكار والتقنيات المستقبلية\n📌 علوم البيانات - لمحبي التحليل والإحصاء',
        time: DateTime.now(),
        majorMatch: _MajorMatch(
          title: 'هندسة الحاسوب',
          matchPercentage: 92,
          university: 'الجامعة الإسلامية - غزة',
          explanation:
              'بناءً على تحليل اهتماماتك وقدراتك، نوصي بتخصص هندسة الحاسوب لأنه يجمع بين البرمجة وحل المشكلات.',
        ),
      );
    } else if (msg.contains('جامعة') || msg.contains('كلية')) {
      return _ChatMessage(
        isUser: false,
        text:
            'من أفضل الجامعات في فلسطين:\n\n🏛️ الجامعة الإسلامية - غزة (الأعلى ترتيباً)\n🏛️ جامعة الأزهر - غزة (برامج قوية)\n🏛️ جامعة الأقصى - غزة\n🏛️ جامعة القدس - القدس\n\nهل تريد معلومات عن تخصص معين في إحداها؟',
        time: DateTime.now(),
      );
    } else if (msg.contains('عمل') ||
        msg.contains('وظيفة') ||
        msg.contains('مستقبل')) {
      return _ChatMessage(
        isUser: false,
        text:
            'من أهم مجالات العمل المستقبلية:\n\n💻 تكنولوجيا المعلومات - مطلوب بشدة\n🤖 الذكاء الاصطناعي - مستقبل واعد\n📊 تحليل البيانات - طلب متزايد\n🏥 الصحة الرقمية - مجال حيوي\n\nكل هذه المجالات تشهد نمواً متسارعاً في سوق العمل.',
        time: DateTime.now(),
      );
    } else if (msg.contains('دراسة') ||
        msg.contains('نصيحة') ||
        msg.contains('نجاح')) {
      return _ChatMessage(
        isUser: false,
        text:
            'نصائح للنجاح في الدراسة الجامعية:\n\n📚 نظم وقتك - ضع جدولاً دراسياً منتظماً\n👥 شارك في الأنشطة - طور مهاراتك الشخصية\n💡 ابحث عن شغفك - اختر تخصصاً تحبه\n🤝 ابنِ علاقات - تواصل مع زملائك وأساتذتك\n\nهل لديك استفسار محدد؟',
        time: DateTime.now(),
      );
    } else if (msg.contains('هندسة') || msg.contains('engineering')) {
      return _ChatMessage(
        isUser: false,
        text:
            'تخصص هندسة الحاسوب من أكثر التخصصات طلباً!\n\nالمدة الدراسية: 4 سنوات\nالمواد الأساسية: البرمجة، الدوائر الكهربائية، الخوارزميات، هياكل البيانات\n\nالوظائف المتاحة:\n• مهندس برمجيات\n• مهندس أجهزة\n• مطور تطبيقات\n• محلل أنظمة',
        time: DateTime.now(),
      );
    } else if (msg.contains('ذكاء') ||
        msg.contains('اصطناعي') ||
        msg.contains('ai')) {
      return _ChatMessage(
        isUser: false,
        text:
            'الذكاء الاصطناعي هو المستقبل! 🤖\n\nهذا التخصص يشمل:\n• التعلم الآلي\n• الشبكات العصبية معالجة اللغات الطبيعية\n• الرؤية الحاسوبية\n\nالطلب على خبراء AI في تزايد مستمر مع رواتب تنافسية.',
        time: DateTime.now(),
      );
    } else {
      return _ChatMessage(
        isUser: false,
        text:
            'شكراً لسؤالك! 🙏\n\nيمكنني مساعدتك في:\n• اختيار التخصص المناسب\n• معلومات عن الجامعات\n• مجالات العمل المستقبلية\n• نصائح للدراسة\n\nاطرح سؤالك بوضوح وسأجيبك بأفضل شكل.',
        time: DateTime.now(),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _typingDotController.dispose();
    _onlineDotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: c.background,
        body: Stack(
          children: [
            Positioned.fill(child: _buildAmbientBackground(c)),
            Column(
              children: [
                _buildHeader(c),
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(color: c.primary),
                        )
                      : _buildMessagesList(c),
                ),
                if (_messages.length <= 3 && !_isLoading)
                  _buildSuggestionChips(c),
                if (_isTyping) _buildTypingIndicator(c),
                _buildInputBar(c),
              ],
            ),
            if (_showScrollToBottom) _buildScrollToBottomFAB(c),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Ambient background
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildAmbientBackground(AppColors c) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _AmbientGlowPainter(c.primary.withValues(alpha: 0.04)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                c.primary.withValues(alpha: 0.03),
                c.background,
                c.background,
              ],
              stops: const [0.0, 0.3, 1.0],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Header
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildHeader(AppColors c) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: c.surface.withValues(alpha: 0.85),
          border: Border(
            bottom: BorderSide(
              color: c.divider.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // AI Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [c.gradientStart, c.gradientEnd],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: c.primary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 24,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Title + status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المساعد الأكاديمي',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      // Pulsing online dot
                      AnimatedBuilder(
                        animation: _onlineDotController,
                        builder: (_, __) {
                          final opacity =
                              0.5 + (_onlineDotController.value * 0.5);
                          final scale =
                              0.8 + (_onlineDotController.value * 0.2);
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: c.warning.withValues(alpha: opacity),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: c.warning
                                        .withValues(alpha: opacity * 0.4),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'نسخة تجريبية — ردود محلية',
                        style: TextStyle(
                          fontSize: 12,
                          color: c.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Action buttons
            _buildHeaderAction(
              c: c,
              icon: Icons.delete_outline_rounded,
              tooltip: 'مسح المحادثة',
              onTap: _confirmClearChat,
            ),
            const SizedBox(width: 8),
            _buildHeaderAction(
              c: c,
              icon: Icons.more_vert_rounded,
              tooltip: 'معلومات المحادثة',
              onTap: _showChatInfo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderAction({
    required AppColors c,
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: c.surfaceAlt,
        foregroundColor: c.textSecondary,
        minimumSize: const Size(42, 42),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      icon: Icon(icon, size: 20),
    );
  }

  Future<void> _confirmClearChat() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('مسح المحادثة؟'),
        content: const Text(
          'سيتم حذف الرسائل من هذه الجلسة فقط. لا توجد محادثة محفوظة على الخادم.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('مسح'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _messages = [
        _ChatMessage(
          isUser: false,
          text: _getWelcomeMessage(),
          time: DateTime.now(),
        ),
      ];
      _currentSuggestions = const [
        'ما هو أفضل تخصص يناسبني؟',
        'كيف أختار جامعتي؟',
        'ما هي مجالات العمل المستقبلية؟',
        'نصائح للنجاح في الدراسة الجامعية',
      ];
    });
  }

  void _showChatInfo() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'عن المساعد الأكاديمي',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8),
              Text(
                'هذه محادثة تجريبية تعمل بقواعد محلية ولا تتصل بخادم ذكاء '
                'اصطناعي. الردود محدودة ومخصصة للعرض فقط.',
                style: TextStyle(fontSize: 13, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Messages list
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildMessagesList(AppColors c) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      physics: const BouncingScrollPhysics(),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final showDatePill =
            index == 0 || !_isSameDay(_messages[index - 1].time, message.time);

        return Column(
          children: [
            if (showDatePill) _buildDatePill(message.time, c),
            if (message.isUser)
              _buildUserMessage(message, c)
            else
              _buildAIMessage(message, c),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Date pill
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildDatePill(DateTime time, AppColors c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: c.surfaceAlt,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _formatDate(time),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: c.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // AI message bubble
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildAIMessage(_ChatMessage message, AppColors c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI avatar
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [c.gradientStart, c.gradientEnd],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: c.primary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Message content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Message bubble
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(4),
                      topLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: c.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatTime(message.time),
                        style: TextStyle(
                          fontSize: 10,
                          color: c.textSecondary.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                // Major match card
                if (message.majorMatch != null) ...[
                  const SizedBox(height: 10),
                  _buildMajorMatchCard(message.majorMatch!, c),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // User message bubble
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildUserMessage(_ChatMessage message, AppColors c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [c.gradientStart, c.gradientEnd],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(4),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: c.primary.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.text,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(
                        _formatTime(message.time),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // User avatar
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: c.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _userName.isNotEmpty ? _userName[0] : 'ط',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: c.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Major match card
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildMajorMatchCard(_MajorMatch match, AppColors c) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            c.primary,
            c.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: c.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with match percentage
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Match circle
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${match.matchPercentage}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        match.university,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.verified_rounded,
                  size: 24,
                  color: c.success,
                ),
              ],
            ),
          ),
          // Explanation
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              match.explanation,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
          // Action button
          Padding(
            padding: const EdgeInsets.only(left: 14, right: 14, bottom: 14),
            child: GestureDetector(
              onTap: () => context.push('/student/recommendations'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'اعرف المزيد',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Typing indicator
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTypingIndicator(AppColors c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [c.gradientStart, c.gradientEnd],
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _typingDotController,
              builder: (_, __) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final delay = i * 0.33;
                    final value = (_typingDotController.value + delay) % 1.0;
                    final y = math.sin(value * math.pi) * 4;
                    return Transform.translate(
                      offset: Offset(0, -y),
                      child: Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.symmetric(horizontal: 2.5),
                        decoration: BoxDecoration(
                          color:
                              c.primary.withValues(alpha: 0.4 + (value * 0.6)),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Suggestion chips
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSuggestionChips(AppColors c) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _currentSuggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _sendMessage(_currentSuggestions[index]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: c.primary.withValues(alpha: 0.2),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: c.primary.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 14,
                    color: c.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _currentSuggestions[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: c.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Input bar (glassmorphism)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildInputBar(AppColors c) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: c.surface.withValues(alpha: 0.85),
        border: Border(
          top: BorderSide(
            color: c.divider.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: c.surfaceAlt,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 14,
                  color: c.textPrimary,
                ),
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'اسأل المساعد الأكاديمي...',
                  hintStyle: TextStyle(
                    color: c.textSecondary.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(_messageController.text),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Send button
          GestureDetector(
            onTap: () => _sendMessage(_messageController.text),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [c.gradientStart, c.gradientEnd],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: c.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Scroll to bottom FAB
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildScrollToBottomFAB(AppColors c) {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: _scrollToBottom,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: c.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: c.textSecondary,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} د';
    if (diff.inDays < 1) return 'منذ ${diff.inHours} س';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime time) {
    final now = DateTime.now();
    if (time.year == now.year &&
        time.month == now.month &&
        time.day == now.day) {
      return 'اليوم';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (time.year == yesterday.year &&
        time.month == yesterday.month &&
        time.day == yesterday.day) {
      return 'أمس';
    }
    return '${time.day}/${time.month}/${time.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────────────────

class _ChatMessage {
  final bool isUser;
  final String text;
  final DateTime time;
  final _MajorMatch? majorMatch;

  _ChatMessage({
    required this.isUser,
    required this.text,
    required this.time,
    this.majorMatch,
  });
}

class _MajorMatch {
  final String title;
  final int matchPercentage;
  final String university;
  final String explanation;

  _MajorMatch({
    required this.title,
    required this.matchPercentage,
    required this.university,
    required this.explanation,
  });
}

// ─────────────────────────────────────────────────────────────────────────
// Painters
// ─────────────────────────────────────────────────────────────────────────

class _AmbientGlowPainter extends CustomPainter {
  final Color color;
  _AmbientGlowPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.05),
      size.width * 0.4,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.15),
      size.width * 0.3,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _AmbientGlowPainter old) => old.color != color;
}
