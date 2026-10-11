import 'package:get/get.dart';
import 'package:working_hiring/app/features/client/dashboard/bindings/dashboard_binding.dart';
import 'package:working_hiring/app/features/client/dashboard/views/dashboard/dashboard_view.dart';
import 'package:working_hiring/app/features/client/payment/views/payment/payment_view.dart';
import 'package:working_hiring/app/features/client/profile/bindings/change_password_binding.dart';
import 'package:working_hiring/app/features/client/profile/views/change_password/change_password_view.dart';
import 'package:working_hiring/app/features/client/profile/views/transaction_history/transaction_history_view.dart';
import 'package:working_hiring/app/features/worker/profile/views/worker_settings/worker_settings_view.dart';
import 'package:working_hiring/app/features/notification/bindings/notification_binding.dart';
import 'package:working_hiring/app/features/notification/views/notification/notification_view.dart';
import 'package:working_hiring/app/features/onboarding/bindings/onboarding_binding.dart';
import 'package:working_hiring/app/features/onboarding/views/onboarding/onboarding_view.dart';
import 'package:working_hiring/app/features/client/order/views/order/order_view.dart';
import 'package:working_hiring/app/features/client/order/views/feedback_success/feedback_success_view.dart';
import 'package:working_hiring/app/features/client/payment/bindings/billing_payments_binding.dart';
import 'package:working_hiring/app/features/client/payment/views/add_billing/add_billing_view.dart';
import 'package:working_hiring/app/features/client/payment/views/billing_payments/billing_payments_view.dart';
import 'package:working_hiring/app/features/service_selection/bindings/service_selection_binding.dart';
import 'package:working_hiring/app/features/service_selection/views/service_selection/service_selection_view.dart';
import 'package:working_hiring/app/features/role_selection/bindings/role_selection_binding.dart';
import 'package:working_hiring/app/features/role_selection/views/role_selection/role_selection_view.dart';
import 'package:working_hiring/app/features/splash/bindings/splash_binding.dart';
import 'package:working_hiring/app/features/splash/views/splash/splash_view.dart';
import 'package:working_hiring/app/features/worker/home/bindings/worker_home_binding.dart';
import 'package:working_hiring/app/features/worker/home/views/worker_home/worker_home_view.dart';
import 'package:working_hiring/app/features/shell/bindings/main_binding.dart';
import 'package:working_hiring/app/features/shell/views/main/main_view.dart';
import 'package:working_hiring/app/features/worker/profile/views/worker_profile/worker_profile_view.dart';
import 'package:working_hiring/app/features/worker/profile/bindings/worker_profile_binding.dart';
import 'package:working_hiring/app/features/worker/helper_profile/views/create_helper_profile/create_helper_profile_view.dart';
import 'package:working_hiring/app/features/worker/account_verification/views/worker_account_verification/worker_account_verification_view.dart';
import 'package:working_hiring/app/features/worker/account_verification/bindings/worker_account_verification_binding.dart';
import 'package:working_hiring/app/features/about/bindings/about_binding.dart';
import 'package:working_hiring/app/features/about/views/about/about_view.dart';
import 'package:working_hiring/app/features/worker/profile/views/worker_change_photo/worker_change_photo_view.dart';
import 'package:working_hiring/app/features/worker/dashboard/bindings/worker_dashboard_binding.dart';
import 'package:working_hiring/app/features/worker/dashboard/views/worker_dashboard/worker_dashboard_view.dart';
import 'package:working_hiring/app/features/client/helper_list/views/helper_list/helper_list_view.dart';
import 'package:working_hiring/app/features/client/helper_list/bindings/helper_list_binding.dart';
import 'package:working_hiring/app/features/client/helper_profile/views/helper_profile/helper_profile_view.dart';
import 'package:working_hiring/app/features/client/helper_profile/bindings/helper_profile_binding.dart';
import 'package:working_hiring/app/features/client/vouchers/bindings/vouchers_offers_binding.dart';
import 'package:working_hiring/app/features/client/vouchers/views/vouchers_offers/vouchers_offers_view.dart';

import 'package:working_hiring/app/features/auth/login/bindings/login_binding.dart';
import 'package:working_hiring/app/features/auth/login/views/login/login_view.dart';
import 'package:working_hiring/app/features/auth/otp_verification/bindings/otp_verification_binding.dart';
import 'package:working_hiring/app/features/auth/sign_up/bindings/signup_binding.dart';
import 'package:working_hiring/app/features/auth/sign_up/views/sign_up/sign_up_view.dart';
import 'package:working_hiring/app/features/auth/otp_verification/views/otp/otp_view.dart';

part 'package:working_hiring/app/routes/app_routes.dart';

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
      page: () => OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(name: _Paths.MAIN, page: () => MainView(), binding: MainBinding()),
    GetPage(
      name: _Paths.SIGN_IN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.SIGN_UP,
      page: () => SignUpView(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: _Paths.OTP,
      page: () => OtpView(),
      binding: OtpVerificationBinding(),
    ),
    GetPage(
      name: _Paths.SERVICE_SELECTION,
      page: () => ServiceSelectionView(),
      binding: ServiceSelectionBinding(),
    ),
    GetPage(
      name: _Paths.ROLE_SELECTION,
      page: () => RoleSelectionView(),
      binding: RoleSelectionBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.PAYMENT,
      page: () => BillingPaymentsView(),
      binding: BillingPaymentsBinding(),
    ),
    GetPage(
      name: _Paths.ADD_PAYMENT,
      page: () => AddBillingView(),
      binding: BillingPaymentsBinding(),
    ),
    GetPage(
      name: _Paths.CHANGE_PASSWORD,
      page: () => ChangePasswordView(),
      binding: ChangePasswordBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATION,
      page: () => NotificationView(),
      binding: NotificationBinding(),
    ),
    GetPage(name: _Paths.ORDER_VIEW, page: () => OrderView()),
    GetPage(name: _Paths.FEEDBACK_SUCCESS, page: () => FeedbackSuccessView()),
    GetPage(
      name: _Paths.WORKER_HOME,
      page: () => WorkerHomeView(),
      binding: WorkerHomeBinding(),
    ),
    GetPage(
      name: _Paths.TRANSACTION_HISTORY,
      page: () => TransactionHistoryView(),
    ),
    GetPage(
      name: _Paths.WORKER_PROFILE,
      page: () => WorkerProfileView(),
      binding: WorkerProfileBinding(),
    ),
    GetPage(
      name: _Paths.WORKER_D,
      page: () => WorkerDashboardView(),
      binding: WorkerDashboardBinding(),
    ),
    GetPage(
      name: _Paths.WORKER_ACCOUNT_VERIFICATION,
      page: () => WorkerAccountVerificationView(),
      binding: WorkerAccountVerificationBinding(),
    ),
    GetPage(
      name: _Paths.ABOUT,
      page: () => AboutView(),
      binding: AboutBinding(),
    ),
    GetPage(
      name: _Paths.WORKER_CHANGE_PHOTO,
      page: () => WorkerChangePhotoView(),
    ),
    GetPage(
      name: _Paths.HELPER_LIST,
      page: () => HelperListView(),
      binding: HelperListBinding(),
    ),
    GetPage(
      name: _Paths.HELPER_PROFILE,
      page: () => HelperProfileView(),
      binding: HelperProfileBinding(),
    ),
    GetPage(
      name: _Paths.VOUCHERS_OFFERS,
      page: () => VouchersOffersView(),
      binding: VouchersOffersBinding(),
    ),
    GetPage(name: _Paths.WORKER_SETTINGS, page: () => WorkerSettingsView()),
    GetPage(
      name: _Paths.CREATE_HELPER_PROFILE,
      page: () => CreateHelperProfileView(),
      binding: WorkerProfileBinding(),
    ),
    GetPage(name: _Paths.CHECKOUT, page: () => PaymentView()),
  ];
}
