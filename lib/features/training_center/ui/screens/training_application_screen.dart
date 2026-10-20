import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/core/widgets/app_buttons.dart';
import 'package:nextstep_ai_app/core/widgets/app_card.dart';
import 'package:nextstep_ai_app/core/widgets/app_responsive.dart';
import 'package:nextstep_ai_app/core/widgets/app_snack.dart';

import '../../logic/training_application_bloc/training_application_bloc.dart';

class TrainingApplicationScreen extends StatefulWidget {
  final String programId;

  const TrainingApplicationScreen({super.key, required this.programId});

  @override
  State<TrainingApplicationScreen> createState() =>
      _TrainingApplicationScreenState();
}

class _TrainingApplicationScreenState
    extends State<TrainingApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقديم طلب التدريب'),
        centerTitle: true,
      ),
      body: BlocListener<TrainingApplicationBloc, TrainingApplicationState>(
        listener: (context, state) {
          if (state is TrainingApplicationSuccess) {
            AppSnack.info(
              context,
              'التقديم الإلكتروني غير متاح حالياً ولم يُرسل الطلب.',
            );
            Navigator.pop(context);
          }
          if (state is TrainingApplicationError) {
            AppSnack.error(context, 'تعذّر تقديم الطلب: ${state.message}');
          }
        },
        child: SingleChildScrollView(
          padding: context.pagePadding,
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: AppLayout.maxFormWidth),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: SampleDataBadge(),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const AppNoticeCard(
                      title: 'التقديم غير متاح',
                      message: 'وضع تجريبي: لن يتم إرسال الطلب إلى المركز. '
                          'يمكنك استعراض النموذج فقط.',
                      tone: AppNoticeTone.warning,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'الاسم الكامل',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'الرجاء إدخال الاسم';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'الرجاء إدخال البريد الإلكتروني';
                        }
                        if (!value!.contains('@')) {
                          return 'الرجاء إدخال بريد إلكتروني صحيح';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'رقم الهاتف',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'الرجاء إدخال رقم الهاتف';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظات إضافية (اختياري)',
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppPrimaryButton(
                      label: 'التقديم غير متاح حالياً',
                      icon: Icons.lock_outline_rounded,
                      onPressed: null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
