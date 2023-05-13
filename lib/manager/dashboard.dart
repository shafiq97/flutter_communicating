import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/task.dart';

class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({super.key});

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  List<Task> _tasks = [];
  List<TaskSummary> _taskSummaries = [];
  int _employeeCount = 0;
  int _managerCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchUserCounts() async {
    final Uri uri = Uri.parse(
        'http://192.168.68.100/flutter_communicating_api/user_counts.php');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _employeeCount = data['employeeCount'];
        _managerCount = data['managerCount'];
      });
    } else {
      // Handle API errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Failed to fetch user counts')),
      );
    }
  }

  Future<void> _fetchTasks() async {
    final Uri uri = Uri.parse(
        'http://192.168.68.100/flutter_communicating_api/dashboard.php');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final tasks =
          List<Task>.from(data['tasks'].map((task) => Task.fromJson(task)));

      setState(() {
        _tasks = tasks;
        _taskSummaries = _summarizeTasks(tasks);
      });
    } else {
      // Handle API errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Failed to fetch tasks')),
      );
    }
  }

  List<TaskSummary> _summarizeTasks(List<Task> tasks) {
    final statusCounts = <String, int>{};

    // Count the tasks for each status
    for (final task in tasks) {
      statusCounts.update(task.status, (value) => value + 1, ifAbsent: () => 1);
    }

    // Create a TaskSummary object for each status count
    final summaries = statusCounts.entries.map((entry) {
      return TaskSummary(status: entry.key, count: entry.value);
    }).toList();

    return summaries;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Dashboard'),
      ),
      body: _taskSummaries.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Task Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: charts.BarChart(
                          _createChartSeries(),
                          animate: true,
                          domainAxis: const charts.OrdinalAxisSpec(
                            renderSpec: charts.SmallTickRendererSpec(
                              labelRotation: 45,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // const Text(
                      //   'User Summary',
                      //   style: TextStyle(
                      //     fontSize: 18,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                      // const SizedBox(height: 16),
                      // SizedBox(
                      //   height: 200, // Replace with your desired height
                      //   child: charts.PieChart(
                      //     _createUserSeries(),
                      //     animate: true,
                      //     defaultRenderer: charts.ArcRendererConfig(
                      //       arcRendererDecorators: [
                      //         charts.ArcLabelDecorator(
                      //           labelPosition: charts.ArcLabelPosition.inside,
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  List<charts.Series<TaskSummary, String>> _createChartSeries() {
    return [
      charts.Series<TaskSummary, String>(
        id: 'TaskSummary',
        data: _taskSummaries,
        domainFn: (TaskSummary summary, _) => summary.status,
        measureFn: (TaskSummary summary, _) => summary.count,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      ),
    ];
  }

  List<charts.Series<UserSummary, String>> _createUserSeries() {
    final List<UserSummary> userSummaries = [
      UserSummary(
        userType: 'Employees',
        count: _employeeCount,
        color: Colors.blue,
      ),
      UserSummary(
        userType: 'Managers',
        count: _managerCount,
        color: Colors.green,
      ),
    ];

    return [
      charts.Series<UserSummary, String>(
        id: 'UserSummary',
        data: userSummaries,
        domainFn: (UserSummary summary, _) => summary.userType,
        measureFn: (UserSummary summary, _) => summary.count,
        colorFn: (UserSummary summary, _) =>
            charts.ColorUtil.fromDartColor(summary.color),
        labelAccessorFn: (UserSummary summary, _) =>
            '${summary.userType}: ${summary.count}',
      ),
    ];
  }
}

class TaskSummary {
  final String status;
  final int count;

  TaskSummary({required this.status, required this.count});
}

class UserSummary {
  final String userType;
  final int count;
  final Color color;

  UserSummary({
    required this.userType,
    required this.count,
    required this.color,
  });
}
