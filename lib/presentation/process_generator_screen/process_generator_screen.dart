import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:os_project_unii/core/theme/app_colors.dart';
import 'package:os_project_unii/presentation/scheduler_screen/os_scheduler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProcessGeneratorScreen extends StatefulWidget {
  static const routeName = "/process_generator_screen";
  const ProcessGeneratorScreen({super.key});

  @override
  _ProcessGeneratorScreenState createState() => _ProcessGeneratorScreenState();
}

class _ProcessGeneratorScreenState extends State<ProcessGeneratorScreen> {
  final TextEditingController _processCountController = TextEditingController();
  final TextEditingController _arrivalTimeRangeController =
      TextEditingController();
  final TextEditingController _burstTimeRangeController =
      TextEditingController();
  final TextEditingController _priorityController = TextEditingController();
  // final TextEditingController _quantumController = TextEditingController();

  List<Map<String, dynamic>> processes = [];
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

  void _showToast(BuildContext context, String msg) {
    Fluttertoast.showToast(
      msg: msg, // النص الذي سيظهر
      toastLength: Toast.LENGTH_SHORT, // LENGTH_SHORT أو LENGTH_LONG
      gravity: ToastGravity.BOTTOM, // مكان ظهور الرسالة (BOTTOM, TOP, CENTER)
      timeInSecForIosWeb: 3, // المدة الزمنية للظهور على iOS/Web
      backgroundColor: AppColors.mainColor, // لون الخلفية
      textColor: Colors.white, // لون النص
      fontSize: 14.0, // حجم الخط
    );
  }

  // Function to generate random priority values close to a specific value using Gaussian distribution
  double _randomPriority(double target, double stdDev, double min, double max) {
    // Generate a random value using Gaussian distribution
    double value;
    do {
      value =
          target +
          stdDev * _random.nextDouble() * (_random.nextBool() ? 1 : -1);
    } while (value < min ||
        value > max); // Ensure the value is within the specified range
    return value;
  }

  // Function to generate random processes and save them to file
  void _generateAndSaveProcesses() async {
    // Parse process count
    int processCount = int.tryParse(_processCountController.text) ?? 0;
    if (processCount <= 0) {
      _showToast(context, 'Please enter a valid number of processes.');
      return;
    }

    // Parse arrival time range
    final arrivalTimeRange = _parseRange(_arrivalTimeRangeController.text);
    if (arrivalTimeRange == null) {
      _showToast(context, 'Invalid Arrival Time Range. Example: "1.4 , 8.5"');
      return;
    }

    // Parse burst time range
    final burstTimeRange = _parseRange(_burstTimeRangeController.text);
    if (burstTimeRange == null) {
      _showToast(context, 'Invalid Burst Time Range. Example: "5.3 , 10"');
      return;
    }

    // Parse priority target value
    double priorityTarget =
        double.tryParse(_priorityController.text) ??
        7.9; // Default to 7.9 if empty
    const double priorityStdDev =
        1.0; // Standard deviation for Gaussian distribution
    const double priorityMin = 1.0; // Minimum priority value
    const double priorityMax = 15.0; // Maximum priority value

    // Generate processes
    processes.clear();
    for (int i = 1; i <= processCount; i++) {
      processes.add({
        'id': i,
        'arrivalTime': _randomDouble(arrivalTimeRange[0], arrivalTimeRange[1]),
        'burstTime': _randomDouble(burstTimeRange[0], burstTimeRange[1]),
        'priority': _randomPriority(
          priorityTarget,
          priorityStdDev,
          priorityMin,
          priorityMax,
        ),
      });
    }

    // Save processes to file
    await _saveToFile();
    _showToast(
      context,
      'Generated and saved ${processes.length} processes successfully!',
    );
  }

  // Helper function to generate random double
  double _randomDouble(double min, double max) {
    return min + (max - min) * _random.nextDouble();
  }

  // Function to save processes to output.txt in a specific directory
  Future<void> _saveToFile() async {
    if (processes.isEmpty) {
      _showToast(
        context,
        'No processes to save. Please generate processes first.',
      );
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
                'Burst Time: ${p['burstTime'].toStringAsFixed(2)}, Priority: ${p['priority'].toStringAsFixed(2)}',
          )
          .join('\n');
      await file.writeAsString(content);

      _showToast(context, 'Processes saved to $filePath');
    } catch (e) {
      _showToast(context, 'Error saving file: $e');
    }
  }

  // Function to show generated processes in a BottomSheet
  void _showGeneratedProcessesInBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: AppColors.mainColorBg,
      context: context,
      isScrollControlled: true, // Enable scrolling for the bottom sheet
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight:
                MediaQuery.of(context).size.height *
                0.9, // تحديد الحد الأقصى للارتفاع بنسبة 90%
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Generated Processes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(
                          label: Text(
                            'ID',
                            style: TextStyle(fontWeight: FontWeight.w300),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Arrival Time',
                            style: TextStyle(fontWeight: FontWeight.w300),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Burst Time',
                            style: TextStyle(fontWeight: FontWeight.w300),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Priority',
                            style: TextStyle(fontWeight: FontWeight.w300),
                          ),
                        ),
                      ],
                      rows:
                          processes.map((process) {
                            return DataRow(
                              cells: [
                                DataCell(Text('${process['id']}')),
                                DataCell(
                                  Text(
                                    '${process['arrivalTime'].toStringAsFixed(2)}',
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${process['burstTime'].toStringAsFixed(2)}',
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${process['priority'].toStringAsFixed(2)}',
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
                  SizedBox(height: 16),
                  // ElevatedButton(
                  //   onPressed: () => Navigator.pop(context),
                  //   child: Text('Close'),
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.mainColorBg,
      body: Padding(
        padding: const EdgeInsets.only(left: 16, bottom: 16, right: 16, top: 8),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Process Generator',
                    style: TextStyle(
                      fontSize: 26,
                      color: AppColors.creamyColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextField(
                controller: _processCountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Number of Processes',
                  labelStyle: TextStyle(color: Colors.black45),
                  floatingLabelStyle: TextStyle(color: AppColors.mainColor),
                  hintText: 'Enter a number',
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black45, width: 1.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.mainColor,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _arrivalTimeRangeController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Arrival Time Range',
                  labelStyle: TextStyle(color: Colors.black45),
                  floatingLabelStyle: TextStyle(color: AppColors.mainColor),
                  hintText: 'Ex. 1.4 , 8.5',
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black45, width: 1.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.mainColor,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _burstTimeRangeController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Burst Time Range',
                  labelStyle: TextStyle(color: Colors.black45),
                  floatingLabelStyle: TextStyle(color: AppColors.mainColor),
                  hintText: 'Ex. 5.3 , 10',
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black45, width: 1.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.mainColor,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _priorityController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Priority Target',
                  labelStyle: TextStyle(color: Colors.black45),
                  floatingLabelStyle: TextStyle(color: AppColors.mainColor),
                  hintText: 'Ex. 7.9',
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black45, width: 1.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.mainColor,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        backgroundColor: AppColors.mainColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                      onPressed: _generateAndSaveProcesses,
                      child: Text('Generate Processes'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        backgroundColor: AppColors.mainColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                      onPressed:
                          () => _showGeneratedProcessesInBottomSheet(context),
                      child: Text('View Processes'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        backgroundColor: AppColors.mainColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                      onPressed:
                          () => Navigator.pushNamed(
                            context,
                            OsScheduler.routeName,
                          ),
                      child: Text('OS Scheduler'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Description : ',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'In this page, a set of processes is randomly generated based on the input values such as number of processes, arrival time range, burst time range, and priority target. After entering the data, you can click "Generate Processes" to create the processes, view them using "View Processes", then move to schedule them using "OS Scheduler".',
                style: TextStyle(fontSize: 16, color: Colors.black45),
              ),
              SizedBox(height: 15),
              Text(
                'After generating the processes, they are stored internally to be used later in scheduling. Each process includes an arrival time, burst time, and priority, all randomly calculated based on your input values.',
                style: TextStyle(fontSize: 16, color: Colors.black45),
              ),
              // Spacer(),
              SizedBox(height: 15,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(
                    "assets/ecu_logo.png",
                    width: MediaQuery.of(context).size.width * 0.2,
                  ),
                ],
              ),
              // Spacer(),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
