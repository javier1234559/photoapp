import 'package:flutter/material.dart';

class DetailImageScreen extends StatelessWidget {
  final String imageUrl;

  const DetailImageScreen({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black for a dark theme
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              height: 100, // Height for the row of action buttons
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(10, (index) => _buildActionButton(index)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(int index) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.blue, // Set a color for the action button
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$index', // Display the index as a label for demonstration
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}