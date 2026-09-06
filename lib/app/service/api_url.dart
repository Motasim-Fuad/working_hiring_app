class ApiUrl {
  static const baseUrl = "http://15.222.112.196:8001/api/v1";

  // ==================== Auth ====================
  static const loginWithPassword = "/token/auth/";
  static const requestLoginOtp = "/token/otp/request/";
  static const verifyLoginOtp = "/token/otp/verify/";
  static const verifyToken = "/token/verify/";
  static const refreshToken = "/token/refresh/";
  static const signUp = "/auth/signup/";
  static const signUpVerify = "/auth/signup/verify/";
  static const signUpResendOtp = "/auth/signup/resend/";
  static const changePassword = "/auth/password/change/";
  static const passwordResetRequest = "/auth/password/reset/";
  static const passwordResetConfirm = "/auth/password/reset-confirm/";
  static const googleLogin = "/auth/token/google/";
  static const appleLogin = "/auth/token/apple/";

  // ==================== User / Profile ====================
  static const currentUser = "/current-user/";
  static const userAddresses = "/user/address/";
  static const userLanguage = "/user/language/";

  // ==================== Helper / Provider Profile ====================
  static const helperProfile = "/helper-profile/";
  static const createHelperProfile = "/create-helper-profile/";
  static const providerAddressUpdate = "/provider-address-update/";
  static const providerVerification = "/provider-verification/";
  static const providerNextJobOrders = "/provider/next-job-orders/";
  static const providerEarningsOverview = "/provider/earnings-overview/";
  static const providerEarningsTransactions = "/provider/earnings-transactions/";

  // ==================== Availability ====================
  static const helperWeeklyAvailability = "/user/helper-weekly-availability/";
  static const helperWeeklyDayList = "/user/helper-weekly-availability/weekly-day-list/";
  static String helperSetWeeklyAvailability = "/user/helper-weekly-availability/set-weekly-availability/";
  static String helperUpdateAvailability(String day) => "/user/helper-weekly-availability/update-availability/$day/";
  static String helperDateSlotList(String date) => "/user/helper-weekly-availability/date-slot-list/$date/";
  static String helperSlotException(String date) => "/user/helper-weekly-availability/slot-exception/$date/";
  static String helperSpecialDate(String date) => "/user/helper-weekly-availability/special-date/$date/";

  // ==================== Categories ====================
  static const categories = "/category/";
  static const subCategories = "/sub-category/";

  // ==================== Orders ====================
  static const customerOrders = "/order/customer/";
  static const providerOrders = "/order/provider/";
  static const orderCreate = "/order-create/";

  static String customerOrderDetail(int id) => "/order/customer/$id/";
  static String customerOrderAccept(int id) => "/order/customer/$id/accept/";
  static String customerOrderPayAndConfirm(int id) => "/order/customer/$id/pay-and-confirm/";
  static String customerOrderCounter(int id) => "/order/customer/$id/counter/";
  static String customerOrderProposeNewTime(int id) => "/order/customer/$id/propose-new-time/";
  static String customerOrderCancel(int id) => "/order/customer/$id/cancel/";
  static String customerOrderCancelAccept(int id) => "/order/customer/$id/cancel-accept/";
  static String customerOrderGiveFeedback(int id) => "/order/customer/$id/give-feedback/";

  static String providerOrderDetail(int id) => "/order/provider/$id/";
  static String providerOrderAccept(int id) => "/order/provider/$id/accept/";
  static String providerOrderCounter(int id) => "/order/provider/$id/counter/";
  static String providerOrderSetWorkHour(int id) => "/order/provider/$id/set-work-hour/";
  static String providerOrderProposeNewTime(int id) => "/order/provider/$id/propose-new-time/";
  static String providerOrderCancel(int id) => "/order/provider/$id/cancel/";
  static String providerOrderCancelAccept(int id) => "/order/provider/$id/cancel-accept/";
  static String providerOrderStartWork(int id) => "/order/provider/$id/start-work/";
  static String providerOrderComplete(int id) => "/order/provider/$id/complete/";
  static String providerOrderGiveFeedback(int id) => "/order/provider/$id/give-feedback/";

  // ==================== Helpers / Search ====================
  static const helpers = "/helper/";
  static const recommendedHelpers = "/user/recommended-helpers/";

  // ==================== Chat ====================
  static const startChat = "/room/start-chat/";
  static const customerRooms = "/room/customer/";
  static const providerRooms = "/room/provider/";
  static String roomMessages(int roomPk) => "/room/$roomPk/message/";
  static String roomMessagesByUuid(String role) => "/room/$role/message/";

  // ==================== Notifications ====================
  static const notifications = "/notifications/";
  static String notificationDetail(int id) => "/notifications/$id/";

  // ==================== Payments ====================
  static const customerPaymentMethods = "/user/customer/payment-methods/";
  static const providerPayoutMethods = "/user/provider/payout-methods/";
  static const paymentTransactions = "/payment-transaction/";

  // ==================== Vouchers ====================
  static const myVouchers = "/user/my-vouchers/";
  static const addVoucher = "/user/my-vouchers/add-voucher/";
  static const applyVoucher = "/vouchers/apply/";

  // ==================== Tickets ====================
  static const tickets = "/tickets/";
  static String ticketDetail(int id) => "/tickets/$id/";
  static String ticketReply(int id) => "/tickets/$id/reply/";
  static String ticketClose(int id) => "/tickets/$id/close/";

  // ==================== Reviews ====================
  static const reviews = "/review/";
  static const customerReviews = "/user/reviews/customer/";
  static const providerReviews = "/user/reviews/provider/";

  // ==================== Misc ====================
  static const activity = "/activity/";
  static const myReferralCode = "/my-referral-code/";
  static const myReferrals = "/user/my-referrals/";
  static const savedHelpers = "/user/customer/save-helper/";
  static const signupSlides = "/signup-slide/";
  static const customerScreens = "/customer-screen/";
}