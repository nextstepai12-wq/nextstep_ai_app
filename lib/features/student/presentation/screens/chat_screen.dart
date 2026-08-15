import 'package:flutter/material.dart';
import 'package:nextstep_ai_app/core/themes/app_theme.dart';
import 'package:nextstep_ai_app/shared/services/supabase/supabase_service.dart';
import 'package:nextstep_ai_app/shared/services/auth/token_manager.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SupabaseService _supabase = SupabaseService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool _isTyping = false;
  String _userName = '';

  // أسئلة مقترحة
  final List<String> _suggestedQuestions = [
    'ما هو أفضل تخصص يناسبني؟',
    'كيف أختار جامعتي؟',
    'ما هي مجالات العمل المستقبلية؟',
    'نصائح للنجاح في الدراسة الجامعية',
  ];

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final cachedData = await TokenManager.getUserData();
      if (cachedData['name'] != null && cachedData['name']!.isNotEmpty) {
        _userName = cachedData['name']!;
      }

      // ✅ جلب تاريخ المحادثة من قاعدة البيانات
      // TODO: استدعاء API لجلب المحادثات السابقة

      // رسائل ترحيبية
      _messages = [
        {
          'isUser': false,
          'message':
              'مرحباً $_userName! 👋\nأنا مساعدك الأكاديمي الذكي. اسألني أي شيء عن التخصصات، الجامعات، أو مسارك الأكاديمي.',
          'time': DateTime.now().subtract(const Duration(minutes: 5)),
        },
      ];

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // إضافة رسالة المستخدم
    setState(() {
      _messages.add({
        'isUser': true,
        'message': message.trim(),
        'time': DateTime.now(),
      });
      _messageController.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      // ✅ استدعاء AI API للحصول على الرد
      // TODO: استدعاء API للذكاء الاصطناعي
      await Future.delayed(const Duration(seconds: 1));

      final response = _getAIResponse(message.trim());

      setState(() {
        _messages.add({
          'isUser': false,
          'message': response,
          'time': DateTime.now(),
        });
        _isTyping = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add({
          'isUser': false,
          'message': 'عذراً، حدث خطأ. يرجى المحاولة مرة أخرى.',
          'time': DateTime.now(),
        });
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  String _getAIResponse(String message) {
    final msg = message.toLowerCase();

    if (msg.contains('تخصص') || msg.contains('مسار')) {
      return 'بناءً على اهتماماتك، أقترح عليك التخصصات التالية:\n\n'
          '📌 **هندسة الحاسوب** - مناسب لمحبي التكنولوجيا والبرمجة\n'
          '📌 **الذكاء الاصطناعي** - لمحبي الابتكار والتقنيات المستقبلية\n'
          '📌 **علوم البيانات** - لمحبي التحليل والإحصاء\n\n'
          'هل تريد معرفة المزيد عن أي منها؟';
    } else if (msg.contains('جامعة') || msg.contains('كلية')) {
      return 'من أفضل الجامعات في فلسطين:\n\n'
          '🏛️ **الجامعة الإسلامية** - غزة\n'
          '🏛️ **جامعة الأزهر** - غزة\n'
          '🏛️ **جامعة الأقصى** - غزة\n'
          '🏛️ **جامعة القدس** - القدس\n\n'
          'هل تريد معلومات عن تخصص معين في إحداها؟';
    } else if (msg.contains('عمل') || msg.contains('وظيفة') || msg.contains('مهنة')) {
      return 'من أهم مجالات العمل المستقبلية:\n\n'
          '💻 **تكنولوجيا المعلومات** - مطلوب بشدة\n'
          '🤖 **الذكاء الاصطناعي** - مستقبل واعد\n'
          '📊 **تحليل البيانات** - طلب متزايد\n'
          '⚕️ **الصحة** - مجال حيوي\n\n'
          'هل تريد معرفة المزيد عن مجال معين؟';
    } else if (msg.contains('دراسة') || msg.contains('جامعي') || msg.contains('نجاح')) {
      return 'نصائح للنجاح في الدراسة الجامعية:\n\n'
          '📚 **نظم وقتك** - ضع جدولاً دراسياً منتظماً\n'
          '👥 **شارك في الأنشطة** - طور مهاراتك الشخصية\n'
          '💡 **ابحث عن شغفك** - اختر تخصصاً تحبه\n'
          '🤝 **ابنِ علاقات** - تواصل مع زملائك وأساتذتك\n\n'
          'هل لديك استفسار محدد؟';
    } else {
      return 'شكراً لسؤالك! 🙏\n\n'
          'يمكنني مساعدتك في:\n'
          '• اختيار التخصص المناسب\n'
          '• معلومات عن الجامعات\n'
          '• مجالات العمل المستقبلية\n'
          '• نصائح للدراسة\n\n'
          'اطرح سؤالك بوضوح وسأجيبك بأفضل شكل.';
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

  void _sendSuggestedQuestion(String question) {
    _sendMessage(question);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: _buildAppBar(),
        body: Column(
          children: [
            // Messages Area
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primary,
                      ),
                    )
                  : _messages.isEmpty
                      ? _buildEmptyState()
                      : _buildMessagesList(),
            ),

            // Suggested Questions
            if (_messages.length <= 2 && !_isLoading)
              _buildSuggestedQuestions(),

            // Typing Indicator
            if (_isTyping) _buildTypingIndicator(),

            // Input Area
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primary, AppTheme.primaryContainer],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(Icons.chat_rounded, size: 20, color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'المساعد الأكاديمي',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryContainer,
            ),
          ),
        ],
      ),
      centerTitle: true,
leading: const SizedBox.shrink(),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: AppTheme.primaryContainer,
          ),
          onPressed: () {
            // TODO: حذف تاريخ المحادثة
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 40,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'مرحباً في المساعد الأكاديمي',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'اسألني أي شيء عن مسارك الأكاديمي',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      physics: const BouncingScrollPhysics(),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isUser = message['isUser'] as bool;
        final text = message['message'] as String;
        final time = message['time'] as DateTime;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isUser)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.primary, AppTheme.primaryContainer],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.smart_toy_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              if (!isUser) const SizedBox(width: 10),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isUser ? AppTheme.primary : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isUser ? 16 : 4),
                      topRight: Radius.circular(isUser ? 4 : 16),
                      bottomLeft: const Radius.circular(16),
                      bottomRight: const Radius.circular(16),
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
                        text,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: isUser ? Colors.white : AppTheme.primaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(time),
                        style: TextStyle(
                          fontSize: 10,
                          color: isUser
                              ? Colors.white.withValues(alpha: 0.6)
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isUser) const SizedBox(width: 10),
              if (isUser)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _userName.isNotEmpty ? _userName[0] : 'ط',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSuggestedQuestions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أسئلة مقترحة',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestedQuestions.map((question) {
              return GestureDetector(
                onTap: () => _sendSuggestedQuestion(question),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.2),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    question,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primary, AppTheme.primaryContainer],
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.smart_toy_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(Colors.grey.shade400),
                const SizedBox(width: 4),
                _buildDot(Colors.grey.shade500),
                const SizedBox(width: 4),
                _buildDot(Colors.grey.shade600),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.primaryContainer,
              ),
              decoration: InputDecoration(
                hintText: 'اكتب سؤالك هنا...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _sendMessage(_messageController.text),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primary, AppTheme.primaryContainer],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 22,
              ),
              onPressed: () => _sendMessage(_messageController.text),
              splashRadius: 24,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inDays < 1) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }
}