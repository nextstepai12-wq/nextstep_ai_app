# NextStep AI — UI Documentation

App: **NextStep AI** — AI-Powered Academic & Career Guidance Platform
Language: Arabic (RTL) | Locale: `ar-SA` | Version: 1.0.0

This document describes every screen in the app, grouped by user role.

---

## 1. Shared / Auth Screens

| Route | Screen | Description |
|-------|--------|-------------|
| `/splash` | **SplashScreen** | Animated landing page: particles background, pulsing logo, staggered fade/slide intro of title "NextStep AI", subtitle and CTA button "ابدأ الآن". After ~3.4s it checks the saved session and routes to the correct role home, or to `/login`. |
| `/login` | **LoginScreen** | Email/password login with connectivity check, show/hide password, localized error handling (invalid credentials / network / timeout). Includes 4 one-tap **dev accounts** (طالب / جامعة / إدارة / مركز تدريب) for quick testing. Routes to the role home on success. |
| `/register` | **RegisterScreen** | Student self-registration. User picks path: **طالب توجيهي** (new student) or **طالب جامعي** (university student). Fields adapt accordingly (high-school score / GPA, university, major, academic year, branch, phone with country code). Requires accepting terms. |
| `/forget-password` | **ForgetPasswordScreen** | Password reset request by email. |
| `/terms` | **TermsScreen** | Terms & conditions display. |

---

## 2. Student Screens

Shell: `StudentMainScreen` — bottom navigation bar with 5 fixed tabs (RTL):
**الرئيسية | الاستبيان | التوصيات | المساعد | الملف**

| Route | Screen | Description |
|-------|--------|-------------|
| `/student` (tab 1) | **StudentHomeScreen** | Welcome banner with user name, top AI recommendations (major + university + match %) that jump to recommendations, quick access cards for assessment/recommendations/chat. |
| `/student/assessment` (tab 2) | **AssessmentScreen** | AI survey questionnaire. Loads survey questions (with options), tracks answers, on submit calculates results, saves locally (Hive) and syncs to student profile, then routes to recommendations. |
| `/student/recommendations` (tab 3) | **RecommendationsScreen** | AI-generated major matches backed by universities list (fetched via Supabase query: `select('*, universities(name, location)').eq('is_active', true).order('name')`). |
| `/student/major-detail` | **MajorDetailScreen** | Detail view for a specific major (university + match score), launched with major data as route extra. |
| `/student/chat` (tab 4) | **ChatScreen** | AI assistant chat ("المساعد") using chat-bubble UI with keyword-based contextual replies (specialization / university / career / study topics). |
| `/student/profile` (tab 5) | **ProfileScreen** | Student profile card: student type, phone, city, high-school score, GPA, etc. |
| `/student/notifications` | **NotificationsScreen** | Notifications list with multi-select and delete actions. |
| `/student/settings` | **SettingsScreen** | App settings. |
| `/student/help-center` | **HelpCenterScreen** | Help & FAQ with searchable FAQ list. |
| `/student/contact-us` | **ContactUsScreen** | Contact form / info. |
| `/student/rate-app` | **RateAppScreen** | Rate the app. |
| `/student/share-app` | **ShareAppScreen** | Share the app (uses `share_plus`). |
| `/student/privacy-policy` | **PrivacyPolicyScreen** | Privacy policy text. |
| `/student/terms-conditions` | **TermsConditionsScreen** | Terms & conditions text. |
| `/student/cookies-policy` | **CookiesPolicyScreen** | Cookies policy text. |

---

## 3. University Screens

Shell: `UniversityHomeScreen` — AppBar + side **Drawer** navigation.

Drawer items: الرئيسية، التخصصات، الكليات، التحليلات، الطلاب، الملف الشخصي، الإعدادات، تسجيل الخروج.

| Route | Screen | Description |
|-------|--------|-------------|
| `/university` | **UniversityHomeScreen** | Welcome banner (university name/location, logo), stat cards (students 1,250 / majors 24 / rating 4.8), quick actions grid (إضافة تخصص / الكليات / التقارير / الطلاب / الإعدادات / الملف الشخصي), top majors with student counts & growth %, recent students with status badges. |
| `/university/programs` | **UniversityProgramsScreen** | Manage majors list with search/filter; open add/edit forms. |
| `/university/add-program` | **AddEditProgramScreen** | Add a new major (create mode). |
| `/university/edit-program` | **AddEditProgramScreen** | Edit an existing major (edit mode, pre-filled data). |
| `/university/faculties` | **ManageFacultiesScreen** | Manage faculties list with search and add/edit/delete. |
| `/university/add-faculty` | **AddFacultyScreen** | Add a faculty (name, dean, email, description, type). |
| `/university/edit-faculty` | **AddFacultyScreen** | Edit a faculty (edit mode). |
| `/university/analytics` | **UniversityAnalyticsScreen** | Analytics & reports (programs performance, student interest). |
| `/university/students` | **UniversityStudentsScreen** | Students list with search. |
| `/university/profile` | **UniversityProfileScreen** | University profile (logo, name, identity data). |
| `/university/settings` | **UniversitySettingsScreen** | Settings (incl. radio-based theme preference, subscription tier). |
| `/university/notifications` | **UniversityNotificationsScreen** | Notifications with multi-select management. |

---

## 4. Admin Screens

Shell: `AdminDashboardScreen` (`/admin`) / `AdminHomeScreen` (`/admin/home`) — AppBar + side **Drawer**.

Drawer items: لوحة التحكم، المستخدمين، الجامعات، التخصصات، التقارير، الملف الشخصي، الإعدادات، تسجيل الخروج.

| Route | Screen | Description |
|-------|--------|-------------|
| `/admin` | **AdminDashboardScreen** | Welcome banner, stats grid (users / universities / majors / faculties), quick actions (add user/university/major, reports), recent users, latest universities. |
| `/admin/home` | **AdminHomeScreen** | Similar dashboard (with richer quick-action cards). |
| `/admin/users` | **AdminUsersScreen** | Platform users list: search, delete, role badges; cached offline in Hive with offline fallback message. |
| `/admin/users/add` | **AdminAddUserScreen** | Create user (student/university). |
| `/admin/users/edit` | **AdminAddUserScreen** | Edit user (edit mode). |
| `/admin/universities` | **AdminUniversitiesScreen** | Universities list with search, add/edit/delete (chained delete via Supabase). |
| `/admin/universities/add` | **AdminAddUniversityScreen** | Add university (name, location, email validation). |
| `/admin/universities/edit` | **AdminAddUniversityScreen** | Edit university. |
| `/admin/programs` | **AdminProgramsScreen** | Platform-wide majors list with search; add/edit. |
| `/admin/programs/add` | **AdminAddProgramScreen** | Add major (fetches active universities for dropdown). |
| `/admin/programs/edit` | **AdminAddProgramScreen** | Edit major. |
| `/admin/reports` | **AdminReportsScreen** | Platform statistics (total/active users, new users, etc.). |
| `/admin/llm-usage` | **AdminLlmUsageScreen** | LLM/AI usage monitoring. |
| `/admin/settings` | **AdminSettingsScreen** | Admin settings. |
| `/admin/notifications` | **AdminNotificationsScreen** | Notifications with management. |
| `/admin/profile` | **AdminProfileScreen** | Admin profile with edit (name/phone) + password change. |

---

## 5. Training Center Screens

All routes live inside a `ShellRoute` that injects `TrainingCenterBloc` + `TrainingProgramsBloc`.

Shell: `TrainingCenterHomeScreen` — AppBar (logo + notification badge + avatar) + side **Drawer**.

Drawer items: الرئيسية، لوحة التحكم، البرامج التدريبية، الطلاب، المدربون، الملف التعريفي، الإشعارات، الإعدادات، المساعدة والدعم، تسجيل الخروج (v1.0.0).

| Route | Screen | Description |
|-------|--------|-------------|
| `/training-center` | **TrainingCenterHomeScreen** | Welcome banner with center name + "استعراض البرامج" button, stat cards (programs / students / rating), featured training programs (horizontal scroll → ProgramCard → details), recommended centers. |
| `/training-center/dashboard` | **DashboardScreen** | Full center dashboard. |
| `/training-center/programs` | **TrainingProgramsScreen** | Training programs with grid/list toggle, search, category filter, status badges (e.g. بحاجة لتعديل). |
| `/training-center/program-details` | **TrainingProgramDetailsScreen** | Program details (image, title, description, price/rating), loads via `LoadProgramDetails(programId)`. |
| `/training-center/apply` | **TrainingApplicationScreen** | Application form (name, email, phone, notes) for a given `programId`. |
| `/training-center/students` | **StudentsScreen** | Enrolled students list with search. |
| `/training-center/instructors` | **InstructorsScreen** | Instructor roster with search; **InstructorProfileScreen** for detail. |
| `/training-center/profile` | **CenterProfileScreen** | Training center profile + preview of its programs (`_buildCourseCard`). |
| `/training-center/verification` | **VerificationScreen** | Center verification flow. |
| `/training-center/notifications` | **NotificationsScreen** (training) | Notifications with management. |
| `/training-center/settings` | **SettingsScreen** (training) | Center settings. |
| `/training-center/help` | **HelpScreen** (training) | Help & FAQ (searchable). |

---

## 6. Shared Utility Routes

`/help-center`, `/contact-us`, `/rate-app`, `/share-app`, `/privacy-policy`, `/terms-conditions`, `/cookies-policy` — reachable by multiple roles; all include email-format validation where forms exist.

---

## 7. Notes

- Screen text is Arabic throughout; the app root forces `Directionality` RTL.
- Data shown in most screens is **mock/hardcoded** — the networking layer (`supabase_service.dart`) currently uses `Dummy*` classes, so lists/stats do not come from a real backend yet.
- `flutter analyze` currently reports **0 errors** (only lint infos).