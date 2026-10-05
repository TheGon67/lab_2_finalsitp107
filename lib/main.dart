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
      title: 'Task Group 12',
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

        floatingActionButtonTheme:
            const FloatingActionButtonThemeData(
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

  Widget buildHeroSection(int taskCount) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        8,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TASK Group 12',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'YOUR TASKS',
                  style: TextStyle(
                    color: Color(0xFFBDBDBD),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$taskCount',
                  style: const TextStyle(
                    color: Color(0xFFE53935),
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'TOTAL TASKS',
                  style: TextStyle(
                    color: Color(0xFFF5C542),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.all(5),
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFC62828),
                width: 2,
              ),
            ),
            child: const Center(
              child: Text(
                'Group 12',
                style: TextStyle(
                  color: Color(0xFFF5C542),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
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
              'Group 12',
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
            return Column(
              children: [
                buildHeroSection(0),
                const Expanded(
                  child: EmptyTaskView(),
                ),
              ],
            );
          }

          return Column(
            children: [
              buildHeroSection(box.length),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  20,
                  12,
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
                          'Group 12',
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
                                    horizontal: 12,
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
                                        'Group 12',
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
                                    padding: const EdgeInsets.only(
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

                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          editTask(key, task);
                                        },
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Color(0xFFF5C542),
                                          size: 22,
                                        ),
                                      ),
                                      Container(
                                        width: 32,
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.arrow_back,
                                          color: Color(0xFFE53935),
                                          size: 27,
                                        ),
                                      ),
                                    ],
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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 70,
            color: Color(0xFF707070),
          ),
          SizedBox(height: 15),
          Text(
            'NO TASKS',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: Color(0xFF111111),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Add a task to get started',
            style: TextStyle(
              color: Color(0xFF707070),
            ),
          ),
        ],
      ),
    );
  }
}
