
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/training_center_drawer.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  int _selectedCategoryIndex = -1;
  int _expandedFaqIndex = -1;

  final List<Map<String, dynamic>> _helpCategories = [
    {
      'title': 'إدارة الحساب',
      'description': 'إعدادات الملف الشخصي، كلمات المرور، الصلاحيات.',
      'icon': Icons.person_rounded,
      'color': 0xFF2196F3,
      'articles': 12,
    },
    {
      'title': 'الدعم التقني',
      'description': 'مشاكل النظام، الأخطاء، توافق الأجهزة.',
      'icon': Icons.computer_rounded,
      'color': 0xFF00BCD4,
      'articles': 8,
    },
    {
      'title': 'الفواتير والدفع',
      'description': 'الاشتراكات، طرق الدفع، الفواتير الضريبية.',
      'icon': Icons.payments_rounded,
      'color': 0xFFF44336,
      'articles': 6,
    },
    {
      'title': 'إدارة الدورات',
      'description': 'إضافة المحتوى، شهادات الطلاب، التقييمات.',
      'icon': Icons.school_rounded,
      'color': 0xFF4CAF50,
      'articles': 10,
    },
  ];

  final List<Map<String, dynamic>> _faqs = [
    {
      'question': 'كيف يمكنني إضافة مدرب جديد إلى النظام؟',
      'answer': 'يمكنك إضافة مدرب جديد من خلال الذهاب إلى قسم "المدربون" ثم الضغط على زر "إضافة مدرب" وملء البيانات المطلوبة.',
      'category': 'إدارة الحساب',
    },
    {
      'question': 'ما هي طريقة تصدير تقارير الطلاب؟',
      'answer': 'يمكنك تصدير تقارير الطلاب بصيغة PDF أو Excel من خلال الذهاب إلى قسم "التقارير" واختيار التقرير المطلوب.',
      'category': 'التقارير والإحصائيات',
    },
    {
      'question': 'كيف يمكنني تغيير باقة الاشتراك؟',
      'answer': 'يمكنك تغيير باقة الاشتراك من خلال الذهاب إلى "الإعدادات" ثم "الاشتراكات" واختيار الباقة المناسبة.',
      'category': 'الفواتير والدفع',
    },
  ];

  final List<Map<String, dynamic>> _activeTickets = [
    {
      'id': '#1234',
      'title': 'مشكلة في تصدير التقارير',
      'status': 'قيد المعالجة',
      'statusColor': 0xFF2196F3,
      'time': 'منذ ساعتين',
    },
    {
      'id': '#1230',
      'title': 'تحديث بيانات المدرب',
      'status': 'بانتظار الرد',
      'statusColor': 0xFFFF9800,
      'time': 'منذ يوم واحد',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      drawer: const TrainingCenterDrawer(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded),
        onPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      title: Row(
        children: [
          Icon(
            Icons.help_rounded,
            color: Colors.blue.shade700,
            size: 22.sp,
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              'المساعدة والدعم',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                size: 22.sp,
              ),
              onPressed: () {
                context.push('/training-center/notifications');
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            Positioned(
              top: 2.h,
              right: 2.w,
              child: Container(
                width: 16.w,
                height: 16.h,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '3',
                    style: TextStyle(
                      fontSize: 8.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: 4.w),
        CircleAvatar(
          radius: 16.r,
          backgroundColor: Colors.grey.shade300,
          child: Icon(
            Icons.person,
            size: 18.sp,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(width: 4.w),
      ],
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.white.withValues(alpha: 0.92),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(),
          SizedBox(height: 16.h),
          _buildSearchBar(),
          SizedBox(height: 20.h),
          _buildSupportStats(),
          SizedBox(height: 20.h),
          _buildHelpCategories(),
          SizedBox(height: 20.h),
          _buildFAQs(),
          SizedBox(height: 20.h),
          _buildSupportSection(),
        ],
      ),
    );
  }

  Widget _buildPageHeader() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'كيف يمكننا مساعدتك؟',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'ابحث عن إجابات أو تواصل مع فريق الدعم',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'ابحث عن مقالات، أسئلة شائعة...',
                hintStyle: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade400,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.blue.shade700,
                  size: 20.sp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                });
              },
              icon: Icon(
                Icons.close_rounded,
                color: Colors.grey.shade400,
                size: 18.sp,
              ),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }

  Widget _buildSupportStats() {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          _buildStatItem('48', 'مقالات', Icons.article_rounded, Colors.blue.shade700),
          _buildStatDivider(),
          _buildStatItem('156', 'تذاكر محلولة', Icons.check_circle_rounded, Colors.green.shade700),
          _buildStatDivider(),
          _buildStatItem('2.5س', 'متوسط الرد', Icons.schedule_rounded, Colors.orange.shade700),
          _buildStatDivider(),
          _buildStatItem('94%', 'الرضا', Icons.star_rounded, Colors.amber.shade700),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 18.sp),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 8.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 30.h,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildHelpCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'مواضيع المساعدة',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'عرض الكل',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
            childAspectRatio: 1.0,
          ),
          itemCount: _helpCategories.length,
          itemBuilder: (context, index) {
            final category = _helpCategories[index];
            return _buildCategoryCard(category);
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    final color = Color(category['color']);
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم فتح: ${category['title']}'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                category['icon'],
                color: color,
                size: 20.sp,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category['title'],
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  category['description'],
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQs() {
    final filteredFaqs = _searchQuery.isEmpty
        ? _faqs
        : _faqs.where((faq) =>
            faq['question'].toString().contains(_searchQuery) ||
            faq['answer'].toString().contains(_searchQuery)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الأسئلة الشائعة',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'عرض الكل',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        if (filteredFaqs.isEmpty)
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                'لا توجد نتائج مطابقة',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          )
        else
          Column(
            children: filteredFaqs.asMap().entries.map((entry) {
              final index = entry.key;
              final faq = entry.value;
              return _buildFAQItem(faq, index);
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildFAQItem(Map<String, dynamic> faq, int index) {
    final isExpanded = _expandedFaqIndex == index;

    return Container(
      margin: EdgeInsets.only(bottom: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _expandedFaqIndex = isExpanded ? -1 : index;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Row(
                children: [
                  Icon(
                    Icons.help_outline_rounded,
                    color: Colors.blue.shade700,
                    size: 18.sp,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      faq['question'],
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: Colors.grey.shade500,
                    size: 20.sp,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10.r),
                  bottomRight: Radius.circular(10.r),
                ),
              ),
              child: Text(
                faq['answer'],
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildActiveTickets(),
        ),
        SizedBox(width: 10.w),
        Expanded(
          flex: 1,
          child: _buildContactSupport(),
        ),
      ],
    );
  }

  Widget _buildActiveTickets() {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'التذاكر النشطة',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  _activeTickets.length.toString(),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          if (_activeTickets.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Text(
                  'لا توجد تذاكر نشطة',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            )
          else
            Column(
              children: _activeTickets.map((ticket) {
                return _buildTicketItem(ticket);
              }).toList(),
            ),
          SizedBox(height: 8.h),
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                'عرض جميع التذاكر',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketItem(Map<String, dynamic> ticket) {
    final color = Color(ticket['statusColor']);

    return Container(
      padding: EdgeInsets.all(10.r),
      margin: EdgeInsets.only(bottom: 6.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: Colors.grey.shade600,
              size: 16.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${ticket['id']} - ${ticket['title']}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 4.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            ticket['status'],
                            style: TextStyle(
                              fontSize: 8.sp,
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      ticket['time'],
                      style: TextStyle(
                        fontSize: 8.sp,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSupport() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.indigo.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.headset_mic_rounded,
            color: Colors.white,
            size: 28.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            'الدعم المباشر',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'فريق الدعم متاح 24/7',
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showContactOptions();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue.shade700,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'تواصل مع الدعم',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'اختر طريقة التواصل',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 16.h),
              _buildContactOption(
                icon: Icons.chat_rounded,
                title: 'الدردشة المباشرة',
                color: Colors.blue.shade700,
              ),
              SizedBox(height: 8.h),
              _buildContactOption(
                icon: Icons.email_rounded,
                title: 'البريد الإلكتروني',
                color: Colors.green.shade700,
              ),
              SizedBox(height: 8.h),
              _buildContactOption(
                icon: Icons.phone_rounded,
                title: 'اتصال هاتفي',
                color: Colors.orange.shade700,
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'إلغاء',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade600,
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

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('جاري الاتصال عبر $title... 📞'),
            backgroundColor: Colors.blue.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: color,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey.shade400,
              size: 14.sp,
            ),
          ],
        ),
      ),
    );
  }
}
