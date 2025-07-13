class RegisterRequestModel {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  final String role;

  const RegisterRequestModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role,
    };
  }
}
