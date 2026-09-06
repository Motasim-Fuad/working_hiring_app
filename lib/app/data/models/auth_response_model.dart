class AuthResponse {
  final String access;
  final String refresh;
  final String? defaultProfile;


  const AuthResponse({
    required this.access,
    required this.refresh,
    this.defaultProfile,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      access: json['access'] as String,
      refresh: json['refresh'] as String,
      defaultProfile: json['default_profile'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access': access,
      'refresh': refresh,
      'default_profile': defaultProfile,
    };
  }
}
