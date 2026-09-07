// lib/features/training_center/ui/screens/training_programs_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../logic/training_programs_bloc/training_programs_bloc.dart';
import '../../logic/training_center_bloc/training_center_bloc.dart';
import '../widgets/training_center_drawer.dart';

class TrainingProgramsScreen extends StatefulWidget {
  const TrainingProgramsScreen({super.key});

  @override
  State<TrainingProgramsScreen> createState() => _TrainingProgramsScreenState();
}

class _TrainingProgramsScreenState extends State<TrainingProgramsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'الكل';
  bool _isGridView = true;
  bool _isDataLoaded = false;

  final List<String> _filters = [
    'الكل',
    'معتمدة',
    'قيد المراجعة',
    'بحاجة لتعديل',
    'مسودة',
  ];

  final List<String> _sortOptions = [
    'الأحدث تحديثاً',
    'الأكثر تسجيلاً',
    'أبجدي',
  ];

  String _selectedSort = 'الأحدث تحديثاً';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDataLoaded) {
        context.read<TrainingProgramsBloc>().add(const LoadTrainingPrograms());
        context.read<TrainingCenterBloc>().add(const LoadTrainingCenters());
        _isDataLoaded = true;
      }
    });
  }

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

  // ============================
  //  AppBar
  // ============================
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
            Icons.school_rounded,
            color: Colors.blue.shade700,
            size: 24.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            'البرامج التدريبية',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            context.push('/training-center/notifications');
          },
        ),
        CircleAvatar(
          radius: 20.r,
          backgroundColor: Colors.grey.shade300,
          child: Icon(
            Icons.person,
            size: 22.sp,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(width: 8.w),
      ],
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.white.withValues(alpha: 0.92),
    );
  }

  // ============================
  //  Body
  // ============================
  Widget _buildBody() {
    return Column(
      children: [
        // ✅ شريط البحث والفلاتر
        _buildSearchAndFilter(),
        // ✅ تبديل العرض
        _buildViewToggle(),
        // ✅ قائمة البرامج
        Expanded(
          child: _buildProgramsList(),
        ),
      ],
    );
  }

  // ============================
  //  Search and Filter Bar
  // ============================
  Widget _buildSearchAndFilter() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        children: [
          // ✅ شريط البحث
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      _searchPrograms(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'البحث عن دورة...',
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade400,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Colors.grey.shade400,
                        size: 20.sp,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // ✅ زر الفلاتر
              Container(
                height: 48.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list_rounded,
                      color: Colors.grey.shade600,
                      size: 20.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'فلاتر',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // ✅ فلترة الحالة
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: FilterChip(
                    label: Text(
                      filter,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                      _applyFilter(filter);
                    },
                    selectedColor: Colors.blue.shade100,
                    backgroundColor: Colors.grey.shade50,
                    checkmarkColor: Colors.blue.shade700,
                    side: BorderSide(
                      color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ============================
  //  View Toggle (Grid/List)
  // ============================
  Widget _buildViewToggle() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ✅ تبديل العرض
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                _buildToggleButton(
                  icon: Icons.grid_view_rounded,
                  isSelected: _isGridView,
                  onTap: () {
                    setState(() {
                      _isGridView = true;
                    });
                  },
                ),
                _buildToggleButton(
                  icon: Icons.list_rounded,
                  isSelected: !_isGridView,
                  onTap: () {
                    setState(() {
                      _isGridView = false;
                    });
                  },
                ),
              ],
            ),
          ),
          // ✅ ترتيب
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: DropdownButton<String>(
              value: _selectedSort,
              items: _sortOptions.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(
                    option,
                    style: TextStyle(fontSize: 12.sp),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedSort = value;
                  });
                  _sortPrograms(value);
                }
              },
              underline: const SizedBox(),
              icon: Icon(
                Icons.arrow_drop_down_rounded,
                color: Colors.grey.shade600,
                size: 20.sp,
              ),
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade700 : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey.shade600,
          size: 20.sp,
        ),
      ),
    );
  }

  // ============================
  //  Programs List
  // ============================
  Widget _buildProgramsList() {
    return BlocBuilder<TrainingProgramsBloc, TrainingProgramsState>(
      builder: (context, state) {
        if (state is TrainingProgramsLoading) {
          return _buildShimmerGrid();
        }

        if (state is TrainingProgramsLoaded) {
          final programs = state.programs;
          if (programs.isEmpty) {
            return _buildEmptyState();
          }
          return _isGridView
              ? _buildGridView(programs)
              : _buildListView(programs);
        }

        if (state is TrainingProgramsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 60.sp,
                  color: Colors.red.shade400,
                ),
                SizedBox(height: 16.h),
                Text(
                  'حدث خطأ: ${state.message}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () {
                    context
                        .read<TrainingProgramsBloc>()
                        .add(const LoadTrainingPrograms());
                  },
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        return const Center(
          child: Text('لا توجد بيانات'),
        );
      },
    );
  }

  // ============================
  //  Grid View
  // ============================
  Widget _buildGridView(List programs) {
    return Padding(
      padding: EdgeInsets.all(8.r),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 0.75,
        ),
        itemCount: programs.length,
        itemBuilder: (context, index) {
          final program = programs[index];
          return _buildProgramCard(program);
        },
      ),
    );
  }

  // ============================
  //  List View
  // ============================
  Widget _buildListView(List programs) {
    return ListView.builder(
      padding: EdgeInsets.all(8.r),
      itemCount: programs.length,
      itemBuilder: (context, index) {
        final program = programs[index];
        return _buildProgramListItem(program);
      },
    );
  }

  // ============================
  //  Program Card (Grid)
  // ============================
  Widget _buildProgramCard(dynamic program) {
    final status = _getProgramStatus(program);
    final statusColor = _getStatusColor(status);
    final statusBg = _getStatusBackground(status);
    final statusIcon = _getStatusIcon(status);

    return GestureDetector(
      onTap: () {
        context.push(
          '/training-center/program-details',
          extra: program.id,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: status == 'بحاجة لتعديل'
              ? Colors.orange.shade50
              : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: status == 'بحاجة لتعديل'
                ? Colors.orange.shade300
                : Colors.grey.shade200,
            width: status == 'بحاجة لتعديل' ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ رأس البطاقة
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              statusIcon,
                              color: statusColor,
                              size: 12.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              status,
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          program.level ?? 'مبتدئ',
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: Colors.grey.shade400,
                      size: 18.sp,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            // ✅ صورة البرنامج
            Container(
              height: 80.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                image: program.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(program.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: program.imageUrl == null
                  ? Icon(
                      Icons.menu_book_rounded,
                      size: 32.sp,
                      color: Colors.blue.shade300,
                    )
                  : null,
            ),
            // ✅ محتوى البطاقة
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    program.title,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    program.category ?? 'عام',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.group_rounded,
                            size: 14.sp,
                            color: Colors.grey.shade500,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${program.enrolledCount ?? 0} مسجل',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _getRelativeTime(program.createdAt),
                        style: TextStyle(
                          fontSize: 10.sp,
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
      ),
    );
  }

  // ============================
  //  Program List Item
  // ============================
  Widget _buildProgramListItem(dynamic program) {
    final status = _getProgramStatus(program);
    final statusColor = _getStatusColor(status);
    final statusBg = _getStatusBackground(status);
    final statusIcon = _getStatusIcon(status);

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: status == 'بحاجة لتعديل'
            ? Colors.orange.shade50
            : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: status == 'بحاجة لتعديل'
              ? Colors.orange.shade300
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          context.push(
          '/training-center/program-details',
          extra: program.id,
        );
        },
        child: Row(
          children: [
            // ✅ صورة مصغرة
            Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8.r),
                image: program.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(program.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: program.imageUrl == null
                  ? Icon(
                      Icons.menu_book_rounded,
                      size: 24.sp,
                      color: Colors.blue.shade300,
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            // ✅ المحتوى
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    program.title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${program.category ?? 'عام'} • مستوى ${program.level ?? 'مبتدئ'}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              statusIcon,
                              color: statusColor,
                              size: 10.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              status,
                              style: TextStyle(
                                fontSize: 8.sp,
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.group_rounded,
                        size: 12.sp,
                        color: Colors.grey.shade500,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${program.enrolledCount ?? 0}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.sp,
                color: Colors.grey.shade400,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  // ============================
  //  Empty State
  // ============================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: 80.sp,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد برامج تدريبية',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'قم بإضافة برنامج تدريبي جديد للبدء',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: الذهاب إلى صفحة إضافة برنامج
            },
            icon: const Icon(Icons.add),
            label: const Text('إضافة برنامج جديد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================
  //  Shimmer Loading
  // ============================
  Widget _buildShimmerGrid() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: EdgeInsets.all(8.r),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 0.75,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================
  //  Helper Functions
  // ============================
  String _getProgramStatus(dynamic program) {
    if (program.isActive) return 'معتمدة';
    // يمكن إضافة منطق إضافي بناءً على بيانات البرنامج
    return 'قيد المراجعة';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'معتمدة':
        return Colors.green.shade700;
      case 'قيد المراجعة':
        return Colors.blue.shade700;
      case 'بحاجة لتعديل':
        return Colors.orange.shade700;
      case 'مسودة':
        return Colors.grey.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  Color _getStatusBackground(String status) {
    switch (status) {
      case 'معتمدة':
        return Colors.green.shade50;
      case 'قيد المراجعة':
        return Colors.blue.shade50;
      case 'بحاجة لتعديل':
        return Colors.orange.shade50;
      case 'مسودة':
        return Colors.grey.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

IconData _getStatusIcon(String status) {
  switch (status) {
    case 'معتمدة':
      return Icons.check_circle_rounded;
    case 'قيد المراجعة':
      return Icons.schedule_rounded;
    case 'بحاجة لتعديل':
      return Icons.edit_note_rounded;
    case 'مسودة':
      return Icons.drafts_rounded; // ✅ تم التصحيح
    default:
      return Icons.circle_rounded;
  }
}

  String _getRelativeTime(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return 'منذ ${(difference.inDays / 7).floor()} أسابيع';
    } else if (difference.inDays > 1) {
      return 'منذ ${difference.inDays} أيام';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inHours > 1) {
      return 'منذ ${difference.inHours} ساعات';
    } else if (difference.inHours == 1) {
      return 'منذ ساعة';
    } else if (difference.inMinutes > 1) {
      return 'منذ ${difference.inMinutes} دقائق';
    } else {
      return 'الآن';
    }
  }

  void _searchPrograms(String query) {
    context.read<TrainingProgramsBloc>().add(SearchPrograms(query));
  }

  void _applyFilter(String filter) {
    // تطبيق الفلتر
    if (filter == 'الكل') {
      context.read<TrainingProgramsBloc>().add(const LoadTrainingPrograms());
    } else {
      // يمكن إضافة منطق الفلتر حسب الحالة
      context.read<TrainingProgramsBloc>().add(const LoadTrainingPrograms());
    }
  }

  void _sortPrograms(String sort) {
    // يمكن إضافة منطق الترتيب
  }
}