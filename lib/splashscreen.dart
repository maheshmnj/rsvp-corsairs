import 'package:flutter/material.dart';
import 'package:flutter_animate/animate.dart';
import 'package:flutter_animate/effects/effects.dart';
import 'package:rsvp/base_home.dart';
import 'package:rsvp/models/user.dart';
import 'package:rsvp/pages/login.dart';
import 'package:rsvp/services/api/appstate.dart';
import 'package:rsvp/themes/theme.dart';
import 'package:rsvp/utils/navigator.dart';
import 'package:rsvp/utils/settings.dart';
import 'package:rsvp/utils/size_utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  Future<void> handleNavigation() async {
    UserModel? user = AppStateScope.of(context).user;
    final String _email = await Settings.email;
    final int count = await Settings.skipCount + 1;
    user ??= UserModel.init();
    user.email = _email;
    if (_email.isNotEmpty) {
      user.isLoggedIn = true;
      AppStateWidget.of(context).setUser(user);
      Navigate().pushReplace(context, const AdaptiveLayout());
    } else {
      user.isLoggedIn = false;
      AppStateWidget.of(context).setUser(user);
      if (count % 3 != 0) {
        Settings.setSkipCount = count;
        Navigate().pushReplace(context, const AdaptiveLayout());
      } else {
        Navigate().pushReplace(context, const LoginPage());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeUtils.size = MediaQuery.of(context).size;
    Widget title = Text('Welcome\nCorsairs',
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .displayMedium!
            .copyWith(color: Colors.white));
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  CorsairsTheme.primaryYellow,
                  CorsairsTheme.primaryYellow,
                ]),
          ),
          alignment: Alignment.center,
          child: Animate(
            onComplete: (x) async {
              await Future.delayed(const Duration(milliseconds: 300));
              handleNavigation();
            },
            effects: const [SlideEffect(), ScaleEffect(), FadeEffect()],
            child: title,
          )),
    );
  }
}
