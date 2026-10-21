sealed class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => message;
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.details});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(
    super.message, {
    super.code = 'UNAUTHORIZED',
    super.details,
  });
}

class MembershipPendingException extends AppException {
  const MembershipPendingException(
    super.message, {
    super.code = 'MEMBERSHIP_PENDING',
    super.details,
  });
}

class MembershipRevokedException extends AppException {
  const MembershipRevokedException(
    super.message, {
    super.code = 'MEMBERSHIP_REVOKED',
    super.details,
  });
}

class AncestryCycleException extends AppException {
  const AncestryCycleException(
    super.message, {
    super.code = 'ANCESTRY_CYCLE_DETECTED',
    super.details,
  });
}

class NotFoundException extends AppException {
  const NotFoundException(
    super.message, {
    super.code = 'NOT_FOUND',
    super.details,
  });
}
