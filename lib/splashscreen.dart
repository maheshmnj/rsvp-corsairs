import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/animate.dart';
import 'package:flutter_animate/effects/effects.dart';
import 'package:rsvp/base_home.dart';
import 'package:rsvp/constants/strings.dart';
import 'package:rsvp/models/user.dart';
import 'package:rsvp/navbar/pageroute.dart';
import 'package:rsvp/pages/authentication/login.dart';
import 'package:rsvp/pages/authentication/signup.dart';
import 'package:rsvp/services/api/appstate.dart';
import 'package:rsvp/themes/theme.dart';
import 'package:rsvp/utils/settings.dart';
import 'package:rsvp/utils/size_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    final session = SupabaseAuth.instance.initialSession;
    if (session == null) {
      Navigator.of(context).pushReplacement(PageRoutes.sharedAxis(
          const LoginPage(), SharedAxisTransitionType.scaled));
      return;
    } else {
      user ??= UserModel.init();
      user.email = _email;
      if (_email.isNotEmpty) {
        user.isLoggedIn = true;
        Settings.setSkipCount = count;
        AppStateWidget.of(context).setUser(user);
        Navigator.of(context, rootNavigator: true).pushReplacement(
            PageRoutes.sharedAxis(
                const AdaptiveLayout(), SharedAxisTransitionType.scaled));
      } else {
        user.isLoggedIn = false;
        AppStateWidget.of(context).setUser(user);
        if (count == 1) {
          Settings.setSkipCount = count;
          Navigator.of(context).pushReplacement(PageRoutes.sharedAxis(
              const SignUp(), SharedAxisTransitionType.scaled));
          return;
        }
        Navigator.of(context).pushReplacement(PageRoutes.sharedAxis(
            const LoginPage(), SharedAxisTransitionType.scaled));
        // if (count % 3 != 0) {
        //   Settings.setSkipCount = count;
        //   Navigate().pushReplace(context, const AdaptiveLayout());
        // } else {
        // }
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
              await Future.delayed(const Duration(milliseconds: 1500));
              handleNavigation();
            },
            effects: const [
              ShakeEffect(),
              FadeEffect(
                duration: Duration(milliseconds: 500),
                curve: Curves.easeIn,
              )
            ],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  SPLASH_PATH,
                  width: 200,
                ),
                title,
              ],
            ),
          )),
    );
  }
}
