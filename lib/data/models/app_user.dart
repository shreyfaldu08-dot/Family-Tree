class AppUser {
  final String id;
  final String name;
  final String emailOrPhone;
  final String role; // 'admin' | 'user'
  final bool isBlocked;
  final String language;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.name,
    required this.emailOrPhone,
    required this.role,
    this.isBlocked = false,
    this.language = 'en',
    required this.createdAt,
  });

  AppUser copyWith({
    String? name,
    String? emailOrPhone,
    String? role,
    bool? isBlocked,
    String? language,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      emailOrPhone: emailOrPhone ?? this.emailOrPhone,
      role: role ?? this.role,
      isBlocked: isBlocked ?? this.isBlocked,
      language: language ?? this.language,
      createdAt: createdAt,
    );
  }
}
