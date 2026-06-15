import 'package:flutter/material.dart';
import 'app_bar_widget.dart';
import 'app_drawer.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.showAppBar = true,
    this.showDrawer = true,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  final Widget body;
  final String? title;
  final bool showAppBar;
  final bool showDrawer;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? NasamAppBar(
              title: title ?? '',
              showLeading: showDrawer,
            )
          : null,
      drawer: showDrawer ? const AppDrawer() : null,
      body: SafeArea(
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
