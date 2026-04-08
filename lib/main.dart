import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Task> tasks = [
      Task(title: "Przygotować prezentację", deadline: "jutro", done: true, priority: "wysoki"),
      Task(title: "Oddać raport z laboratoriów", deadline: "dzisiaj", done: true, priority: "wysoki"),
      Task(title: "Powtórzyć widgety Flutter", deadline: "w piątek", done: false, priority: "średni"),
      Task(title: "Napisać notatki do kolokwium", deadline: "w weekend", done: false, priority: "niski"),
    ];

    final doneCount = tasks.where((t) => t.done).length;

    return MaterialApp(
      title: 'KrakFlow',
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ilość zadań: ${tasks.length} (W tym wykonane: $doneCount)",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                "Dzisiejsze zadania",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return TaskCard(
                      title: tasks[index].title,
                      subtitle: "termin: ${tasks[index].deadline} | priorytet: ${tasks[index].priority}",
                      icon: tasks[index].done
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Task {
  final String title;
  final String deadline;
  final bool done;
  final String priority;

  Task({
    required this.title,
    required this.deadline,
    required this.done,
    required this.priority,
  });
}

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
