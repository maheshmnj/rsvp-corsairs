import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rsvp/base_home.dart';
import 'package:rsvp/constants/constants.dart';
import 'package:rsvp/models/user.dart';
import 'package:rsvp/pages/authentication/signup.dart';
import 'package:rsvp/services/analytics.dart';
import 'package:rsvp/services/api/appstate.dart';
import 'package:rsvp/services/api/user.dart';
import 'package:rsvp/services/auth/authentication.dart';
import 'package:rsvp/services/database.dart';
import 'package:rsvp/themes/theme.dart';
import 'package:rsvp/utils/extensions.dart';
import 'package:rsvp/utils/logger.dart';
import 'package:rsvp/utils/navigator.dart';
import 'package:rsvp/utils/settings.dart';
import 'package:rsvp/utils/size_utils.dart';
import 'package:rsvp/utils/utility.dart';
import 'package:rsvp/widgets/button.dart';
import 'package:rsvp/widgets/textfield.dart';
import 'package:rsvp/widgets/widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AuthService auth = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final state = AppStateWidget.of(context);
    _responseNotifier.value = _responseNotifier.value.copyWith(
      state: RequestState.active,
      message: 'Signing in with Google...',
    );
    try {
      user = (await auth.signIn(user.email, user.password))!;
      if (user.email.isNotEmpty) {
        final existingUser = await UserService.findByUsername(
            username: user.email, isEmail: true);
        if (existingUser.email.isEmpty) {
          await Future.delayed(const Duration(seconds: 2));
          _responseNotifier.value = _responseNotifier.value.copyWith(
            state: RequestState.done,
            message: 'Registering new User',
          );
          Navigate.pushAndPopAll(
              context,
              SignUp(
                newUser: user,
                isGoogleSignUp: true,
              ));
        } else {
          _logger.d('found existing user ${user.email}');
          await Settings.setIsSignedIn(true, email: existingUser.email);
          await AuthService.updateLoginStatus(
              email: existingUser.email, isLoggedIn: true);
          state.setUser(existingUser.copyWith(isLoggedIn: true));
          _responseNotifier.value = _responseNotifier.value.copyWith(
              state: RequestState.done, didSucced: true, data: existingUser);
          Navigate.pushAndPopAll(context, const AdaptiveLayout());
          firebaseAnalytics.logSignIn(user);
        }
      } else {
        _responseNotifier.value = _responseNotifier.value.copyWith(
          state: RequestState.done,
          message: signInFailure,
        );
        showMessage(context, signInFailure);
        throw 'Sign in failed';
      }
    } catch (error) {
      showMessage(context, "Couldn't sign in with Google");
      _responseNotifier.value = _responseNotifier.value.copyWith(
        state: RequestState.done,
        message: error.toString(),
      );
      await Settings.setIsSignedIn(false);
    }
  }

  Future<void> _handleSignIn(BuildContext context) async {
    final state = AppStateWidget.of(context);
    try {
      _responseNotifier.value = _responseNotifier.value.copyWith(
        state: RequestState.active,
        message: 'Signing in User',
      );
      auth.signIn(user.email, user.password).then((signedInUser) async {
        if (signedInUser != null) {
          await Settings.setIsSignedIn(true, email: user.email);
          await AuthService.updateLoginStatus(
              email: user.email, isLoggedIn: true);
          state.setUser(user.copyWith(isLoggedIn: true));
          _responseNotifier.value = _responseNotifier.value.copyWith(
            state: RequestState.done,
            message: 'Signin response received',
          );
          // final resp = Response(didSucced: false, message: "Failed");
          // final json = user.schematoJson();
          // // TODO: User should be inserted into database only on email verification
          // final response = await DatabaseService.insertIntoTable(json,
          //     table: USER_TABLE_NAME);
          // if (response.status == 201) {
          //   resp.didSucced = true;
          //   resp.message = 'Success';
          // } else {
          //   await DatabaseService.insertIntoTable(json, table: USER_TABLE_NAME);
          //   // TODO: This should never happen otherwise we would have inconsistent data
          //   _logger.e('Failed to register new user');
          // }
          TextInput.finishAutofillContext(shouldSave: true);
          Navigate.pushAndPopAll(context, const AdaptiveLayout());
          firebaseAnalytics.logSignIn(user);
        } else {
          showMessage(context, 'Something went wrong');
        }
      }).onError((error, stackTrace) {
        showMessage(context, error.toString());
        _responseNotifier.value = _responseNotifier.value.copyWith(
          state: RequestState.done,
          message: error.toString(),
        );
      });
      // String userId = user.email.isEmpty ? user.studentId : user.email;
      // final existingUser = await UserService.findByUsername(
      //     username: userId, isEmail: user.email.isNotEmpty);
      // if (existingUser.email.isEmpty) {
      //   showMessage(context, 'Enter a valid username/password');
      //   _responseNotifier.value = _responseNotifier.value.copyWith(
      //       state: RequestState.done, didSucced: true, data: existingUser);
      // } else {
      //   _logger.d('found existing user ${user.email}');
      //   if (user.password == existingUser.password) {
      //     await Settings.setIsSignedIn(true, email: existingUser.email);
      //     await AuthService.updateLoginStatus(
      //         email: existingUser.email, isLoggedIn: true);
      //     state.setUser(existingUser.copyWith(isLoggedIn: true));
      //     Navigate.pushAndPopAll(context, const AdaptiveLayout());
      //     firebaseAnalytics.logSignIn(user);
      //   } else {
      //     _logger.e('Incorrect password entered');
      //     showMessage(context, 'Incorrect password');
      //     _responseNotifier.value = _responseNotifier.value.copyWith(
      //         state: RequestState.done, didSucced: true, data: existingUser);
      //   }
      // }
    } catch (error) {
      final existingUser =
          await UserService.findByUsername(username: user.email, isEmail: true);
      if (existingUser.email.isEmpty) {
        showMessage(context, 'New User please register');
        Navigate.push(
            context,
            SignUp(
              newUser: user,
            ));
      } else {
        showMessage(context, error.toString());
        _responseNotifier.value = Response.init();
        showMessage(context, '$error');
      }
      _responseNotifier.value = _responseNotifier.value.copyWith(
        state: RequestState.done,
        message: 'Create a new User',
      );
      await Settings.setIsSignedIn(false);
    }
  }

  bool _isValid() {
    for (final fieldKey in _formFieldKeys) {
      final FormFieldState? state = fieldKey.currentState;
      if (state == null || !state.isValid) {
        return false;
      }
    }
    return true;
  }

  @override
  void initState() {
    firebaseAnalytics = Analytics();
    super.initState();
  }

  @override
  void dispose() {
    _responseNotifier.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  final List<GlobalKey<FormFieldState>> _formFieldKeys =
      <GlobalKey<FormFieldState>>[
    GlobalKey<FormFieldState>(),
    GlobalKey<FormFieldState>(),
  ];
  final ValueNotifier<Response> _responseNotifier =
      ValueNotifier<Response>(Response.init());
  UserModel user = UserModel.init();
  late Analytics firebaseAnalytics;
  final Logger _logger = const Logger('LoginPage');
  bool isGoogleSignIn = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    SizeUtils.size = MediaQuery.of(context).size;
    return ValueListenableBuilder<Response>(
        valueListenable: _responseNotifier,
        builder: (BuildContext context, Response _response, Widget? child) {
          Widget _signInButton() {
            return Align(
                alignment: Alignment.center,
                child: CSButton(
                  width: 300,
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  leading: Image.asset(GOOGLE_ASSET_PATH, height: 32),
                  label: 'Sign In with Google',
                  isLoading:
                      isGoogleSignIn && _response.state == RequestState.active,
                  onTap: () {
                    auth.setAuthStrategy(GoogleAuthStrategy());
                    isGoogleSignIn = true;
                    _handleGoogleSignIn(context);
                  },
                ));
          }

          return IgnorePointer(
            ignoring: _response.state == RequestState.active,
            child: Scaffold(
              body: Container(
                decoration:
                    const BoxDecoration(color: CorsairsTheme.primaryBlue),
                padding: 16.0.horizontalPadding,
                child: AutofillGroup(
                  child: Form(
                    key: _formKey,
                    onChanged: () {
                      setState(() {});
                    },
                    child: ListView(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: SizeUtils.size.height * 0.12,
                        ),
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            'RSVP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        48.0.vSpacer(),
                        TransparentField(
                            fKey: _formFieldKeys[0],
                            hint: 'email',
                            controller: _emailController,
                            autoFillHints: const [AutofillHints.email],
                            index: Constants.USER_ID_VALIDATOR),
                        8.0.vSpacer(),
                        TransparentField(
                            fKey: _formFieldKeys[1],
                            hint: 'Password',
                            autoFillHints: const [AutofillHints.password],
                            controller: _passwordController,
                            index: Constants.PASSWORD_VALIDATOR),
                        const SizedBox(height: 20),
                        CSButton(
                            height: 48,
                            backgroundColor: CorsairsTheme.primaryYellow,
                            onTap: _isValid()
                                ? () {
                                    auth.setAuthStrategy(EmailAuthStrategy());
                                    removeFocus(context);
                                    TextInput.finishAutofillContext(
                                        shouldSave: true);
                                    isGoogleSignIn = false;
                                    final _email = _emailController.text.trim();
                                    final _password =
                                        _passwordController.text.trim();
                                    if (_email.isEmpty || _password.isEmpty) {
                                      showMessage(context,
                                          'Please enter valid crednetials');
                                      return;
                                    }
                                    user = user.copyWith(
                                        email:
                                            _email.contains('@') ? _email : '',
                                        password: _password,
                                        studentId:
                                            _email.contains('@') ? '' : _email,
                                        isLoggedIn: true);
                                    _handleSignIn(context);
                                  }
                                : null,
                            isLoading: !isGoogleSignIn &&
                                _response.state == RequestState.active,
                            label: 'Login'),
                        // new user sign up
                        48.0.vSpacer(),
                        RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(children: [
                              const TextSpan(
                                  text: 'Don\'t have an account? ',
                                  style: TextStyle(color: Colors.white)),
                              TextSpan(
                                  text: 'Sign Up',
                                  style: const TextStyle(
                                      color: CorsairsTheme.primaryYellow),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigate.push(context, const SignUp());
                                    })
                            ])),
                        SizedBox(
                          height: SizeUtils.size.height * 0.12,
                        ),
                        _signInButton()
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
