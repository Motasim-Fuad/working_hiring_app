// ignore_for_file: constant_identifier_names
part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const SPLASH = _Paths.SPLASH;
  static const ONBOARDING = _Paths.ONBOARDING;
  static const SIGN_IN = _Paths.SIGN_IN;
  static const SIGN_UP = _Paths.SIGN_UP;
  static const OTP = _Paths.OTP;
  static const ROLE_SELECTION = _Paths.ROLE_SELECTION;
  static const SERVICE_SELECTION = _Paths.SERVICE_SELECTION;
  static const DASHBOARD = _Paths.DASHBOARD;
  static const CREATE_TASK = _Paths.CREATE_TASK;
  static const PAYMENT = _Paths.PAYMENT;
  static const ADD_PAYMENT = _Paths.ADD_PAYMENT;
  static const CHANGE_PASSWORD = _Paths.CHANGE_PASSWORD;
  static const NOTIFICATION = _Paths.NOTIFICATION;
  static const ORDER_VIEW = _Paths.ORDER_VIEW;
  static const FEEDBACK_SUCCESS = _Paths.FEEDBACK_SUCCESS;
  static const WORKER_HOME = _Paths.WORKER_HOME;
  static const MAIN = _Paths.MAIN;
  static const WORKER_D = _Paths.WORKER_D;
  static const TRANSACTION_HISTORY = _Paths.TRANSACTION_HISTORY;
  static const WORKER_ACCOUNT_VERIFICATION = _Paths.WORKER_ACCOUNT_VERIFICATION;
  static const WORKER_PROFILE = _Paths.WORKER_PROFILE;
  static const ABOUT = _Paths.ABOUT;
  static const WORKER_CHANGE_EMAIL = _Paths.WORKER_CHANGE_EMAIL;
  static const WORKER_CHANGE_PHOTO = _Paths.WORKER_CHANGE_PHOTO;
  static const HELPER_LIST = _Paths.HELPER_LIST;
  static const HELPER_PROFILE = _Paths.HELPER_PROFILE;
  static const VOUCHERS_OFFERS = _Paths.VOUCHERS_OFFERS;
  static const SETTINGS = _Paths.SETTINGS;
  static const WORKER_SETTINGS = _Paths.WORKER_SETTINGS;
  static const CREATE_HELPER_PROFILE = _Paths.CREATE_HELPER_PROFILE;
  static const CHECKOUT = _Paths.CHECKOUT;
}

abstract class _Paths {
  _Paths._();
  static const SPLASH = '/';
  static const ONBOARDING = '/onboarding';
  static const SIGN_IN = '/sign-in';
  static const SIGN_UP = '/sign-up';
  static const OTP = '/otp';
  static const ROLE_SELECTION = '/role-selection';
  static const SERVICE_SELECTION = '/service-selection';
  static const DASHBOARD = '/dashboard';
  static const CREATE_TASK = '/create-task';
  static const PAYMENT = '/payment';
  static const ADD_PAYMENT = '/add-payment';
  static const CHANGE_PASSWORD = '/change-password';
  static const NOTIFICATION = '/notification';
  static const CREATE_TASK_SUCCESS = '/create-task-success';
  static const ORDER_VIEW = '/order_view';
  static const FEEDBACK_SUCCESS = '/feedback-success';
  static const WORKER_HOME = '/worker-home';
  static const MAIN = '/main';
  static const WORKER_D = '/worker_dashboard_view';
  static const TRANSACTION_HISTORY = '/transaction-history';
  static const WORKER_PROFILE = '/worker-profile';
  static const WORKER_ACCOUNT_VERIFICATION = '/worker-account-verification';
  static const ABOUT = '/about';
  static const WORKER_CHANGE_EMAIL = '/worker-change-email';
  static const WORKER_CHANGE_PHOTO = '/worker-change-photo';
  static const HELPER_LIST = '/helper-list';
  static const HELPER_PROFILE = '/helper-profile';
  static const VOUCHERS_OFFERS = '/vouchers-offers';
  static const SETTINGS = '/settings';
  static const WORKER_SETTINGS = '/worker-settings';
  static const CREATE_HELPER_PROFILE = '/create-helper-profile';
  static const CHECKOUT = '/checkout';
}
