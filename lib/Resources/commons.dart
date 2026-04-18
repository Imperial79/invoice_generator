import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:prime_invoice/Resources/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:prime_invoice/Essentials/Label.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'colors.dart';

const SizedBox width5 = SizedBox(width: 5);
const SizedBox width10 = SizedBox(width: 10);
const SizedBox width15 = SizedBox(width: 15);
const SizedBox width20 = SizedBox(width: 20);
const SizedBox height5 = SizedBox(height: 5);
const SizedBox height10 = SizedBox(height: 10);
const SizedBox height15 = SizedBox(height: 15);
const SizedBox height20 = SizedBox(height: 20);
const SizedBox height30 = SizedBox(height: 30);
SizedBox kHeight(double height) => SizedBox(height: height);
SizedBox kWidth(double width) => SizedBox(width: width);

Widget kDiv(BuildContext context) =>
    Divider(color: kColor(context).outlineVariant, thickness: .5);

systemColors(BuildContext context) {
  Brightness brightness = Theme.of(context).brightness;
  bool isDark = brightness == Brightness.dark;

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: isDark
          ? Brightness.light
          : Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
}

BorderRadius kRadius(double radius) => BorderRadius.zero;

Future<T?> navPush<T extends Object?>(BuildContext context, Widget screen) {
  return Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => screen),
  );
}

Future<T?> navPushReplacement<T extends Object?, TO extends Object?>(
  BuildContext context,
  Widget screen,
) {
  return Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => screen),
  );
}

Future<T?> navPopUntilPush<T extends Object?>(
  BuildContext context,
  Widget screen,
) {
  Navigator.popUntil(context, (route) => false);
  return navPush(context, screen);
}

KSnackbar(
  BuildContext context, {
  dynamic message,
  bool error = false,
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        bottom: MediaQuery.sizeOf(context).height - 100 > 0 ? MediaQuery.sizeOf(context).height - 100 : 0,
        left: MediaQuery.sizeOf(context).width > 400 ? MediaQuery.sizeOf(context).width - 350 : 20,
        right: 20,
      ),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: error ? StatusText.danger : StatusText.success,
      content: Row(
        spacing: 11,
        children: [
          Icon(
            error ? LucideIcons.circleAlert : LucideIcons.circleCheck,
            color: Colors.white,
          ),
          Flexible(
            child: Label(
              "$message",
              color: Colors.white,
            ).regular,
          ),
        ],
      ),
      action: action,
      dismissDirection: DismissDirection.horizontal,
    ),
  );
}

KErrorAlert(context, {required dynamic message}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: kColor(context).surface,
      title: Label("An Error Occurred!", color: kColor(context).error).title,
      icon: Icon(LucideIcons.circleAlert, color: kColor(context).error, size: 50),
      content: Label("$message", textAlign: TextAlign.center).regular,
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Label("Back").regular,
        ),
      ],
    ),
  );
}

Widget googleLoginButton(
  BuildContext context, {
  required void Function()? onPressed,
}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: kColor(context).surface,
      foregroundColor: kColor(context).onSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: kRadius(15),
        side: BorderSide(color: kColor(context).outlineVariant),
      ),
      padding: EdgeInsets.all(15),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 10,
      children: [
        SvgPicture.asset("$kIconPath/glogo.svg", height: 25),
        Label("Google", fontSize: 17, weight: 600).regular,
      ],
    ),
  );
}

Widget get kSmallLoading => Center(
  child: SizedBox(height: 30, width: 30, child: CircularProgressIndicator()),
);
