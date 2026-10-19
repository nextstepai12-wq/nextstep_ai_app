import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../logic/training_application_bloc/training_application_bloc.dart';

class TrainingApplicationScreen extends StatefulWidget {
  final String programId;

  const TrainingApplicationScreen({super.key, required this.programId});

  @override
  State<TrainingApplicationScreen> createState() =>
      _TrainingApplicationScreenState();
}

class _TrainingApplicationScreenState extends State<TrainingApplicationScreen> {
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'التقديم الإلكتروني غير متاح حالياً ولم يُرسل الطلب.',
                ),
                backgroundColor: Colors.orange,
              ),
            );
            Navigator.pop(context);
          }
          if (state is TrainingApplicationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تعذّر تقديم الطلب: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'وضع تجريبي: لن يتم إرسال الطلب إلى المركز. '
                          'يمكنك استعراض النموذج فقط.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'الاسم الكامل',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'الرجاء إدخال الاسم';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
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
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'الرجاء إدخال رقم الهاتف';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظات إضافية (اختياري)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: const Text(
                    'التقديم غير متاح حالياً',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
