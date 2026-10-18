import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/training_colors.dart';

enum RequestStatus { pending, accepted, rejected }

class RegistrationRequest {
  const RegistrationRequest({
    required this.name,
    required this.initials,
    required this.course,
    required this.time,
    required this.status,
    this.job = 'متدرب',
    this.attachment = false,
    this.verified = false,
    this.meta,
    this.rejectionReason,
  });

  final String name;
  final String initials;
  final String course;
  final String time;
  final String job;
  final RequestStatus status;
  final bool attachment;
  final bool verified;
  final String? meta;
  final String? rejectionReason;
}

const _requests = <RegistrationRequest>[
  RegistrationRequest(
    name: 'عبدالله الشمري',
    initials: 'ع ش',
    course: 'دورة إدارة المشاريع الاحترافية PMP®',
    time: 'قبل ساعتين',
    status: RequestStatus.pending,
    job: 'طالب جامعي • الرياض',
    meta: '25 سنة',
    verified: true,
  ),
  RegistrationRequest(
    name: 'سارة ناصر الدوسري',
    initials: 'س ن',
    course: 'دبلوم الأمن السيبراني واختبار الاختراق',
    time: 'قبل 4 ساعات',
    status: RequestStatus.pending,
    job: 'خريجة تقنية معلومات • الرياض',
    attachment: true,
  ),
  RegistrationRequest(
    name: 'م. فيصل الخالدي',
    initials: 'ف خ',
    course: 'تدريب ميداني — صيانة خطوط الإنتاج',
    time: 'أمس، 03:30 م',
    status: RequestStatus.accepted,
    job: 'مهندس ميكانيكي',
  ),
  RegistrationRequest(
    name: 'فهد تركي القحطاني',
    initials: 'ف ت',
    course: 'دورة إدارة المشاريع الاحترافية PMP®',
    time: 'منذ يومين',
    status: RequestStatus.rejected,
    job: 'موظف إداري',
    rejectionReason: 'عدم استيفاء شروط سنوات الخبرة العملية المطلوبة للدورة.',
  ),
  RegistrationRequest(
    name: 'عمر عبدالعزيز الحربي',
    initials: 'ع ع',
    course: 'تدريب ميداني — إدارة وضبط جودة المشاريع',
    time: 'قبل 5 ساعات',
    status: RequestStatus.pending,
    job: 'بكالوريوس إدارة أعمال',
  ),
];

class RegistrationRequestsScreen extends StatefulWidget {
  const RegistrationRequestsScreen({super.key});

  @override
  State<RegistrationRequestsScreen> createState() =>
      _RegistrationRequestsScreenState();
}

class _RegistrationRequestsScreenState
    extends State<RegistrationRequestsScreen> {
  String _tab = 'الكل';

  List<RegistrationRequest> get _visible => _requests.where((request) {
        return switch (_tab) {
          'جديد' => request.status == RequestStatus.pending,
          'مقبول' => request.status == RequestStatus.accepted,
          'مرفوض' => request.status == RequestStatus.rejected,
          _ => true,
        };
      }).toList();

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: TrainingColors.background,
          appBar: _appBar(context),
          bottomNavigationBar: const _CompanyNav(),
          body: Column(
            children: [
              _tabs(),
              _filters(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  children: [
                    for (int i = 0; i < _visible.length; i++) ...[
                      _RequestCard(
                        request: _visible[i],
                        swipeHint: i == 0 && _visible[i].status == RequestStatus.pending,
                        onTap: () => context
                            .push('/training-center/registration-requests/details'),
                        onDecision: (accept) =>
                            _showDecisionSheet(context, accept, _visible[i]),
                      ),
                      const SizedBox(height: 12),
                    ],
                    const _ListFooter(),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  PreferredSizeWidget _appBar(BuildContext context) => AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded,
              size: 19, color: TrainingColors.primary),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
        titleSpacing: 0,
        title: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('طلبات التسجيل',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w700,
                    fontSize: 19,
                    height: 1.25,
                    color: TrainingColors.primary)),
            Text('مراجعة واعتماد المتقدمين للبرامج المهنية',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
                    height: 1.3,
                    color: TrainingColors.textSecondary)),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: TrainingColors.accentSoft,
                borderRadius: BorderRadius.circular(20)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              _PulseDot(),
              SizedBox(width: 5),
              Text('3 طلبات',
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: TrainingColors.accentDark)),
            ]),
          ),
          Stack(clipBehavior: Clip.none, children: [
            IconButton(
                onPressed: () =>
                    context.push('/training-center/notifications'),
                icon: const Icon(Icons.notifications_none_rounded,
                    color: TrainingColors.textPrimary)),
            const Positioned(
                top: 9,
                left: 11,
                child: CircleAvatar(
                    radius: 4, backgroundColor: TrainingColors.danger)),
          ]),
          const Padding(
            padding: EdgeInsets.only(left: 16, right: 6),
            child: CircleAvatar(
                radius: 16,
                backgroundColor: TrainingColors.navySoft,
                child: Icon(Icons.person_rounded,
                    color: TrainingColors.primary, size: 18)),
          ),
        ],
      );

  Widget _tabs() {
    const tabs = [
      ('الكل', 12),
      ('جديد', 5),
      ('مقبول', 6),
      ('مرفوض', 1),
    ];
    return SizedBox(
      height: 60,
      child: ListView.separated(
        reverse: true,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final tab = tabs[index];
          return _StatusTabPill(
            label: tab.$1,
            count: tab.$2,
            selected: _tab == tab.$1,
            showDot: tab.$1 == 'جديد',
            onTap: () => setState(() => _tab = tab.$1),
          );
        },
      ),
    );
  }

  Widget _filters() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Row(children: [
          Expanded(
              child:
                  _filterButton(Icons.filter_list_rounded, 'تصفية حسب الدورة')),
          const SizedBox(width: 10),
          Expanded(
              child:
                  _filterButton(Icons.schedule_rounded, 'الأحدث')),
          const SizedBox(width: 10),
          const Text('5 من أصل 12',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  color: TrainingColors.textSecondary)),
        ]),
      );

  Widget _filterButton(IconData icon, String text) => InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {},
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: TrainingColors.divider),
              borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Icon(icon, size: 17, color: TrainingColors.primary),
            const SizedBox(width: 7),
            Expanded(
                child: Text(text,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: TrainingColors.textPrimary))),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 18, color: TrainingColors.textSecondary),
          ]),
        ),
      );
}

class RegistrationRequestDetailsScreen extends StatelessWidget {
  const RegistrationRequestDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: TrainingColors.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 1,
            leading: IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded,
                    size: 19, color: TrainingColors.primary),
                onPressed: () => context.pop()),
            title: const Text('تفاصيل الطلب',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    color: TrainingColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 20)),
            actions: [
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.ios_share_rounded,
                      color: TrainingColors.primary)),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.print_outlined,
                      color: TrainingColors.primary)),
            ],
          ),
          body: Stack(children: [
            ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
                children: const [
                  _RequestIdRow(),
                  SizedBox(height: 12),
                  _StudentHeader(),
                  _CourseCard(),
                  SizedBox(height: 16),
                  _InfoCard(),
                  SizedBox(height: 16),
                  _AttachmentsCard(),
                  SizedBox(height: 16),
                  _MessageCard(),
                  SizedBox(height: 16),
                  _PaymentCard(),
                ]),
            _DetailActions(
                onDecision: (accept) =>
                    _showDecisionSheet(context, accept, _requests.first)),
          ]),
        ),
      );
}

class _RequestCard extends StatelessWidget {
  const _RequestCard(
      {required this.request,
      required this.onTap,
      required this.onDecision,
      this.swipeHint = false});

  final RegistrationRequest request;
  final VoidCallback onTap;
  final ValueChanged<bool> onDecision;
  final bool swipeHint;

  @override
  Widget build(BuildContext context) {
    final pending = request.status == RequestStatus.pending;
    final stripe = switch (request.status) {
      RequestStatus.accepted => TrainingColors.primary,
      RequestStatus.rejected => TrainingColors.danger,
      RequestStatus.pending => null,
    };
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: TrainingColors.cardShadow),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _Avatar(initials: request.initials),
                        const SizedBox(width: 11),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Row(children: [
                                Flexible(
                                    child: Text(request.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w700,
                                            color: TrainingColors.primary))),
                                if (request.verified) ...[
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified_rounded,
                                      size: 16, color: TrainingColors.primary)
                                ],
                              ]),
                              const SizedBox(height: 2),
                              Row(children: [
                                const Icon(Icons.history_rounded,
                                    size: 13, color: TrainingColors.textMuted),
                                const SizedBox(width: 4),
                                Flexible(
                                    child: Text(request.time,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 10.5,
                                            color:
                                                TrainingColors.textSecondary))),
                                const SizedBox(width: 6),
                                const Text('•',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: TrainingColors.textMuted)),
                                const SizedBox(width: 6),
                                Flexible(
                                    child: Text(request.job,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 10.5,
                                            color:
                                                TrainingColors.textSecondary))),
                              ]),
                            ])),
                        const SizedBox(width: 6),
                        _StatusPill(status: request.status),
                      ]),
                      const SizedBox(height: 10),
                      _CourseBox(course: request.course),
                      if (request.attachment) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                              color: TrainingColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(8)),
                          child: const Row(children: [
                            Icon(Icons.attach_file_rounded,
                                size: 15, color: TrainingColors.accent),
                            SizedBox(width: 6),
                            Expanded(
                                child: Text(
                                    'مرفق شهادة البكالوريوس والسيرة الذاتية (PDF)',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: TrainingColors.primary))),
                          ]),
                        ),
                      ],
                      if (request.rejectionReason != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: TrainingColors.dangerSoft,
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.info_outline_rounded,
                                    size: 16, color: TrainingColors.danger),
                                const SizedBox(width: 7),
                                Expanded(
                                    child: Text.rich(TextSpan(children: [
                                  const TextSpan(
                                      text: 'سبب الرفض: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700)),
                                  TextSpan(text: request.rejectionReason!),
                                ]),
                                        style: const TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 10.5,
                                            height: 1.6,
                                            color: TrainingColors.danger))),
                              ]),
                        ),
                      ],
                      if (request.status == RequestStatus.accepted) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 9),
                          decoration: BoxDecoration(
                              color: TrainingColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(8)),
                          child: const Row(children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 16, color: TrainingColors.primary),
                            SizedBox(width: 7),
                            Expanded(
                                child: Text(
                                    'تم اعتماد القبول وإرسال الفاتورة آلياً',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 10.5,
                                        color: TrainingColors.textSecondary))),
                            Text('السجل',
                                style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: TrainingColors.accentDark)),
                          ]),
                        ),
                      ],
                      if (swipeHint) ...[
                        const SizedBox(height: 8),
                        const Row(children: [
                          Icon(Icons.touch_app_rounded,
                              size: 14, color: TrainingColors.accent),
                          SizedBox(width: 4),
                          Expanded(
                              child: Text('اسحب لليسار للقبول السريع',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 10,
                                      color: TrainingColors.accent))),
                          Text('عرض الملف',
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: TrainingColors.primary)),
                        ]),
                      ],
                      if (pending) ...[
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(
                              child: _SoftActionButton(
                                  label: 'قبول الطلب',
                                  icon: Icons.check_circle_outline_rounded,
                                  color: TrainingColors.success,
                                  onTap: () => onDecision(true))),
                          const SizedBox(width: 8),
                          Expanded(
                              child: _SoftActionButton(
                                  label: 'رفض',
                                  icon: Icons.cancel_outlined,
                                  color: TrainingColors.danger,
                                  onTap: () => onDecision(false))),
                        ]),
                      ],
                    ]),
              ),
              if (stripe != null)
                Positioned(
                    top: 0,
                    bottom: 0,
                    right: 0,
                    width: 4,
                    child: ColoredBox(color: stripe)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _RequestIdRow extends StatelessWidget {
  const _RequestIdRow();

  @override
  Widget build(BuildContext context) => const Row(children: [
        _PulseDot(),
        SizedBox(width: 8),
        Expanded(
            child: Text('طلب رقم #REQ-2025-884',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: TrainingColors.textSecondary))),
      ]);
}

class _StudentHeader extends StatelessWidget {
  const _StudentHeader();

  @override
  Widget build(BuildContext context) => _Card(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const _Avatar(initials: 'ع ش', size: 72, verified: true),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('عبدالله الشمري',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: TrainingColors.primary)),
                const SizedBox(height: 3),
                const Text('25 سنة • الرياض • طالب خريج',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: TrainingColors.textSecondary)),
                const SizedBox(height: 7),
                Row(children: [
                  Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                          color: TrainingColors.success,
                          shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  const Expanded(
                      child: Text('تم تدقيق الهوية الوطنية',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10,
                              color: TrainingColors.textSecondary))),
                ]),
              ])),
        ]),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
              color: TrainingColors.surfaceMuted,
              borderRadius: BorderRadius.circular(10)),
          child: const Row(children: [
            Icon(Icons.hourglass_top_rounded,
                size: 18, color: TrainingColors.rating),
            SizedBox(width: 8),
            Expanded(
                child: Text('حالة الطلب:',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: TrainingColors.textPrimary))),
            SizedBox(width: 8),
            _StatusPill(status: RequestStatus.pending, wide: true),
          ]),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
              color: TrainingColors.surfaceAlt,
              borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            const Icon(Icons.phone_iphone_rounded,
                size: 18, color: TrainingColors.primary),
            const SizedBox(width: 8),
            const Expanded(
                child: Text('+966 55 123 4567',
                    textDirection: TextDirection.ltr,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: TrainingColors.textPrimary))),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                  color: TrainingColors.successSoft,
                  borderRadius: BorderRadius.circular(20)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.chat_bubble_outline_rounded,
                    size: 14, color: TrainingColors.success),
                SizedBox(width: 4),
                Flexible(
                    child: Text('واتساب مباشر',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: TrainingColors.success))),
              ]),
            ),
          ]),
        ),
        const Divider(height: 18, color: TrainingColors.divider),
        const Row(children: [
          Icon(Icons.mail_outline_rounded,
              size: 18, color: TrainingColors.textSecondary),
          SizedBox(width: 8),
          Expanded(
              child: Text('abdullah.alshammari@example.com',
                  textDirection: TextDirection.ltr,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: TrainingColors.textPrimary))),
        ]),
      ]));
}

class _CourseCard extends StatelessWidget {
  const _CourseCard();

  @override
  Widget build(BuildContext context) => _Card(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.auto_stories_outlined,
              color: TrainingColors.primary, size: 20),
          SizedBox(width: 7),
          Expanded(
              child: Text('الدورة المطلوبة',
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: TrainingColors.primary))),
          _MiniBadge('كورس معتمد', TrainingColors.primary),
        ]),
        const SizedBox(height: 12),
        Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: TrainingColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                      color: TrainingColors.primary,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.groups_rounded,
                      color: Colors.white, size: 32)),
              const SizedBox(width: 10),
              const Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('دورة إدارة المشاريع الاحترافية PMP®',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: TrainingColors.primary)),
                    SizedBox(height: 5),
                    _MiniBadge('تدريب ميداني', TrainingColors.accent),
                    SizedBox(height: 5),
                    Row(children: [
                      Icon(Icons.calendar_month_outlined,
                          size: 14, color: TrainingColors.accent),
                      SizedBox(width: 4),
                      Text('يبدأ 15 يونيو 2025',
                          style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10,
                              color: TrainingColors.textSecondary)),
                    ]),
                    SizedBox(height: 3),
                    Row(children: [
                      Icon(Icons.devices_outlined,
                          size: 14, color: TrainingColors.accent),
                      SizedBox(width: 4),
                      Flexible(
                          child: Text('تدريب هجين (الرياض / عن بُعد)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 10,
                                  color: TrainingColors.textSecondary))),
                    ]),
                  ]))
            ]))
      ]));
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) => const _Card(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            _SectionTitle('البيانات الأكاديمية والمهنية', Icons.badge_outlined),
            SizedBox(height: 14),
            _InfoRow(
                icon: Icons.school_outlined,
                title: 'المؤهل العلمي',
                value: 'بكالوريوس إدارة أعمال',
                sub: 'جامعة الملك سعود — معدل 4.65 من 5.00'),
            _InfoRow(
                icon: Icons.domain_rounded,
                title: 'جهة العمل الحالية',
                value: 'شركة التقنية المتقدمة للحلول الرقمية',
                sub: 'دوام كامل • قسم إدارة البرامج التقنية'),
            _InfoRow(
                icon: Icons.work_history_outlined,
                title: 'سنوات الخبرة العملية',
                value: '3 سنوات كمنسق مشاريع تقنية',
                sub: 'إشراف وتنسيق مشاريع تطوير الأنظمة المؤسسية',
                last: true)
          ]));
}

class _AttachmentsCard extends StatelessWidget {
  const _AttachmentsCard();

  @override
  Widget build(BuildContext context) => const _Card(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.attach_file_rounded,
              color: TrainingColors.primary, size: 20),
          SizedBox(width: 7),
          Expanded(
              child: Text('المرفقات والمستندات',
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: TrainingColors.primary))),
          Text('مستندان مرفقان',
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  color: TrainingColors.textMuted)),
        ]),
        SizedBox(height: 12),
        _FileRow(
            title: 'سيرة_عبدالله_الشمري.pdf',
            sub: '240 كيلوبايت • السيرة الذاتية',
            icon: Icons.picture_as_pdf_outlined,
            color: TrainingColors.danger),
        SizedBox(height: 8),
        _FileRow(
            title: 'وثيقة_البكالوريوس.jpg',
            sub: '1.2 ميجابايت • شهادة التخرج',
            icon: Icons.image_outlined,
            color: TrainingColors.primary,
            status: 'معتمدة'),
      ]));
}

class _FileRow extends StatelessWidget {
  const _FileRow(
      {required this.title,
      required this.sub,
      required this.icon,
      required this.color,
      this.status});

  final String title;
  final String sub;
  final IconData icon;
  final Color color;
  final String? status;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: TrainingColors.surfaceAlt,
            borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, color: color, size: 21)),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  Flexible(
                      child: Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: TrainingColors.textPrimary))),
                  if (status != null) ...[
                    const SizedBox(width: 6),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: TrainingColors.successSoft,
                            borderRadius: BorderRadius.circular(5)),
                        child: Text(status!,
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: TrainingColors.success))),
                  ],
                ]),
                const SizedBox(height: 2),
                Text(sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10,
                        color: TrainingColors.textSecondary)),
              ])),
          IconButton(
              onPressed: () {},
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.visibility_outlined,
                  size: 19, color: TrainingColors.primary)),
          IconButton(
              onPressed: () {},
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.download_rounded,
                  size: 19, color: TrainingColors.primary)),
        ]),
      );
}

class _MessageCard extends StatelessWidget {
  const _MessageCard();

  @override
  Widget build(BuildContext context) => _Card(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _SectionTitle('رسالة ورغبة المتدرب', Icons.format_quote_rounded),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: TrainingColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12)),
          child: const Text(
              'أرغب بتطوير مهاراتي العملية في تخطيط وجدولة المشاريع وفق أحدث معايير PMI للحصول على شهادة PMP والتأهل لقيادة مشاريع التحول الرقمي بالمنشأة.',
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  height: 1.9,
                  fontStyle: FontStyle.italic,
                  color: TrainingColors.textPrimary)),
        ),
      ]));
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard();

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: TrainingColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: TrainingColors.cardShadow),
      child: Row(children: [
        const Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text('رسوم التسجيل المعتمدة',
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: Colors.white70)),
              SizedBox(height: 2),
              Text('1,500 ريال سعودي',
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(20)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.credit_score_outlined,
                size: 15, color: TrainingColors.accent),
            SizedBox(width: 5),
            Text('بانتظار موافقة المنشأة',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    color: TrainingColors.accent)),
          ]),
        ),
      ]));
}

class _DetailActions extends StatelessWidget {
  const _DetailActions({required this.onDecision});

  final ValueChanged<bool> onDecision;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: const BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
                color: Color(0x16000000), blurRadius: 12, offset: Offset(0, -3))
          ]),
          child: SafeArea(
            top: false,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                Expanded(
                    child: _DecisionButton(
                        label: 'قبول الطالب',
                        icon: Icons.check_circle_rounded,
                        color: TrainingColors.success,
                        solid: true,
                        onTap: () => onDecision(true))),
                const SizedBox(width: 12),
                Expanded(
                    child: _DecisionButton(
                        label: 'رفض الطلب',
                        icon: Icons.close_rounded,
                        color: TrainingColors.danger,
                        outlined: true,
                        onTap: () => onDecision(false))),
              ]),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {},
                child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded,
                          size: 15, color: TrainingColors.success),
                      SizedBox(width: 5),
                      Flexible(
                          child: Text('تواصل مع الطالب مباشرة عبر واتساب',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  color: TrainingColors.textSecondary))),
                    ]),
              ),
            ]),
          ),
        ),
      );
}

class _DecisionButton extends StatelessWidget {
  const _DecisionButton(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap,
      this.solid = false,
      this.outlined = false});

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool solid;
  final bool outlined;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 48,
        child: Material(
          color: outlined
              ? Colors.white
              : (solid ? color : color.withValues(alpha: .10)),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: outlined ? Border.all(color: color) : null),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(icon, size: 18, color: solid ? Colors.white : color),
                const SizedBox(width: 6),
                Text(label,
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: solid ? Colors.white : color)),
              ]),
            ),
          ),
        ),
      );
}

class _SoftActionButton extends StatelessWidget {
  const _SoftActionButton(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 40,
        child: Material(
          color: color.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color)),
            ]),
          ),
        ),
      );
}

class _CourseBox extends StatelessWidget {
  const _CourseBox({required this.course});

  final String course;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
            color: TrainingColors.surfaceAlt,
            borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          const Icon(Icons.menu_book_outlined,
              color: TrainingColors.primary, size: 19),
          const SizedBox(width: 8),
          Expanded(
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('طلب التسجيل في:',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    color: TrainingColors.textSecondary)),
            Text(course,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: TrainingColors.primary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700)),
          ])),
        ]),
      );
}

class _StatusTabPill extends StatelessWidget {
  const _StatusTabPill(
      {required this.label,
      required this.count,
      required this.selected,
      required this.onTap,
      this.showDot = false});

  final String label;
  final int count;
  final bool selected;
  final bool showDot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: selected ? TrainingColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: selected
                        ? TrainingColors.primary
                        : TrainingColors.divider)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (showDot) ...[
                Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                        color: TrainingColors.danger, shape: BoxShape.circle)),
                const SizedBox(width: 6),
              ],
              Text(label,
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: selected
                          ? Colors.white
                          : TrainingColors.primary)),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withValues(alpha: .22)
                        : TrainingColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(10)),
                child: Text('$count',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? Colors.white
                            : TrainingColors.primary)),
              ),
            ]),
          ),
        ),
      );
}

class _ListFooter extends StatelessWidget {
  const _ListFooter();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Column(children: [
          CircleAvatar(
              radius: 20,
              backgroundColor: TrainingColors.surfaceMuted,
              child: Icon(Icons.checklist_rtl_rounded,
                  color: TrainingColors.accent, size: 22)),
          SizedBox(height: 10),
          Text('تمت معاينة جميع الطلبات المتبقية اليوم',
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: TrainingColors.primary)),
          SizedBox(height: 3),
          Text('سيتم تحديث القائمة تلقائياً عند وصول تسجيل جديد',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10.5,
                  color: TrainingColors.textSecondary)),
        ]),
      );
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: TrainingColors.cardShadow),
      child: child);
}

class _Avatar extends StatelessWidget {
  const _Avatar(
      {required this.initials, this.size = 48, this.verified = false});

  final String initials;
  final double size;
  final bool verified;

  @override
  Widget build(BuildContext context) =>
      Stack(clipBehavior: Clip.none, children: [
        CircleAvatar(
            radius: size / 2,
            backgroundColor: TrainingColors.navySoft,
            child: Text(initials,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w700,
                    color: TrainingColors.primary,
                    fontSize: size * .28))),
        if (verified)
          Positioned(
              bottom: -2,
              left: -2,
              child: CircleAvatar(
                  radius: size * .21,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.verified_rounded,
                      size: size * .34, color: TrainingColors.success)))
      ]);
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, this.wide = false});

  final RequestStatus status;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final data = switch (status) {
      RequestStatus.pending => (
          'جديد',
          'بانتظار القرار',
          TrainingColors.rating,
          Icons.hourglass_top_rounded
        ),
      RequestStatus.accepted => (
          'مقبول',
          null,
          TrainingColors.success,
          Icons.task_alt_rounded
        ),
      RequestStatus.rejected => (
          'مرفوض',
          null,
          TrainingColors.danger,
          Icons.block_rounded
        ),
    };
    final label = wide && data.$2 != null ? '${data.$1} - ${data.$2}' : data.$1;
    return Container(
        padding: EdgeInsets.symmetric(
            horizontal: wide ? 10 : 9, vertical: wide ? 5 : 5),
        decoration: BoxDecoration(
            color: data.$3.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(data.$4, size: 13, color: data.$3),
          const SizedBox(width: 4),
          Flexible(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: data.$3)))
        ]));
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, this.icon);

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, color: TrainingColors.primary, size: 20),
        const SizedBox(width: 7),
        Expanded(
            child: Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: TrainingColors.primary)))
      ]);
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.icon,
      required this.title,
      required this.value,
      required this.sub,
      this.last = false});

  final IconData icon;
  final String title;
  final String value;
  final String sub;
  final bool last;

  @override
  Widget build(BuildContext context) => Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(
            radius: 18,
            backgroundColor: TrainingColors.surfaceAlt,
            child: Icon(icon, color: TrainingColors.primary, size: 19)),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  color: TrainingColors.textSecondary)),
          const SizedBox(height: 1),
          Text(value,
              style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: TrainingColors.textPrimary)),
          Text(sub,
              style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  color: TrainingColors.textSecondary))
        ]))
      ]));
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge(this.text, this.color);

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: color.withValues(alpha: .13),
          borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: color)));
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: Tween<double>(begin: .35, end: 1).animate(_controller),
        child: Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
                color: TrainingColors.accent, shape: BoxShape.circle)),
      );
}

class _CompanyNav extends StatelessWidget {
  const _CompanyNav();

  @override
  Widget build(BuildContext context) => Container(
      height: 70,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
                color: Color(0x12000000), blurRadius: 12, offset: Offset(0, -3))
          ]),
      child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem('الرئيسية', Icons.home_outlined),
            _NavItem('الدورات', Icons.menu_book_outlined),
            _NavItem('المحفظة', Icons.account_balance_wallet_outlined),
            _NavItem('حسابي', Icons.person_outline_rounded, active: true)
          ]));
}

class _NavItem extends StatelessWidget {
  const _NavItem(this.label, this.icon, {this.active = false});

  final String label;
  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) =>
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon,
            size: 21,
            color:
                active ? TrainingColors.primary : TrainingColors.textSecondary),
        const SizedBox(height: 3),
        if (active)
          Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                  color: TrainingColors.accent, shape: BoxShape.circle)),
        if (active) const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10,
                color: active
                    ? TrainingColors.primary
                    : TrainingColors.textSecondary,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400))
      ]);
}

void _showDecisionSheet(
    BuildContext context, bool accept, RegistrationRequest request) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ConfirmSheet(accept: accept, request: request),
  );
}

class _ConfirmSheet extends StatefulWidget {
  const _ConfirmSheet({required this.accept, required this.request});

  final bool accept;
  final RegistrationRequest request;

  @override
  State<_ConfirmSheet> createState() => _ConfirmSheetState();
}

class _ConfirmSheetState extends State<_ConfirmSheet> {
  bool _welcome = true;
  bool _telegram = true;

  @override
  Widget build(BuildContext context) {
    final accept = widget.accept;
    final color = accept ? TrainingColors.success : TrainingColors.danger;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: EdgeInsets.fromLTRB(
            24, 10, 24, 18 + MediaQuery.of(context).viewPadding.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                  color: TrainingColors.divider,
                  borderRadius: BorderRadius.circular(8))),
          const SizedBox(height: 18),
          CircleAvatar(
              radius: 27,
              backgroundColor: color.withValues(alpha: .12),
              child: Icon(accept ? Icons.check_rounded : Icons.close_rounded,
                  size: 31, color: color)),
          const SizedBox(height: 12),
          Text(accept ? 'تأكيد قبول الطالب' : 'تأكيد رفض الطلب',
              style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: TrainingColors.primary)),
          if (accept) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: TrainingColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.school_rounded,
                    size: 15, color: TrainingColors.accent),
                const SizedBox(width: 6),
                Flexible(
                    child: Text.rich(TextSpan(children: [
                  const TextSpan(text: 'الطالب: '),
                  TextSpan(
                      text: widget.request.name,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: ' • ${widget.request.course}'),
                ]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: TrainingColors.primary))),
              ]),
            ),
          ],
          const SizedBox(height: 10),
          Text(
              accept
                  ? 'سيتم إشعار الطالب فوراً برسالة نصية وتطبيق واتساب بقبول طلبه، وإصدار رابط سداد الفاتورة تلقائياً، وإضافته لكشف الحضور الرسمي الخاص بالدورة.'
                  : 'هل أنت متأكد من رفض طلب ${widget.request.name}؟ سيتم إشعاره وتحديث حالة الطلب.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  height: 1.8,
                  color: TrainingColors.textSecondary)),
          if (accept) ...[
            const SizedBox(height: 16),
            _SheetOption(
                checked: _welcome,
                onChanged: (value) => setState(() => _welcome = value),
                title: 'إرسال رسالة ترحيبية وتفاصيل القاعة التدريبية',
                subtitle: 'عبر البريد الإلكتروني والواتساب'),
            const SizedBox(height: 10),
            _SheetOption(
                checked: _telegram,
                onChanged: (value) => setState(() => _telegram = value),
                title: 'تضمين رابط الانضمام لمجموعة تليجرام الخاصة بالدورة',
                subtitle: 'للتواصل المباشر مع المدرب وزملائه المتدربين'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: TrainingColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.event_seat_rounded,
                    color: TrainingColors.accent, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                    child: Text.rich(TextSpan(children: [
                  TextSpan(text: 'سيتم حجز مقعد رسمي فوراً '),
                  TextSpan(
                      text: '(المتبقي: 4 مقاعد من 20)',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: TrainingColors.accentDark)),
                ]),
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.5,
                            color: TrainingColors.textPrimary))),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: const Text('20% شاغر',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: TrainingColors.accent))),
              ]),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: () {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                messenger.showSnackBar(SnackBar(
                    content: Text(accept
                        ? 'تم قبول الطالب وإرسال الإشعار'
                        : 'تم رفض طلب التسجيل')));
              },
              style: FilledButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              icon: Icon(accept ? Icons.check_rounded : Icons.close_rounded),
              label: Text(accept ? 'تأكيد القبول' : 'تأكيد الرفض',
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
            ),
          ),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('رجوع',
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      color: TrainingColors.textSecondary))),
        ]),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.checked,
    required this.onChanged,
    required this.title,
    required this.subtitle,
  });

  final bool checked;
  final ValueChanged<bool> onChanged;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Material(
        color: TrainingColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => onChanged(!checked),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                      color: checked
                          ? TrainingColors.accent
                          : Colors.transparent,
                      border: Border.all(
                          color: checked
                              ? TrainingColors.accent
                              : TrainingColors.divider,
                          width: 1.6),
                      borderRadius: BorderRadius.circular(6)),
                  child: checked
                      ? const Icon(Icons.check_rounded,
                          size: 15, color: Colors.white)
                      : null),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(title,
                        style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w600,
                            fontSize: 11.5,
                            height: 1.5,
                            color: TrainingColors.textPrimary)),
                    Text(subtitle,
                        style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10,
                            height: 1.5,
                            color: TrainingColors.textSecondary)),
                  ])),
            ]),
          ),
        ),
      );
}
