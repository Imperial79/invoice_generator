import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:invoice_generator/Resources/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:invoice_generator/Essentials/Label.dart';
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

Widget kDiv(BuildContext context) => Divider(
      color: kColor(context).outlineVariant,
      thickness: .5,
    );

systemColors(BuildContext context) {
  Brightness brightness = Theme.of(context).brightness;
  bool isDark = brightness == Brightness.dark;

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
}

BorderRadius kRadius(double radius) => BorderRadius.circular(radius);

Future<T?> navPush<T extends Object?>(BuildContext context, Widget screen) {
  return Navigator.push(
      context, MaterialPageRoute(builder: (context) => screen));
}

Future<T?> navPushReplacement<T extends Object?, TO extends Object?>(
    BuildContext context, Widget screen) {
  return Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => screen));
}

Future<T?> navPopUntilPush<T extends Object?>(
    BuildContext context, Widget screen) {
  Navigator.popUntil(context, (route) => false);
  return navPush(context, screen);
}

KSnackbar(
  context, {
  dynamic message,
  bool error = false,
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: kRadius(10)),
      backgroundColor: error ? kColor(context).error : kColor(context).primary,
      content: Row(
        spacing: 11,
        children: [
          Icon(
            error ? Icons.dangerous : Icons.check_circle_outline,
            color: error ? kColor(context).onError : kColor(context).onPrimary,
          ),
          Flexible(
            child: Label(
              "$message",
              color:
                  error ? kColor(context).onError : kColor(context).onPrimary,
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
      icon: Icon(
        Icons.dangerous,
        color: kColor(context).error,
        size: 50,
      ),
      content: Label("$message", textAlign: TextAlign.center).regular,
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Label(
            "Back",
          ).regular,
        ),
      ],
    ),
  );
}

Widget googleLoginButton(BuildContext context, {required void Function()? onPressed}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: kColor(context).surface,
      foregroundColor: kColor(context).onSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: kRadius(15),
        side: BorderSide(
          color: kColor(context).outlineVariant,
        ),
      ),
      padding: EdgeInsets.all(15),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 10,
      children: [
        SvgPicture.asset(
          "$kIconPath/glogo.svg",
          height: 25,
        ),
        Label("Google", fontSize: 17, weight: 600).regular,
      ],
    ),
  );
}

Widget get kSmallLoading => Center(
      child:
          SizedBox(height: 30, width: 30, child: CircularProgressIndicator()),
    );
