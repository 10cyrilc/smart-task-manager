class UserProfile {
  final String id;
  final String email;
  final String name;
  final DateTime createdAt;
  final String themeMode;

  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
    required this.themeMode,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map, String documentId) {
    return UserProfile(
      id: documentId,
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? 'Unknown',
      createdAt: map['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'].seconds * 1000)
          : DateTime.now(),
      themeMode: map['themeMode'] as String? ?? 'system',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'createdAt': createdAt,
      'themeMode': themeMode,
    };
  }
}
