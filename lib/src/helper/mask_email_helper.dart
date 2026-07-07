class MaskEmailHelper {
  static String maskEmail(String email) {
    if (email.isEmpty || !email.contains('@')) return email;

    final parts = email.split('@');
    if (parts.length != 2) return email;

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 2) {
      return '${username[0]}***@$domain';
    }

    final visibleLength = (username.length / 2).ceil();
    final visiblePart = username.substring(0, visibleLength);
    final hiddenPart = '*' * (username.length - visibleLength);

    return '$visiblePart$hiddenPart@$domain';
  }
}
