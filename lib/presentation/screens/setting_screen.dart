import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photoapp/presentation/viewmodel/init_view_model.dart';

class SettingsScreen extends StatelessWidget {
  static String appBarName = "Setting";
  static String routeName = "/setting";


  const SettingsScreen({super.key});

 @override
 Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting'),
      ),
      body: Center(
        child: Consumer<InitViewModel>(
          builder: (context, viewModel, child) {
            return SwitchListTile(
              title: Text('Dark Mode'),
              value: viewModel.themeMode == ThemeMode.dark,
              onChanged: (bool value) {
                viewModel.toggleTheme(value);
              },
            );
          },
        ),
      ),
    );
 }
}
