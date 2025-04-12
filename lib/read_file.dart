import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ReadFile extends StatefulWidget {
  static const routeName = "/read";
  const ReadFile({super.key});

  @override
  State<ReadFile> createState() => _ReadFileState();
}

class _ReadFileState extends State<ReadFile> {
  List<String> fileLines = [];
  String outputMessage = '';

  Future<void> _readFileContent() async {
    try {
      // Get the app-specific directory
      final directory = await getApplicationDocumentsDirectory();
      final appDir = Directory('${directory.path}/Os Scheduler');
      if (!appDir.existsSync()) {
        setState(() {
          outputMessage = 'Error: Directory not found.';
        });
        return;
      }

      // Define file path
      final filePath = '${appDir.path}/output.txt';

      // Check if the file exists
      final file = File(filePath);
      if (await file.exists()) {
        final content = await file.readAsLines();
        setState(() {
          fileLines = content;
          outputMessage = 'File loaded successfully.';
        });
      } else {
        setState(() {
          outputMessage = 'File not found at $filePath';
        });
      }
    } catch (e) {
      setState(() {
        outputMessage = 'Error reading file: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Process Generator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _readFileContent,
              child: Text('Load File'),
            ),
            SizedBox(height: 16),
            Text(
              outputMessage,
              style: TextStyle(fontSize: 16, color: Colors.green),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: fileLines.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(fileLines[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}