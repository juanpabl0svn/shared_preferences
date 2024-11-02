import 'package:flutter/material.dart';
import 'package:myapp/domain/models/user.dart';

class StateResult {
  final List<User> list;
  final bool isLoading;

  StateResult({
    required this.list,
    this.isLoading = false,
  });

  StateResult copyWith({
    List<User>? list,
    bool? isLoading,
  }) {
    return StateResult(
      list: list ?? this.list,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}