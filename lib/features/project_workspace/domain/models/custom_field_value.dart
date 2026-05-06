class CustomFieldValue {
  const CustomFieldValue({
    required this.shotId,
    required this.columnId,
    this.textValue,
    this.numberValue,
    this.enumValue,
  });

  final String shotId;
  final String columnId;
  final String? textValue;
  final double? numberValue;
  final String? enumValue;

  Object? get value {
    if (textValue != null) {
      return textValue;
    }
    if (numberValue != null) {
      return numberValue;
    }
    return enumValue;
  }
}
