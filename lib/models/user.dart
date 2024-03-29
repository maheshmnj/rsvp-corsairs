import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rsvp/exports.dart';
import 'package:rsvp/models/event_schema.dart';
import 'package:uuid/uuid.dart';

part 'user.g.dart';

@JsonSerializable()
class UserModel extends ChangeNotifier {
  String? id;
  String? accessToken;
  // events hosted or attended by user
  List<EventModel> hosted;
  List<EventModel> bookmarks;
  String email;
  String name;
  String? avatarUrl;
  bool isLoggedIn;
  bool isAdmin;
  String username;
  String password;
  String studentId;
  int reputation;
  DateTime? created_at;

  UserModel(
      {this.id,
      this.name = '',
      this.email = '',
      this.avatarUrl,
      this.isAdmin = false,
      this.accessToken,
      this.username = '',
      this.created_at,
      this.studentId = '',
      this.password = '',
      this.reputation = 0,
      this.isLoggedIn = false,
      this.bookmarks = const [],
      this.hosted = const []});

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// todo: add created at parameter
  factory UserModel.copyWith(UserModel w) {
    return UserModel(
        id: w.id,
        name: w.name,
        email: w.email,
        avatarUrl: w.avatarUrl,
        accessToken: w.accessToken,
        isAdmin: w.isAdmin,
        username: w.username,
        password: w.password,
        studentId: w.studentId,
        created_at: w.created_at,
        isLoggedIn: w.isLoggedIn,
        bookmarks: w.bookmarks,
        reputation: w.reputation,
        hosted: w.hosted);
  }
  factory UserModel.schema(UserModel w) {
    return UserModel(
      name: w.name,
      email: w.email,
      avatarUrl: w.avatarUrl,
      accessToken: w.accessToken,
      isAdmin: w.isAdmin,
      username: w.username,
      password: w.password,
      studentId: w.studentId,
      created_at: w.created_at,
      isLoggedIn: w.isLoggedIn,
      reputation: w.reputation,
      bookmarks: w.bookmarks,
    );
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    String? idToken,
    String? accessToken,
    bool? isAdmin,
    bool? isLoggedIn,
    String? username,
    String? password,
    String? studentId,
    DateTime? created_at,
    int? reputation,
    List<EventModel>? bookmarks,
    List<EventModel>? hosted,
  }) {
    return UserModel(
        id: id ?? id,
        name: name ?? this.name,
        email: email ?? this.email,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        accessToken: accessToken ?? this.accessToken,
        isAdmin: isAdmin ?? this.isAdmin,
        username: username ?? this.username,
        password: password ?? this.password,
        studentId: studentId ?? this.studentId,
        created_at: created_at ?? this.created_at,
        isLoggedIn: isLoggedIn ?? this.isLoggedIn,
        bookmarks: bookmarks ?? this.bookmarks,
        reputation: reputation ?? this.reputation,
        hosted: hosted ?? this.hosted);
  }

  factory UserModel.init({String email = '', String name = '', String? id}) {
    final now = DateTime.now().toUtc();
    return UserModel(
        id: id ?? '',
        name: name,
        email: email,
        avatarUrl: '',
        accessToken: '',
        hosted: [],
        bookmarks: [],
        created_at: now,
        username: '',
        password: '',
        studentId: '',
        reputation: 0,
        isAdmin: false,
        isLoggedIn: false);
  }

  /// TODO: add a method to convert a User to JSON object
//  Map<String, dynamic> toJson() => {
//         'id': id,
//         'email': email,
//         'created_at': createdAt,
//         'last_sign_in_at': lastSignInAt,
//         'updated_at': updatedAt,
//       };

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  Map<String, dynamic> schematoJson() => <String, dynamic>{
        'id': const Uuid().v4(),
        'accessToken': accessToken,
        'email': email,
        'name': name,
        'avatarUrl': avatarUrl,
        'isLoggedIn': true,
        'isAdmin': isAdmin,
        'username': username,
        'studentId': studentId,
        'reputation': reputation,
        'created_at': created_at?.toIso8601String(),
      };
  Map<String, dynamic> signUpSchema() => <String, dynamic>{
        'id': const Uuid().v4(),
        'accessToken': accessToken,
        'email': email,
        'name': name,
        'avatarUrl': avatarUrl,
        'isLoggedIn': true,
        'isAdmin': isAdmin,
        'username': username,
        'password': password,
        'avatarUrl': avatarUrl ?? defaultAvatarUrl,
        'studentId': studentId,
        'reputation': reputation,
        'created_at': created_at?.toIso8601String(),
      };

  set setEmail(String m) {
    email = m;
    notifyListeners();
  }

  set setName(String m) {
    name = m;
    notifyListeners();
  }

  set setAccessToken(String m) {
    accessToken = m;
    notifyListeners();
  }

  set setAvatarUrl(String m) {
    avatarUrl = m;
    notifyListeners();
  }

  set setPassword(String m) {
    password = m;
    notifyListeners();
  }

  set setStudentId(String m) {
    studentId = m;
    notifyListeners();
  }

  set user(UserModel? user) {
    if (user == null) {
      avatarUrl = null;
      accessToken = null;
      name = '';
      email = '';
      username = '';
      password = '';
      isLoggedIn = false;
    } else {
      avatarUrl = user.avatarUrl;
      accessToken = user.accessToken;
      name = user.name;
      email = user.email;
      reputation = user.reputation;
      username = user.username;
      password = user.password;
      isLoggedIn = true;
    }
    notifyListeners();
  }
}
