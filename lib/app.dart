
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:nextstep_ai_app/core/di/service_locator.dart';
import 'package:nextstep_ai_app/core/routing/app_router.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/features/training_center/logic/training_center_bloc/training_center_bloc.dart';
import 'package:nextstep_ai_app/features/training_center/logic/training_programs_bloc/training_programs_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: AppTheme.themeModeNotifier,
          builder: (context, themeMode, _) {
            return MaterialApp.router(
              title: 'NextStep AI',
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
              debugShowCheckedModeBanner: false,
              routerConfig: AppRouter.router,
              builder: (context, child) {
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider<TrainingCenterBloc>(
                        create: (_) => TrainingCenterBloc(repository: sl())
                          ..add(const LoadTrainingCenters()),
                      ),
                      BlocProvider<TrainingProgramsBloc>(
                        create: (_) => TrainingProgramsBloc(repository: sl())
                          ..add(const LoadTrainingPrograms()),
                      ),
                    ],
                    child: child!,
                  ),
                );
              },
              locale: const Locale('ar', 'SA'),
              supportedLocales: const [Locale('ar', 'SA')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
            );
          },
        );
      },
    );
  }
}
