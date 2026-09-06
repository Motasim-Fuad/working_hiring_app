import '../../service/api_service.dart';
import '../../service/api_url.dart';
import '../models/auth_response_model.dart';

class AuthRepository {
  final ApiClient _client;

  AuthRepository(this._client);

  String _fullUrl(String path) => '${ApiUrl.baseUrl}$path';

  /// Login with email + password.
  Future<AuthResponse> loginWithPassword(String email, String password) async {
    final response = await _client.post(
      url: _fullUrl(ApiUrl.loginWithPassword),
      isBasic: true,
      body: {'email': email, 'password': password},
    );
    final data = parseApiResponse(response);
    return AuthResponse.fromJson(data as Map<String, dynamic>);
  }

  /// Request OTP for login. [contact] should be phone or email.
  Future<String> requestLoginOtp(String contact, {bool isEmail = true}) async {
    final field = isEmail ? 'email' : 'phone';
    final response = await _client.post(
      url: _fullUrl(ApiUrl.requestLoginOtp),
      isBasic: true,
      body: {field: contact},
    );
    parseApiResponse(response); // just check status
    return contact;
  }

  /// Verify login OTP.
  Future<AuthResponse> verifyLoginOtp(String contact, String otp,
      {bool isEmail = true}) async {
    final field = isEmail ? 'email' : 'phone';
    final response = await _client.post(
      url: _fullUrl(ApiUrl.verifyLoginOtp),
      isBasic: true,
      body: {field: contact, 'otp': otp},
    );
    final data = parseApiResponse(response);
    return AuthResponse.fromJson(data as Map<String, dynamic>);
  }

  /// Register a new user. Backend sends OTP to email.
  Future<void> signUp(Map<String, dynamic> signUpData) async {
    final response = await _client.post(
      url: _fullUrl(ApiUrl.signUp),
      isBasic: true,
      body: signUpData,
    );
    parseApiResponse(response);
  }

  /// Verify signup OTP and get tokens.
  Future<AuthResponse> verifySignUp(String contact, String otp,
      {bool isEmail = true}) async {
    final field = isEmail ? 'email' : 'phone';
    final response = await _client.post(
      url: _fullUrl(ApiUrl.signUpVerify),
      isBasic: true,
      body: {field: contact, 'otp': otp},
    );
    final data = parseApiResponse(response);
    return AuthResponse.fromJson(data as Map<String, dynamic>);
  }

  /// Resend signup OTP.
  Future<void> resendSignUpOtp(String email) async {
    final response = await _client.post(
      url: _fullUrl(ApiUrl.signUpResendOtp),
      isBasic: true,
      body: {'email': email},
    );
    parseApiResponse(response);
  }

  /// Google social login. [accessToken] is the Google OAuth token.
  Future<AuthResponse> googleLogin(String accessToken) async {
    final response = await _client.post(
      url: _fullUrl(ApiUrl.googleLogin),
      isBasic: true,
      body: {'access_token': accessToken},
    );
    final data = parseApiResponse(response);
    return AuthResponse.fromJson(data as Map<String, dynamic>);
  }

  /// Apple social login.
  Future<AuthResponse> appleLogin(String accessToken) async {
    final response = await _client.post(
      url: _fullUrl(ApiUrl.appleLogin),
      isBasic: true,
      body: {'access_token': accessToken},
    );
    final data = parseApiResponse(response);
    return AuthResponse.fromJson(data as Map<String, dynamic>);
  }

  /// Refresh the JWT access token.
  Future<AuthResponse> refreshToken(String refresh) async {
    final response = await _client.post(
      url: _fullUrl(ApiUrl.refreshToken),
      isBasic: true,
      body: {'refresh': refresh},
    );
    final data = parseApiResponse(response);
    return AuthResponse.fromJson(data as Map<String, dynamic>);
  }

  /// Verify a token is valid.
  Future<bool> verifyToken(String token) async {
    final response = await _client.post(
      url: _fullUrl(ApiUrl.verifyToken),
      isBasic: true,
      body: {'token': token},
    );
    final body = response.body;
    return body is Map && body['status'] == true;
  }

  /// Change password (requires auth).
  Future<void> changePassword(
    String oldPassword,
    String newPassword,
    String confirmNewPassword,
  ) async {
    final response = await _client.post(
      url: _fullUrl(ApiUrl.changePassword),
      body: {
        'old_password': oldPassword,
        'new_password': newPassword,
        'confirm_new_password': confirmNewPassword,
      },
    );
    parseApiResponse(response);
  }

  /// Request password reset OTP.
  Future<void> requestPasswordReset(String email) async {
    final response = await _client.post(
      url: _fullUrl(ApiUrl.passwordResetRequest),
      isBasic: true,
      body: {'email': email},
    );
    parseApiResponse(response);
  }

  /// Confirm password reset with OTP.
  Future<void> confirmPasswordReset(
    String contact,
    String otp,
    String newPassword, {
    bool isEmail = true,
  }) async {
    final field = isEmail ? 'email' : 'phone';
    final response = await _client.post(
      url: _fullUrl(ApiUrl.passwordResetConfirm),
      isBasic: true,
      body: {field: contact, 'otp': otp, 'new_password': newPassword},
    );
    parseApiResponse(response);
  }
}
