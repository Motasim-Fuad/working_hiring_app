import 'package:get/get.dart';
import '../modules/i_need_help/create_task/bindings/create_task_binding.dart';
import '../modules/i_need_help/create_task/views/create_task_view.dart';
import '../modules/i_need_help/create_task/views/task_success_view.dart';
import '../modules/i_need_help/dashboard/bindings/dashboard_binding.dart';
import '../modules/i_need_help/dashboard/views/dashboard_view.dart';
import '../modules/i_need_help/payment/views/payment_view.dart';
import '../modules/i_need_help/profile/bindings/change_password_binding.dart';
import '../modules/i_need_help/profile/views/change_password_view.dart';
import '../modules/i_need_help/profile/views/transaction_history_view.dart';
import '../modules/i_want_to_work/profile/views/worker_settings_view.dart';
import '../modules/notification/bindings/notification_binding.dart';
import '../modules/notification/views/notification_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/i_need_help/order/views/order_view.dart';
import '../modules/i_need_help/order/views/feedback_success_view.dart';
import '../modules/i_need_help/payment/bindings/billing_payments_binding.dart';
import '../modules/i_need_help/payment/views/add_billing_view.dart';
import '../modules/i_need_help/payment/views/billing_list_view.dart';
import '../modules/i_need_help/payment/views/billing_payments_view.dart';
import '../modules/service_selection/bindings/service_selection_binding.dart';
import '../modules/service_selection/views/service_selection_view.dart';
import '../modules/role_selection/bindings/role_selection_binding.dart';
import '../modules/role_selection/views/role_selection_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/i_want_to_work/home/bindings/worker_home_binding.dart';
import '../modules/i_want_to_work/home/views/worker_home_view.dart';
import '../modules/main/bindings/main_binding.dart';
import '../modules/main/views/main_view.dart';
import '../modules/i_want_to_work/profile/views/worker_profile_view.dart';
import '../modules/i_want_to_work/profile/bindings/worker_profile_binding.dart';
import '../modules/i_want_to_work/profile/create_helper_profile_view.dart';
import '../modules/i_want_to_work/profile/views/worker_account_verification_view.dart';
import '../modules/i_want_to_work/profile/bindings/worker_account_verification_binding.dart';
import '../modules/common/about/bindings/about_binding.dart';
import '../modules/common/about/views/about_view.dart';
import '../modules/i_want_to_work/profile/views/worker_change_email_view.dart';
import '../modules/i_want_to_work/profile/views/worker_change_photo_view.dart';
import '../modules/i_want_to_work/dashboard/bindings/worker_dashboard_binding.dart';
import '../modules/i_want_to_work/dashboard/views/worker_dashboard_view.dart';
import '../modules/i_need_help/helper_list/views/helper_list_view.dart';
import '../modules/i_need_help/helper_list/bindings/helper_list_binding.dart';
import '../modules/i_need_help/helper_profile/views/helper_profile_view.dart';
import '../modules/i_need_help/helper_profile/bindings/helper_profile_binding.dart';
import '../modules/i_need_help/profile/bindings/vouchers_offers_binding.dart';
import '../modules/i_need_help/profile/views/vouchers_offers_view.dart';
import '../modules/i_need_help/profile/views/settings_view.dart';

// Auth Module Imports
import '../modules/auth/login/bindings/login_binding.dart';
import '../modules/auth/login/views/login_view.dart';
import '../modules/auth/otp_verification/bindings/otp_verification_binding.dart';
import '../modules/auth/sign_up/bindings/signup_binding.dart';
import '../modules/auth/sign_up/views/sign_up_view.dart';
import '../modules/auth/otp_verification/views/otp_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () =>  OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.MAIN,
      page: () =>  MainView(),
      binding: MainBinding(),
    ),
    GetPage(
      name: _Paths.SIGN_IN,
      page: () =>  LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.SIGN_UP,
      page: () =>  SignUpView(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: _Paths.OTP,
      page: () =>  OtpView(),
      binding: OtpVerificationBinding(),
    ),
    GetPage(
      name: _Paths.SERVICE_SELECTION,
      page: () =>  ServiceSelectionView(),
      binding: ServiceSelectionBinding(),
    ),
    GetPage(
      name: _Paths.ROLE_SELECTION,
      page: () =>  RoleSelectionView(),
      binding: RoleSelectionBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () =>  DashboardView(),
      binding: DashboardBinding(),
    ),
    // GetPage(
    //   name: _Paths.CREATE_TASK,
    //   page: () => const CreateTaskView(),
    //   binding: CreateTaskBinding(),
    // ),
    GetPage(
      name: _Paths.PAYMENT,
      page: () =>  BillingPaymentsView(),
      binding: BillingPaymentsBinding(),
    ),
    GetPage(
      name: _Paths.ADD_PAYMENT,
      page: () =>  AddBillingView(),
      binding: BillingPaymentsBinding(),
    ),
    GetPage(
      name: _Paths.CHANGE_PASSWORD,
      page: () =>  ChangePasswordView(),
      binding: ChangePasswordBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATION,
      page: () =>  NotificationView(),
      binding: NotificationBinding(),
    ),
    // GetPage(
    //   name: _Paths.CREATE_TASK_SUCCESS,
    //   page: () => const TaskSuccessView(),
    // ),
    GetPage(name: _Paths.ORDER_VIEW, page: () =>  OrderView()),
    GetPage(
      name: _Paths.FEEDBACK_SUCCESS,
      page: () =>  FeedbackSuccessView(),
    ),
    GetPage(
      name: _Paths.WORKER_HOME,
      page: () =>  WorkerHomeView(),
      binding: WorkerHomeBinding(),
    ),
    GetPage(
      name: _Paths.TRANSACTION_HISTORY,
      page: () =>  TransactionHistoryView(),
    ),
    GetPage(
      name: _Paths.WORKER_PROFILE,
      page: () =>  WorkerProfileView(),
      binding: WorkerProfileBinding(),
    ),
    GetPage(
      name: _Paths.WORKER_D,
      page: () =>  WorkerDashboardView(),
      binding: WorkerDashboardBinding(),
    ),
    GetPage(
      name: _Paths.WORKER_ACCOUNT_VERIFICATION,
      page: () =>  WorkerAccountVerificationView(),
      binding: WorkerAccountVerificationBinding(),
    ),
    GetPage(
      name: _Paths.ABOUT,
      page: () =>  AboutView(),
      binding: AboutBinding(),
    ),
    GetPage(
      name: _Paths.WORKER_CHANGE_PHOTO,
      page: () =>  WorkerChangePhotoView(),
    ),
    GetPage(
      name: _Paths.HELPER_LIST,
      page: () =>  HelperListView(),
      binding: HelperListBinding(),
    ),
    GetPage(
      name: _Paths.HELPER_PROFILE,
      page: () =>  HelperProfileView(),
      binding: HelperProfileBinding(),
    ),
    GetPage(
      name: _Paths.VOUCHERS_OFFERS,
      page: () =>  VouchersOffersView(),
      binding: VouchersOffersBinding(),
    ),
    // GetPage(
    //   name: _Paths.SETTINGS,
    //   page: () => const SettingsView(),
    // ),
    GetPage(
      name: _Paths.WORKER_SETTINGS,
      page: () =>  WorkerSettingsView(),
    ),
    GetPage(
      name: _Paths.CREATE_HELPER_PROFILE,
      page: () =>  CreateHelperProfileView(),
      binding: WorkerProfileBinding(),
    ),
    GetPage(name: _Paths.CHECKOUT, page: () =>  PaymentView()),
  ];
}
