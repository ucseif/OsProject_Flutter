import 'dart:io';
import 'package:flutter/material.dart';
import 'package:os_project_unii/core/theme/app_colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/services.dart';

class OsScheduler extends StatefulWidget {
  static const routeName = "/os_scheduler";
  const OsScheduler({super.key});

  @override
  State<OsScheduler> createState() => _OsSchedulerState();
}

class _OsSchedulerState extends State<OsScheduler> {
  List<Map<String, dynamic>> processes = [];
  final List<String> schedulers = ['FCFS', 'HPF', 'RR', 'SRTF'];

  String? selectedValue;
  String? descScheduler;
  void _handleCaseSelectioDesc(String? value){
    switch (value) {
      case 'FCFS':
        descScheduler =
        'This algorithm schedules processes based on their arrival time. The first process to arrive is the first to be executed, regardless of priority or burst time.';
        break;
      case 'HPF':
        descScheduler =
        'This non-preemptive algorithm selects the process with the highest priority to execute first. In case of a tie, the process that arrived first gets executed. Once a process starts, it runs to completion.';
        break;
      case 'RR':
        descScheduler =
        'A time quantum is assigned to each process. If a process doesn’t finish within that time, it is paused and the next process gets a turn. The cycle continues in a round-robin fashion.';
        break;
      case 'SRTF':
        descScheduler =
        'The process with the shortest remaining execution time is selected. If a new process arrives with a shorter burst time, it preempts the currently running process.';
        break;
    }
  }
  void _handleCaseSelection(String? value) {
    switch (value) {
      case 'FCFS':
        setState(() {
          descScheduler =
          'This algorithm schedules processes based on their arrival time. The first process to arrive is the first to be executed, regardless of priority or burst time.';
          _executeFCFS(context);
        });
        break;
      case 'HPF':
        descScheduler =
            'This non-preemptive algorithm selects the process with the highest priority to execute first. In case of a tie, the process that arrived first gets executed. Once a process starts, it runs to completion.';
        _executeHPF(context);
        break;
      case 'RR':
        descScheduler =
            'A time quantum is assigned to each process. If a process doesn’t finish within that time, it is paused and the next process gets a turn. The cycle continues in a round-robin fashion.';
        _executeRR(context);
        break;
      case 'SRTF':
        descScheduler =
            'The process with the shortest remaining execution time is selected. If a new process arrives with a shorter burst time, it preempts the currently running process.';
        _executeSRTF(context);
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFile(); // Automatically load file when entering the page

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.mainColorBg,
      ),
    );
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

  // Function to load file content automatically
  Future<void> _loadFile() async {
    try {
      // Get the app-specific directory
      final directory = await getApplicationDocumentsDirectory();
      final appDir = Directory('${directory.path}/Os Scheduler');
      if (!appDir.existsSync()) {
        _showToast(context, 'Error: Directory not found.');
        return;
      }

      // Define file path
      final filePath = '${appDir.path}/output.txt';

      // Check if the file exists
      final file = File(filePath);
      if (await file.exists()) {
        final content = await file.readAsLines();
        setState(() {
          processes =
              content.map((line) {
                final parts = line.split(', ');
                return {
                  'id': int.parse(parts[0].split(': ')[1]),
                  'arrivalTime': double.parse(parts[1].split(': ')[1]),
                  'burstTime': double.parse(parts[2].split(': ')[1]),
                  'priority': double.parse(parts[3].split(': ')[1]),
                };
              }).toList();

          // Sort processes by arrival time
          processes.sort(
            (a, b) => a['arrivalTime'].compareTo(b['arrivalTime']),
          );
          _showToast(context, 'File loaded successfully.');
        });
      } else {
        _showToast(context, 'File not found at $filePath');
      }
    } catch (e) {
      _showToast(context, 'Error reading file: $e');
    }
  }

  // Helper function to calculate completion, turnaround, and waiting times
  void _calculateProcessTimes(
    Map<String, dynamic> process,
    double currentTime,
  ) {
    process['completionTime'] = currentTime;
    process['turnaroundTime'] =
        process['completionTime'] - process['arrivalTime'];
    process['waitingTime'] = process['turnaroundTime'] - process['burstTime'];
  }

  // Function to execute Non-Preemptive Highest Priority First algorithm
  void _executeHPF(BuildContext context) {
    // Sort processes by priority (lowest value means highest priority)
    List<Map<String, dynamic>> sortedProcesses = List.from(processes)
      // ..sort((a, b) => a['priority'].compareTo(b['priority']));
      ..sort(
        (a, b) => b['priority'].compareTo(a['priority']),
      ); // Reverse sorting

    // Calculate start, completion, turnaround, and waiting times
    double currentTime = 0;
    for (var process in sortedProcesses) {
      process['startTime'] = currentTime;
      currentTime += process['burstTime'];
      _calculateProcessTimes(process, currentTime);
    }

    _showResultsInBottomSheet(context, sortedProcesses, 'Non-Preemptive HPF');
  }

  // Function to execute First Come First Serve algorithm
  void _executeFCFS(BuildContext context) {
    // Processes are already sorted by arrival time
    double currentTime = 0;
    for (var process in processes) {
      process['startTime'] = currentTime;
      currentTime += process['burstTime'];
      _calculateProcessTimes(process, currentTime);
    }

    _showResultsInBottomSheet(context, processes, 'FCFS');
  }

  // Function to execute Round Robin algorithm
  void _executeRR(BuildContext context) {
    double currentTime = 0;
    double quantum = 2.0; // Time quantum
    Map<int, double> remainingBurstTimes = {
      for (var p in processes) p['id']: p['burstTime'],
    };
    List<Map<String, dynamic>> completedProcesses = [];

    while (completedProcesses.length < processes.length) {
      bool idle = true;
      for (var process in processes) {
        if (remainingBurstTimes[process['id']]! > 0 &&
            process['arrivalTime'] <= currentTime) {
          idle = false;
          double executionTime =
              remainingBurstTimes[process['id']]! > quantum
                  ? quantum
                  : remainingBurstTimes[process['id']]!;
          remainingBurstTimes[process['id']] =
              remainingBurstTimes[process['id']]! - executionTime;
          currentTime += executionTime;

          if (remainingBurstTimes[process['id']]! == 0) {
            _calculateProcessTimes(process, currentTime);
            completedProcesses.add(process);
          }
        }
      }
      if (idle) {
        currentTime += 0.1; // Idle time
      }
    }

    _showResultsInBottomSheet(context, processes, 'Round Robin');
  }

  // Function to execute Preemptive Shortest Remaining Time First algorithm

  void _executeSRTF(BuildContext context) {
    double currentTime = 0;
    Map<int, double> remainingBurstTimes = {
      for (var p in processes) p['id']: p['burstTime'],
    };
    Map<int, double> startTimes = {};
    List<Map<String, dynamic>> completedProcesses = [];

    // ننسخ العمليات عشان نشتغل على نسخة خاصة ونمنع التعديل على القائمة الأصلية
    List<Map<String, dynamic>> processesCopy = processes
        .map((p) => Map<String, dynamic>.from(p))
        .toList();

    while (completedProcesses.length < processesCopy.length) {
      var availableProcesses = processesCopy
          .where((p) =>
      p['arrivalTime'] <= currentTime &&
          remainingBurstTimes[p['id']]! > 0)
          .toList();

      if (availableProcesses.isEmpty) {
        currentTime += 0.1;
        continue;
      }

      var currentProcess = availableProcesses.reduce((a, b) =>
      remainingBurstTimes[a['id']]! < remainingBurstTimes[b['id']]!
          ? a
          : b);

      double executionTime = 0.1;
      int id = currentProcess['id'];

      if (!startTimes.containsKey(id)) {
        startTimes[id] = currentTime;
      }

      remainingBurstTimes[id] = remainingBurstTimes[id]! - executionTime;
      currentTime += executionTime;

      if (remainingBurstTimes[id]! <= 0.0001) {
        currentProcess['completionTime'] = double.parse(currentTime.toStringAsFixed(2));
        currentProcess['startTime'] = startTimes[id];
        currentProcess['turnaroundTime'] =
            currentTime - currentProcess['arrivalTime'];
        currentProcess['waitingTime'] =
            currentProcess['turnaroundTime'] - currentProcess['burstTime'];

        // نضيف نسخة منفصلة من العملية إلى completedProcesses
        completedProcesses.add(Map<String, dynamic>.from(currentProcess));
      }
    }

    _showResultsInBottomSheet(context, completedProcesses, 'Preemptive SRTF');
  }



  // void _executeSRTF(BuildContext context) {
  //   double currentTime = 0;
  //   Map<int, double> remainingBurstTimes = {
  //     for (var p in processes) p['id']: p['burstTime'],
  //   };
  //   List<Map<String, dynamic>> completedProcesses = [];
  //
  //   while (completedProcesses.length < processes.length) {
  //     // Find the process with the shortest remaining burst time
  //     var availableProcesses =
  //         processes
  //             .where(
  //               (p) =>
  //                   p['arrivalTime'] <= currentTime &&
  //                   remainingBurstTimes[p['id']]! > 0,
  //             )
  //             .toList();
  //     if (availableProcesses.isEmpty) {
  //       currentTime += 0.1; // Idle time
  //       continue;
  //     }
  //
  //     var currentProcess = availableProcesses.reduce(
  //       (a, b) =>
  //           remainingBurstTimes[a['id']]! < remainingBurstTimes[b['id']]!
  //               ? a
  //               : b,
  //     );
  //     double executionTime = 0.1; // Execute in small intervals
  //     remainingBurstTimes[currentProcess['id']] =
  //         remainingBurstTimes[currentProcess['id']]! - executionTime;
  //     currentTime += executionTime;
  //
  //     if (remainingBurstTimes[currentProcess['id']]! == 0) {
  //       _calculateProcessTimes(currentProcess, currentTime);
  //       completedProcesses.add(currentProcess);
  //     }
  //   }
  //
  //   _showResultsInBottomSheet(context, processes, 'Preemptive SRTF');
  // }

  // Function to display results in a BottomSheet

  void _showResultsInBottomSheet(
    BuildContext context,
    List<Map<String, dynamic>> results,
    String algorithmName,
  ) {
    showModalBottomSheet(
      backgroundColor: AppColors.mainColorBg,
      context: context,
      isScrollControlled: true,
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$algorithmName Results',
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
                  SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Arrival')),
                        DataColumn(label: Text('Burst')),
                        DataColumn(label: Text('Start')),
                        DataColumn(label: Text('Completion')),
                        DataColumn(label: Text('Turnaround')),
                        DataColumn(label: Text('Waiting')),
                        DataColumn(label: Text('Priority')),
                      ],
                      rows:
                          results.map((process) {
                            return DataRow(
                              cells: [
                                DataCell(Text('${process['id']}')),
                                DataCell(Text('${process['arrivalTime']}')),
                                DataCell(Text('${process['burstTime']}')),
                                DataCell(
                                  Text(
                                    '${process['startTime']?.toStringAsFixed(2)}',
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${process['completionTime']?.toStringAsFixed(2)}',
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${process['turnaroundTime']?.toStringAsFixed(2)}',
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${process['waitingTime']?.toStringAsFixed(2)}',
                                  ),
                                ),
                                DataCell(Text('${process['priority']}')),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
                  SizedBox(height: 16),
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
      backgroundColor: AppColors.mainColorBg,
      body: Padding(
        padding: const EdgeInsets.only(left: 16, bottom: 16, right: 16, top: 8),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Os Scheduler',
                style: TextStyle(
                  fontSize: 26,
                  color: AppColors.creamyColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 20),
              DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  hint: const Text(
                    'Choose the algorithm',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  items:
                      schedulers
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                  value: selectedValue,
                  onChanged: (value) {
                    setState(() {
                      selectedValue = value;
                      _handleCaseSelectioDesc(value);
                    });
                  },
                  buttonStyleData: ButtonStyleData(
                    height: 52,
                    padding: const EdgeInsets.only(right: 16, left: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.mainColorBg,
                      border: Border.all(color: Colors.black45),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.grey.shade200,
                      //     blurRadius: 8,
                      //     offset: const Offset(0, 2),
                      //   ),
                      // ],
                    ),
                  ),
                  iconStyleData: const IconStyleData(
                    icon: Icon(Icons.keyboard_arrow_down_rounded),
                    iconSize: 24,
                    iconEnabledColor: Colors.grey,
                  ),
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.mainColorBg,
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.grey.shade100,
                      //     blurRadius: 10,
                      //   ),
                      // ],
                    ),
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    height: 48,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
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
                      onPressed: () => _handleCaseSelection(selectedValue),
                      child: Text('Select This Algorithm'),
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
                descScheduler ?? 'In this stage, the previously generated processes are scheduled using various algorithms to manage their execution order on the CPU. The goal is to improve performance by reducing waiting time and maximizing CPU efficiency. Each algorithm follows a different strategy to choose which process runs next.',
                style: TextStyle(fontSize: 16, color: Colors.black45),
              ),
              Spacer(),
              Center(
                child: Image.asset(
                  "assets/ecu_logo.png",
                  width: MediaQuery.of(context).size.width * 0.7,
                ),
              ),
              Spacer(),
              SizedBox(height: 40),

              // SizedBox(height: 16),
              // Expanded(
              //   child: ListView.builder(
              //     itemCount: processes.length,
              //     itemBuilder: (context, index) {
              //       final process = processes[index];
              //       return ListTile(
              //         title: Text('Process ID: ${process['id']}'),
              //         subtitle: Text(
              //           'Arrival Time: ${process['arrivalTime']}, '
              //           'Burst Time: ${process['burstTime']}, '
              //           'Priority: ${process['priority']}',
              //         ),
              //       );
              //     },
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
