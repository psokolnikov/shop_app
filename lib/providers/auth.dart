import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/configuration.dart';

class Auth with ChangeNotifier {
  static const SIGNUP_URL =
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp';
  static const LOGIN_URL =
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword';

  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_token != null &&
        _expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now())) {
      return _token!;
    }

    return null;
  }

  String? get userId => _userId;

  Future<void> signup(String email, String password) async {
    final url = Uri.parse('$SIGNUP_URL?key=${Configuration().firebaseKey}');
    return _authenticate(url, email, password);
  }

  Future<void> login(String email, String password) async {
    final url = Uri.parse('$LOGIN_URL?key=${Configuration().firebaseKey}');
    return _authenticate(url, email, password);
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('userData')) {
      return false;
    }

    final exractedUserData = json.decode(prefs.getString('userData')!);
    final expiryDate = DateTime.parse(exractedUserData['expiryDate'] as String);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = exractedUserData['token'] as String;
    _userId = exractedUserData['userId'] as String;
    _expiryDate = expiryDate;

    notifyListeners();
    _autoLogout();

    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    notifyListeners();
  }

  void _autoLogout() {
    if (_expiryDate == null) return;

    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    Timer(Duration(seconds: timeToExpiry), logout);
  }

  Future<void> _authenticate(Uri url, String email, String password) async {
    final response = await http.post(
      url,
      body: json.encode(
          {'email': email, 'password': password, 'returnSecureToken': true}),
    );

    final responseData = json.decode(response.body);

    if (responseData['error'] != null) {
      throw HttpException(responseData['error']['message']);
    }

    _token = responseData['idToken'];
    _expiryDate = DateTime.now()
        .add(Duration(seconds: int.parse(responseData['expiresIn'])));
    _userId = responseData['localId'];
    _autoLogout();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode({ 'token': _token, 'userId': _userId, 'expiryDate': _expiryDate!.toIso8601String()});
    prefs.setString('userData', userData);
  }
}
