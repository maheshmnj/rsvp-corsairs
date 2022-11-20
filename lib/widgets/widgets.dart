import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rsvp/constants/const.dart';
import 'package:rsvp/main.dart';
import 'package:rsvp/services/analytics.dart';
import 'package:rsvp/themes/theme.dart';
import 'package:rsvp/utils/size_utils.dart';
import 'package:rsvp/utils/utility.dart';

void removeFocus(BuildContext context) => FocusScope.of(context).unfocus();

void showCircularIndicator(BuildContext context, {Color? color}) {
  removeFocus(context);
  showDialog<void>(
      barrierColor: color,
      context: context,
      barrierDismissible: false,
      builder: (x) => const LoadingWidget());
}

void stopCircularIndicator(BuildContext context) {
  Navigator.of(context).pop();
}

class LoadingWidget extends StatelessWidget {
  final Color? color;
  const LoadingWidget({Key? key, this.color}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
      color ?? CorsairsTheme.primaryColor,
    )));
  }
}

Widget hLine({Color? color, double height = 0.4}) {
  return Container(
    height: height,
    color: color ?? Colors.grey.withOpacity(0.5),
  );
}

Widget vLine({Color? color}) {
  return Container(
    width: 0.4,
    color: color ?? Colors.grey.withOpacity(0.5),
  );
}

SelectableText buildExample(String example, String word, {TextStyle? style}) {
  final textSpans = [const TextSpan(text: ' - ')];
  final iterable = example
      .split(' ')
      .toList()
      .map((e) => TextSpan(
          text: e + ' ',
          style: style ??
              TextStyle(
                  fontWeight: (e.toLowerCase().contains(word.toLowerCase()))
                      ? FontWeight.bold
                      : FontWeight.normal)))
      .toList();
  textSpans.addAll(iterable);
  textSpans.add(const TextSpan(text: '\n'));
  return SelectableText.rich(TextSpan(
      style: TextStyle(color: darkNotifier.value ? Colors.white : Colors.black),
      children: textSpans));
}

Widget storeRedirect(BuildContext context,
    {String redirectUrl = PLAY_STORE_URL,
    String assetUrl = 'assets/googleplay.png'}) {
  return GestureDetector(
    onTap: () {
      final firebaseAnalytics = Analytics();
      final width = MediaQuery.of(context).size.width;
      firebaseAnalytics.logRedirectToStore(
          width > SizeUtils.kTabletBreakPoint ? 'desktop' : 'mobile');
      launchURL(redirectUrl);
    },
    child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Image.asset(assetUrl, height: 50)),
  );
}

RichText buildNotification(String notification, String word,
    {TextStyle? style}) {
  final List<InlineSpan>? textSpans = [];
  final iterable = notification.split(' ').toList().map((e) {
    final isMatched = e.toLowerCase().contains(word.toLowerCase());
    return TextSpan(
        text: e + ' ',
        style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: isMatched ? FontWeight.bold : FontWeight.w400));
  }).toList();
  textSpans!.addAll(iterable);
  return RichText(text: TextSpan(text: '', children: textSpans));
}

Widget heading(String title) {
  return Text(
    title,
    style: const TextStyle(
      fontSize: 20,
      color: CorsairsTheme.primaryBlue,
      fontWeight: FontWeight.w600,
    ),
  );
}

Widget buildGradient(
    {Color top = Colors.transparent, Color bottom = Colors.black}) {
  return Positioned.fill(
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, bottom],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          tileMode: TileMode.mirror,
          stops: const [0.6, 0.95],
        ),
      ),
    ),
  );
}

class VersionBuilder extends StatelessWidget {
  final String version;
  const VersionBuilder({Key? key, this.version = ''}) : super(key: key);

  Future<String> getAppDetails() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version; // + ' (' + packageInfo.buildNumber + ')';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      alignment: Alignment.center,
      child: FutureBuilder<String>(
          future: getAppDetails(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            return snapshot.data == null
                ? Text(VERSION, style: Theme.of(context).textTheme.bodySmall)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('v', style: Theme.of(context).textTheme.bodySmall),
                      Text(snapshot.data!,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  );
          }),
    ));
  }
}
