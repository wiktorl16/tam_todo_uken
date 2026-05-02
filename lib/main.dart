import 'package:flutter/material.dart';
import 'task_repository.dart';

void main() {
  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String filter = "wszystkie";
  String selectedFilter = "wszystkie";

  @override
  Widget build(BuildContext context) {
    List<Task> filteredTasks = TaskRepository.tasks;

    if (selectedFilter == "wykonane") {
      filteredTasks = TaskRepository.tasks.where((task) => task.done).toList();
    } else if (selectedFilter == "do zrobienia") {
      filteredTasks = TaskRepository.tasks.where((task) => !task.done).toList();
    }

    final doneCount = filteredTasks.where((t) => t.done).length;

    return Scaffold(
        appBar: AppBar(
          title: Text(
            "KrakFlow",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.delete),
              color: TaskRepository.tasks.isEmpty ? Colors.grey : Colors.red,
              onPressed: TaskRepository.tasks.isEmpty
                  ? null
                  : () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Potwierdzenie"),
                            content: Text(
                              "Czy na pewno chcesz usunąć wszystkie zadania?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Anuluj"),
                              ),
                              TextButton(
                                onPressed: () {
                                  final messenger = ScaffoldMessenger.of(context);

                                  setState(() {
                                    TaskRepository.tasks.clear();
                                  });

                                  Navigator.pop(context);

                                  messenger.showSnackBar(
                                    const SnackBar(content: Text("Usunięto wszystkie zadania.")),
                                  );
                                },
                                child: Text("Usuń"),
                              ),
                            ],
                          );
                        },
                      );
                    },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ilość zadań: ${filteredTasks.length} (W tym wykonane: $doneCount)",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Dzisiejsze zadania",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              FilterBar(
                selectedFilter: selectedFilter,
                onFilterChanged: (value) {
                  setState(() {
                    selectedFilter = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    return Dismissible(
                      key: ValueKey(task.title),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        setState(() {
                          TaskRepository.tasks.remove(task);
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Usunięto zadanie: ${task.title}"),
                          ),
                        );
                      },
                      child: TaskCard(
                        title: filteredTasks[index].title,
                        subtitle:
                            "termin: ${filteredTasks[index].deadline} | priorytet: ${filteredTasks[index].priority}",
                        done: task.done,
                        onChanged: (value) {
                          setState(() {
                            task.done = value!;
                          });
                        },
                        onTap: () async {
                          final Task? updatedTask = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditTaskScreen(task: task),
                            ),
                          );
                          if (updatedTask != null) {
                            setState(() {
                              final originalIndex = TaskRepository.tasks
                                  .indexOf(task);
                              if (originalIndex != -1) {
                                TaskRepository.tasks[originalIndex] =
                                    updatedTask;
                              }
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              onPressed: () async {
                final Task? newTask = await Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        AddTaskScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                  ),
                );
                if (newTask != null) {
                  setState(() {
                    TaskRepository.tasks.add(newTask);
                  });
                }
              },
              child: Icon(Icons.add),
            );
          },
        ),
      );
  }
}

class FilterBar extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const FilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
          onPressed: () => onFilterChanged("wszystkie"),
          style: TextButton.styleFrom(
            foregroundColor: selectedFilter == "wszystkie"
                ? Colors.blue
                : Colors.black,
          ),
          child: const Text("Wszystkie"),
        ),
        TextButton(
          onPressed: () => onFilterChanged("do zrobienia"),
          style: TextButton.styleFrom(
            foregroundColor: selectedFilter == "do zrobienia"
                ? Colors.blue
                : Colors.black,
          ),
          child: const Text("Do zrobienia"),
        ),
        TextButton(
          onPressed: () => onFilterChanged("wykonane"),
          style: TextButton.styleFrom(
            foregroundColor: selectedFilter == "wykonane"
                ? Colors.blue
                : Colors.black,
          ),
          child: const Text("Wykonane"),
        ),
      ],
    );
  }
}

class AddTaskScreen extends StatelessWidget {
  AddTaskScreen({super.key});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Nowe zadanie",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Tytuł zadania",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: deadlineController,
              decoration: InputDecoration(
                labelText: "Termin",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: priorityController,
              decoration: InputDecoration(
                labelText: "Priorytet",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                final newTask = Task(
                  title: titleController.text,
                  deadline: deadlineController.text,
                  done: false,
                  priority: priorityController.text,
                );

                Navigator.pop(context, newTask);
              },
              child: Text("Zapisz"),
            ),
          ],
        ),
      ),
    );
  }
}

class EditTaskScreen extends StatelessWidget {
  final Task task;

  EditTaskScreen({super.key, required this.task});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    titleController.text = task.title;
    deadlineController.text = task.deadline;
    priorityController.text = task.priority;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edytuj zadanie",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Tytuł zadania",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: deadlineController,
              decoration: InputDecoration(
                labelText: "Termin",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: priorityController,
              decoration: InputDecoration(
                labelText: "Priorytet",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                final newTask = Task(
                  title: titleController.text,
                  deadline: deadlineController.text,
                  done: false,
                  priority: priorityController.text,
                );

                Navigator.pop(context, newTask);
              },
              child: Text("Zapisz"),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool done;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.done,
    this.onChanged,
    this.onTap,
  });

  Color getPriorityColor(String subtitle) {
    if (subtitle.toLowerCase().contains('wysoki')) {
      return Colors.red;
    } else if (subtitle.toLowerCase().contains('średni')) {
      return Colors.orange;
    } else if (subtitle.toLowerCase().contains('niski')) {
      return Colors.green;
    }
    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(value: done, onChanged: onChanged),
        title: Text(
          title,
          style: TextStyle(
            decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
            color: done ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: getPriorityColor(subtitle)),
        ),
        trailing: Icon(Icons.chevron_right),
      ),
    );
  }
}
