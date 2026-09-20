import 'package:flutter/material.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildHeroSection(),
              const SizedBox(height: 28),
              _buildSectionsList(),
              const SizedBox(height: 32),
              _buildActionButtons(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

PreferredSizeWidget _buildAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    leading: const SizedBox.shrink(),
    actions: [
      Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_forward_rounded,
            color: AppTheme.primaryContainer,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
          splashRadius: 24,
        ),
      ),
    ],
    title: const Text(
      'الشروط والأحكام',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppTheme.primaryContainer,
        letterSpacing: -0.5,
      ),
    ),
    centerTitle: true,
  );
}

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppTheme.primary.withValues(alpha: 0.06),
            AppTheme.primaryContainer.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.08),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primary,
                  AppTheme.primaryContainer,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.25),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.gavel_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'الشروط والأحكام',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryContainer,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.update_rounded,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'آخر تحديث: 10 أغسطس 2026',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
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

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryContainer.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppTheme.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'مرحباً بك في NextStep AI',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'باستخدامك لهذه المنصة، فإنك توافق على الالتزام بالشروط والأحكام التالية. '
            'يرجى قراءة هذه الشروط بعناية قبل استخدام المنصة.\n\n'
            'NextStep AI هي منصة ذكية للإرشاد الأكاديمي والمهني تهدف إلى مساعدة الطلاب '
            'في اختيار مساراتهم الأكاديمية والمهنية باستخدام الذكاء الاصطناعي.',
            style: TextStyle(
              fontSize: 14,
              height: 1.8,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionsList() {
    return Column(
      children: [
        _buildSection(
          title: 'الحساب والتسجيل',
          icon: Icons.account_circle_outlined,
          iconColor: Colors.blue.shade600,
          items: const [
            'يجب أن تكون المعلومات التي تقدمها عند التسجيل صحيحة وكاملة.',
            'أنت المسؤول عن الحفاظ على سرية بيانات حسابك وكلمة المرور.',
            'يحق لـ NextStep AI تعليق أو إنهاء حسابك في حال مخالفة هذه الشروط.',
            'يجب أن يكون عمرك 16 عاماً على الأقل لاستخدام المنصة.',
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: 'البيانات والخصوصية',
          icon: Icons.privacy_tip_outlined,
          iconColor: Colors.purple.shade600,
          items: const [
            'نقوم بجمع البيانات التي تقدمها لتقديم توصيات دقيقة ومخصصة.',
            'لا نشارك بياناتك الشخصية مع أطراف ثالثة دون موافقتك.',
            'يمكنك طلب حذف بياناتك في أي وقت عن طريق التواصل معنا.',
            'نستخدم تقنيات تشفير متقدمة لحماية بياناتك.',
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: 'المحتوى والملكية الفكرية',
          icon: Icons.copyright_outlined,
          iconColor: Colors.teal.shade600,
          items: const [
            'جميع المحتويات على المنصة محمية بحقوق الملكية الفكرية.',
            'يُمنع نسخ أو توزيع أي محتوى دون إذن صريح.',
            'التوصيات المقدمة هي لأغراض إرشادية وليست ملزمة.',
            'قد تختلف دقة التوصيات بناءً على دقة البيانات المدخلة.',
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: 'إخلاء المسؤولية',
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.orange.shade700,
          items: const [
            'المنصة تقدم توصيات بناءً على تحليل البيانات، وهي ليست بديلاً عن الاستشارة المهنية.',
            'NextStep AI ليست مسؤولة عن أي قرارات تتخذها بناءً على التوصيات.',
            'لا نضمن دقة المعلومات المقدمة من قبل الجامعات والمؤسسات التعليمية.',
            'استخدام المنصة يكون على مسؤوليتك الشخصية.',
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: 'التعديلات على الشروط',
          icon: Icons.update_outlined,
          iconColor: Colors.indigo.shade600,
          items: const [
            'يحق لـ NextStep AI تعديل هذه الشروط في أي وقت.',
            'سيتم إعلامك بأي تغييرات جوهرية عبر البريد الإلكتروني.',
            'استمرارك في استخدام المنصة بعد التعديل يعني موافقتك على الشروط الجديدة.',
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: 'التواصل معنا',
          icon: Icons.email_outlined,
          iconColor: Colors.red.shade600,
          items: const [
            'إذا كان لديك أي أسئلة أو استفسارات حول هذه الشروط، يرجى التواصل معنا عبر البريد الإلكتروني:',
            '📧 nextstepai12@gmail.com',
          ],
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            spreadRadius: 2,
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
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryContainer,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: iconColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.6,
                          color: Colors.grey.shade700,
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

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              shadowColor: AppTheme.primary.withValues(alpha: 0.3),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 22,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Text(
                  'أوافق على الشروط والأحكام',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey.shade600,
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_forward_rounded,
                size: 18,
              ),
              SizedBox(width: 6),
              Text('الرجوع'),
            ],
          ),
        ),
      ],
    );
  }
}
