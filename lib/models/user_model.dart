class UserModel {
  final int? id;
  final String userName;
  final String dob;
  final String email;
  final String password;
  final String confirmPassword;
  final String? createdAt;
  final String? planType;
  final String? updatedAt;

  UserModel({
    this.id,
    required this.userName,
    required this.dob,
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.createdAt,
    this.planType,
    this.updatedAt,
  });

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'User_Name': userName,
      'Dob': dob,
      'Email': email,
      'Password': password,
      'Confirm_Password': confirmPassword,
      if (createdAt != null) 'Created_at': createdAt,
      if (planType != null) 'Plan_Type': planType,
      if (updatedAt != null) 'Updated_at': updatedAt,
    };
  }

  // Create from JSON response
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int?,
      userName: json['User_Name'] as String? ?? '',
      dob: json['Dob'] as String? ?? '',
      email: json['Email'] as String? ?? '',
      password: json['Password'] as String? ?? '',
      confirmPassword: json['Confirm_Password'] as String? ?? '',
      createdAt: json['Created_at'] as String?,
      planType: json['Plan_Type'] as String?,
      updatedAt: json['Updated_at'] as String?,
    );
  }

  // Copy with method for updates
  UserModel copyWith({
    int? id,
    String? userName,
    String? dob,
    String? email,
    String? password,
    String? confirmPassword,
    String? createdAt,
    String? planType,
    String? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      dob: dob ?? this.dob,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      createdAt: createdAt ?? this.createdAt,
      planType: planType ?? this.planType,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

