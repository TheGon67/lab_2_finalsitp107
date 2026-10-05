import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('taskBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task 86',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF2F2F0),

        colorScheme: const ColorScheme.light(
          primary: Color(0xFF111111),
          secondary: Color(0xFFC62828),
          surface: Colors.white,
          error: Color(0xFFD32F2F),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF111111),
          foregroundColor: Colors.white,
          elevation: 0,
        ),

        cardTheme: CardThemeData(
          color: const Color(0xFF2A2A2A),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC62828),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 20,
            ),
          ),
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFC62828),
          foregroundColor: Colors.white,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF2F2F0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Color(0xFF707070),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Color(0xFFC62828),
              width: 2,
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Box taskBox = Hive.box('taskBox');

  String formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  Future<void> addTask() async {
    final titleController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Row(
                children: [
                  Icon(
                    Icons.add_task,
                    color: Color(0xFFC62828),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'ADD TASK',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111111),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Task Title',
                      prefixIcon: Icon(Icons.task_alt),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.calendar_month,
                      color: Color(0xFFC62828),
                    ),
                    title: const Text(
                      'Task Date',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      formatDate(selectedDate),
                      style: const TextStyle(
                        color: Color(0xFF707070),
                      ),
                    ),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        setDialogState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(
                      color: Color(0xFF707070),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Color(0xFFC62828),
                          content: Text(
                            'Task title cannot be empty.',
                          ),
                        ),
                      );
                      return;
                    }

                    await taskBox.add({
                      'title': titleController.text.trim(),
                      'date': selectedDate.toIso8601String(),
                    });

                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('SAVE'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
  }

  Future<void> editTask(dynamic key, Map task) async {
    final titleController = TextEditingController(
      text: task['title'].toString(),
    );

    DateTime selectedDate =
        DateTime.tryParse(task['date'].toString()) ??
        DateTime.now();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Row(
                children: [
                  Icon(
                    Icons.edit,
                    color: Color(0xFFC62828),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'EDIT TASK',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111111),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Task Title',
                      prefixIcon: Icon(Icons.edit),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.calendar_month,
                      color: Color(0xFFC62828),
                    ),
                    title: const Text(
                      'Task Date',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      formatDate(selectedDate),
                      style: const TextStyle(
                        color: Color(0xFF707070),
                      ),
                    ),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        setDialogState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(
                      color: Color(0xFF707070),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Color(0xFFC62828),
                          content: Text(
                            'Task title cannot be empty.',
                          ),
                        ),
                      );
                      return;
                    }

                    await taskBox.put(key, {
                      'title': titleController.text.trim(),
                      'date': selectedDate.toIso8601String(),
                    });

                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('UPDATE'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
  }

  Future<void> deleteTask(dynamic key) async {
    await taskBox.delete(key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 18,
        title: const Row(
          children: [
            Text(
              'TASK',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(width: 8),
            Text(
              '86',
              style: TextStyle(
                color: Color(0xFFE53935),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 18),
            alignment: Alignment.center,
            child: const Text(
              'TO-DO',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 2,
                color: Color(0xFFF5C542),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),

      body: ValueListenableBuilder(
        valueListenable: taskBox.listenable(),
        builder: (context, Box box, widget) {
          if (box.isEmpty) {
            return const EmptyTaskView();
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  12,
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MY TASKS',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111111),
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Color(0xFFC62828),
                            thickness: 3,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          '86',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC62828),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    5,
                    16,
                    90,
                  ),
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    final key = box.keyAt(index);

                    final task = Map<String, dynamic>.from(
                      box.get(key),
                    );

                    final title = task['title'].toString();

                    final date =
                        DateTime.tryParse(
                          task['date'].toString(),
                        ) ??
                        DateTime.now();

                    return Dismissible(
                      key: ValueKey(key),
                      direction: DismissDirection.endToStart,

                      background: Container(
                        margin: const EdgeInsets.only(
                          bottom: 14,
                        ),
                        padding: const EdgeInsets.only(
                          right: 20,
                        ),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC62828),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),

                      onDismissed: (direction) {
                        deleteTask(key);

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            backgroundColor: Color(0xFF111111),
                            content: Text(
                              'TASK DELETED',
                            ),
                          ),
                        );
                      },

                      child: Container(
                        margin: const EdgeInsets.only(
                          bottom: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFC62828),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                ),
                              ),

                              Expanded(
                                child: ListTile(
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),

                                  leading: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF111111),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '86',
                                        style: TextStyle(
                                          color: Color(0xFFF5C542),
                                          fontWeight:
                                              FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),

                                  title: Text(
                                    title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  subtitle: Padding(
                                    padding:
                                        const EdgeInsets.only(
                                      top: 7,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 13,
                                          color: Color(0xFFF5C542),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          formatDate(date),
                                          style: const TextStyle(
                                            color:
                                                Color(0xFFBDBDBD),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Color(0xFFE53935),
                                    ),
                                    onPressed: () {
                                      editTask(
                                        key,
                                        task,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: addTask,
        icon: const Icon(Icons.add),
        label: const Text(
          'ADD TASK',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class EmptyTaskView extends StatelessWidget {
  const EmptyTaskView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  '86',
                  style: TextStyle(
                    color: Color(0xFFF5C542),
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'NO TASKS',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111111),
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Your task list is empty.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF707070),
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 25),

            Container(
              width: 80,
              height: 4,
              color: const Color(0xFFC62828),
            ),

            const SizedBox(height: 12),

            const Text(
              'READY',
              style: TextStyle(
                color: Color(0xFFC62828),
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
