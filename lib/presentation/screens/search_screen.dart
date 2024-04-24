import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  static String appBarName = "Search";
  static String routeName = "/search";
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
