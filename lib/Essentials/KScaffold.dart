import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../Resources/colors.dart';
import '../Resources/commons.dart';
import '../Resources/constants.dart';
import 'Label.dart';
import 'kCard.dart';

// ignore: must_be_immutable
class KScaffold extends StatelessWidget {
  PreferredSizeWidget? appBar;
  final Widget body;
  FloatingActionButtonLocation? floatingActionButtonLocation;
  FloatingActionButtonAnimator? floatingActionButtonAnimator;
  Widget? floatingActionButton;
  Widget? bottomNavigationBar;
  ValueListenable<dynamic>? isLoading;
  List<Widget>? persistentFooterButtons;
  final Color? color;
  final Color? borderColor;
  KScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.isLoading,
    this.floatingActionButtonAnimator,
    this.floatingActionButtonLocation,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.persistentFooterButtons,
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    systemColors(context);
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: isLoading ?? ValueNotifier(false),
        builder: (context, loading, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Scaffold(
                persistentFooterButtons: persistentFooterButtons,
                appBar: appBar,
                body: SizedBox(
                  height: double.maxFinite,
                  width: double.maxFinite,
                  child: body,
                ),
                floatingActionButtonAnimator: floatingActionButtonAnimator,
                floatingActionButtonLocation: floatingActionButtonLocation,
                floatingActionButton: floatingActionButton,
                bottomNavigationBar: bottomNavigationBar,
              ),
              _fullLoading(context, isLoading: loading),
            ],
          );
        },
      ),
    );
  }

  AnimatedSwitcher _fullLoading(
    BuildContext context, {
    required bool isLoading,
  }) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 200),
      child: isLoading
          ? Container(
              height: double.maxFinite,
              width: double.maxFinite,
              color: kColor(context).surface.withAlpha(200),
              child: Center(
                child: KCard(
                  width: 300,
                  color: color ?? kColor(context).surfaceContainerLow,
                  padding: const EdgeInsets.all(30),
                  borderColor: borderColor ?? kColor(context).outlineVariant,
                  borderWidth: borderColor != null ? 1 : 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 25,
                        width: 25,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          backgroundColor: kColor(
                            context,
                          ).surfaceContainerHighest,
                          color: kColor(context).primary,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Label(
                        "Please Wait",
                        fontSize: 17,
                        weight: 550,
                        color: kColor(context).onSurface,
                      ).title,
                    ],
                  ),
                ),
              ),
            )
          : const SizedBox(),
    );
  }
}

AppBar KAppBar(
  BuildContext context, {
  IconData? icon,
  String title = "",
  Widget? child,
  bool showBack = true,
  List<Widget>? actions,
}) {
  return AppBar(
    automaticallyImplyLeading: false,
    titleSpacing: showBack ? 0 : kPadding,
    leadingWidth: 50,
    surfaceTintColor: kColor(context).surface,
    backgroundColor: kColor(context).surface,
    leading: showBack
        ? Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(LucideIcons.chevronLeft, size: 20),
            ),
          )
        : null,
    title: child ?? Label(title, fontSize: 18, weight: 600).title,
    actions: actions,
  );
}
