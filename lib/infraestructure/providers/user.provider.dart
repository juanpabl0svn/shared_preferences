import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/domain/models/state-result.dart';
import 'package:myapp/domain/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

final userProvider = StateNotifierProvider<UserNotifier, StateResult>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<StateResult> {
  BuildContext? _context;

  UserNotifier() : super(StateResult(list: [])) {
    cleanAndGetFromCache();
  }

  void setContext(BuildContext context) {
    _context = context;
  }

  void deleteData() async {
    state = state.copyWith(list: []);
    saveUsersToPrefs();

    showAlert("Datos borrados en shared_preferences", () {});
  }

  void showAlert(String message, Function fn) {
    if (_context == null) return;

    final snackBar = SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: "Aceptar",
        onPressed: () {
          fn();
        },
      ),
      duration: const Duration(seconds: 10),
    );
    ScaffoldMessenger.of(_context!).showSnackBar(snackBar);
  }

  Future<void> fetchUsersFromApi() async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/users'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final users = data.map((userJson) => User.fromJson(userJson)).toList();
        state = state.copyWith(list: users);
        await saveUsersToPrefs();
        showAlert("Datos guardados en shared_preferences", () {});
      } else {
        throw Exception('Error al cargar usuarios');
      }
    } catch (e) {
      showAlert('Error al cargar usuarios: ${e.toString()}', () {});
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> saveUsersToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userJsonList =
        state.list.map((user) => json.encode(user.toJson())).toList();
    await prefs.setStringList('users', userJsonList);
  }

  Future<void> cleanAndGetFromCache() async {
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJsonList = prefs.getStringList('users') ?? [];

      await Future.delayed(const Duration(seconds: 3));

      if (userJsonList.isEmpty) {
        showAlert(
          "No hay nada guardado, ¿Quieres consultar la api?, da click en Aceptar o en el boton de buscar",
          () => fetchUsersFromApi(),
        );
        return;
      }

      final users = userJsonList
          .map((userJson) => User.fromJson(json.decode(userJson)))
          .toList();

      Future.delayed(const Duration(seconds: 5), () {
        state = state.copyWith(list: users);
      });
      showAlert("Datos cargados desde shared_preferences", () {});
    } catch (e) {
      showAlert('Error al cargar datos: ${e.toString()}', () {});
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
