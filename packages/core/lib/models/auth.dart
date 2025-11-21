class AuthTokens {
  final String accessToken;
  final String refreshToken;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthTokens.fromJson(dynamic json) {
    return AuthTokens(
      accessToken: '${json['accessToken'] ?? ''}',
      refreshToken: '${json['refreshToken'] ?? ''}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}
