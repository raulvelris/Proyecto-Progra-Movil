class User {
  final int userId;
  final String password;
  final String email;
  final bool isActive;
  final Client? client;

  User({
    required this.userId,
    required this.password,
    required this.email,
    required this.isActive,
    this.client,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['usuario_id'],
      password: json['clave'],
      email: json['correo'],
      isActive: json['isActive'],
      client: json['cliente'] != null ? Client.fromJson(json['cliente']) : null,
    );
  }
}

class Client {
  final int clientId;
  final String firstName;
  final String lastName;
  final String profilePicture;
  final int userId;

  Client({
    required this.clientId,
    required this.firstName,
    required this.lastName,
    required this.profilePicture,
    required this.userId,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      clientId: json['cliente_id'],
      firstName: json['nombre'],
      lastName: json['apellido'],
      profilePicture: json['fotoperfil'],
      userId: json['usuario_id'],
    );
  }

  String get fullName => '$firstName $lastName';
}