import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invoice_generator/Essentials/Label.dart';
import 'package:invoice_generator/Essentials/kCard.dart';
import 'package:invoice_generator/Resources/colors.dart';
import 'package:invoice_generator/Resources/commons.dart';
import 'package:invoice_generator/Resources/constants.dart';
import 'package:invoice_generator/essentials/KScaffold.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HomeUI extends StatefulWidget {
  const HomeUI({super.key});

  @override
  State<HomeUI> createState() => _HomeUIState();
}

class _HomeUIState extends State<HomeUI> {
  @override
  Widget build(BuildContext context) {
    return KScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(kPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                LucideIcons.file,
                size: 30,
              ),
              height10,
              Label("Invoice Generator", fontSize: 20).title,
              height20,
              Label("Recent Invoices").regular,
              height10,
              ListView.separated(
                separatorBuilder: (context, index) => height15,
                itemCount: 10,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) => KCard(
                  padding: EdgeInsets.all(10),
                  color: Kolor.scaffold,
                  borderWidth: 1,
                  radius: 10,
                  child: Row(
                    spacing: 15,
                    children: [
                      KCard(
                        radius: 5,
                        height: 40,
                        width: 40,
                        padding: EdgeInsets.all(10),
                        child: FittedBox(child: Label("PDF").regular),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push("/create-invoice"),
        icon: Icon(Icons.add),
        elevation: 0,
        label: Label("Create").regular,
      ),
    );
  }
}
