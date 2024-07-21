extension SafetyCheckNull on String? {
  String safeValue([String value = ""]) {
    if (this == null) {
      return value;
    }
    return this!;
  }
}
