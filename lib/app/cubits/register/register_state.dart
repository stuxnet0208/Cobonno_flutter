part of 'register_cubit.dart';

enum RegisterStatus { initial, submitting, success, error }

class RegisterState extends Equatable {
  final String email, password, name;
  final String? phoneNumber, invitationCode;
  final RegisterStatus status;

  const RegisterState(
      {required this.email,
      required this.password,
      required this.name,
      required this.status,
      this.invitationCode,
      this.phoneNumber});

  factory RegisterState.initial() {
    return const RegisterState(
      email: '',
      password: '',
      status: RegisterStatus.initial,
      name: '',
      invitationCode: null,
    );
  }

  RegisterState copyWith({
    String? email,
    String? password,
    String? name,
    String? phoneNumber,
    String? invitationCode,
    RegisterStatus? status,
  }) {
    return RegisterState(
        email: email ?? this.email,
        password: password ?? this.password,
        name: name ?? this.name,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        invitationCode: invitationCode ?? this.invitationCode,
        status: status ?? this.status);
  }

  @override
  List<Object?> get props => [email, password, name, phoneNumber, status, invitationCode];
}
