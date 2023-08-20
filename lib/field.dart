import 'package:flutter/widgets.dart';

class RangedIntField extends Field<int> {
  int min;
  int max;
  RangedIntField(super.fieldName, super.value, {this.min = 0, this.max = 100});
  @override
  set value(int newValue) {
    if (newValue > max) {
      newValue = max;
    } else if (newValue < min) {
      newValue = min;
    }
    super.value = newValue;
  }
}

class ChoicesField<T> extends Field<T> {
  List<T> choices;
  T defaultValue;
  ChoicesField(String field, this.defaultValue, this.choices)
      : super(field, defaultValue);
  @override
  set value(T newValue) {
    if (!choices.contains(newValue)) {
      newValue = defaultValue;
    }
    super.value = newValue;
  }
}

class Field<T> extends ValueNotifier<T> {
  String fieldName;
  Field(this.fieldName, super.value);

  bool readFromObj(Map<String, dynamic>? obj) {
    if (obj != null && obj.containsKey(fieldName)) {
      try {
        value = obj[fieldName];
        return true;
      } catch (err) {}
    }
    return false;
  }
}
