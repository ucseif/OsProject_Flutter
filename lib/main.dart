import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:os_project_unii/read_file.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(ProcessGeneratorApp());
}

class ProcessGeneratorApp extends StatelessWidget {
  const ProcessGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Process Generator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ProcessGeneratorScreen(),
      routes: {
        ReadFile.routeName : (_) => ReadFile(),
      },
    );
  }
}

class ProcessGeneratorScreen extends StatefulWidget {
  const ProcessGeneratorScreen({super.key});

  @override
  _ProcessGeneratorScreenState createState() => _ProcessGeneratorScreenState();
}

class _ProcessGeneratorScreenState extends State<ProcessGeneratorScreen> {
  final TextEditingController _processCountController = TextEditingController();
  final TextEditingController _arrivalTimeRangeController = TextEditingController();
  final TextEditingController _burstTimeRangeController = TextEditingController();
  List<Map<String, dynamic>> processes = [];
  String outputMessage = '';
  final Random _random = Random();

  // Function to parse range input (e.g., "2.5 , 6.9") into two numbers
  List<double>? _parseRange(String input) {
    try {
      // Remove spaces and split by comma
      final parts = input.split(',').map((part) => part.trim()).toList();
      if (parts.length != 2) return null;

      // Parse the two numbers
      final min = double.tryParse(parts[0]);
      final max = double.tryParse(parts[1]);

      if (min == null || max == null || min >= max) return null;
      return [min, max];
    } catch (e) {
      return null;
    }
  }

  // Function to generate random processes
  void _generateProcesses() {
    // Parse process count
    int processCount = int.tryParse(_processCountController.text) ?? 0;
    if (processCount <= 0) {
      setState(() {
        outputMessage = 'Please enter a valid number of processes.';
      });
      return;
    }

    // Parse arrival time range
    final arrivalTimeRange = _parseRange(_arrivalTimeRangeController.text);
    if (arrivalTimeRange == null) {
      setState(() {
        outputMessage = 'Invalid Arrival Time Range. Example: "1.3 , 9.2"';
      });
      return;
    }

    // Parse burst time range
    final burstTimeRange = _parseRange(_burstTimeRangeController.text);
    if (burstTimeRange == null) {
      setState(() {
        outputMessage = 'Invalid Burst Time Range. Example: "2.5 , 6.9"';
      });
      return;
    }

    // Generate processes
    processes.clear();
    for (int i = 1; i <= processCount; i++) {
      processes.add({
        'id': i,
        'arrivalTime': _randomDouble(arrivalTimeRange[0], arrivalTimeRange[1]),
        'burstTime': _randomDouble(burstTimeRange[0], burstTimeRange[1]),
        'priority': _randomInt(1, 15),
      });
    }

    setState(() {
      outputMessage = 'Generated ${processes.length} processes successfully!';
    });
  }

  // Helper function to generate random double
  double _randomDouble(double min, double max) {
    return min + (max - min) * _random.nextDouble();
  }

  // Helper function to generate random integer
  int _randomInt(int min, int max) {
    return min + _random.nextInt(max - min + 1);
  }

  // Function to save processes to output.txt in a specific directory
  Future<void> _saveToFile() async {
    if (processes.isEmpty) {
      setState(() {
        outputMessage = 'No processes to save. Please generate processes first.';
      });
      return;
    }

    try {
      // Get external storage directory
      final directory = await getApplicationDocumentsDirectory();
      final appDir = Directory('${directory.path}/Os Scheduler');
      if (!appDir.existsSync()) {
        appDir.createSync(recursive: true);
      }

      // Define file path
      final filePath = '${appDir.path}/output.txt';

      // Write data to file
      final file = File(filePath);
      final content = processes
          .map(
            (p) =>
        'Process ID: ${p['id']}, Arrival Time: ${p['arrivalTime'].toStringAsFixed(2)}, '
            'Burst Time: ${p['burstTime'].toStringAsFixed(2)}, Priority: ${p['priority']}',
      )
          .join('\n');

      await file.writeAsString(content);

      setState(() {
        outputMessage = 'Processes saved to $filePath';
      });
    } catch (e) {
      setState(() {
        outputMessage = 'Error saving file: $e';
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
            TextField(
              controller: _processCountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Number of Processes',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _burstTimeRangeController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Burst Time Range',
                hintText: 'Ex. 2.5 , 6.9',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _arrivalTimeRangeController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Arrival Time Range',
                hintText: 'Ex. 1.3 , 9.2',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generateProcesses,
              child: Text('Generate Processes'),
            ),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _saveToFile, child: Text('Save to File')),
            SizedBox(height: 16),
            ElevatedButton(onPressed: () => Navigator.pushNamed(context, ReadFile.routeName), child: Text('Read File')),
            SizedBox(height: 16),
            Text(
              outputMessage,
              style: TextStyle(fontSize: 16, color: Colors.green),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: processes.length,
                itemBuilder: (context, index) {
                  final process = processes[index];
                  return ListTile(
                    title: Text('Process ID: ${process['id']}'),
                    subtitle: Text(
                      'Arrival Time: ${process['arrivalTime'].toStringAsFixed(2)}, '
                          'Burst Time: ${process['burstTime'].toStringAsFixed(2)}, '
                          'Priority: ${process['priority']}',
                    ),
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