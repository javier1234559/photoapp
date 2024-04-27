import 'package:flutter/material.dart';
import 'dart:io';

class AddAlbumScreen extends StatefulWidget {
  const AddAlbumScreen({super.key});

  @override
  State<AddAlbumScreen> createState() => _AddAlbumScreenState();
}

class _AddAlbumScreenState extends State<AddAlbumScreen> {
  List<File> _images = [];
  Future<void> Addnewalbum() async {
    String? newItem = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MyDialog();
      },
    );
    if (newItem != null) {
      print('Added item: $newItem');
      // Do something with the new item
    } else {
      print('No item added');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text("hello"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // Number of columns in the grid
              crossAxisSpacing: 4.0, // Spacing between columns
              mainAxisSpacing: 4.0, // Spacing between rows
            ),
            itemCount: 20,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return GestureDetector(
                  onTap: () async {
                    String? newItem = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return MyDialog();
                      },
                    );
                    // Handle the result of the dialog if needed
                  },
                  child: Container(
                    color: Colors.white, // Set container color to white
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add,
                          color: Colors.red, // Set icon color to red
                        ),
                        Text('Item $index'), // Add text below the icon
                      ],
                    ),
                  ),
                );
              } else {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("$index"),
                      Text('Item $index'),
                      // Display item index
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: Addnewalbum,
        tooltip: 'Pick Image',
        child: const Icon(Icons.add),
      ),
    ));
  }
}

class MyDialog extends StatefulWidget {
  const MyDialog({super.key});

  @override
  _MyDialogState createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  final TextEditingController _textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm album'),
      content: TextField(
        controller: _textFieldController,
        decoration: const InputDecoration(hintText: "Têm album"),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            String newItem = _textFieldController.text;
            if (newItem.isNotEmpty) {
              Navigator.of(context)
                  .pop(newItem); // Pass the new item back to the caller
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
