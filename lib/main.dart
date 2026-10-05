import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('todoBox');

  runApp(const MyApp());
}

const Color backgroundColor = Color(0xFF0B0D12);
const Color surfaceColor = Color(0xFF181B23);
const Color cardColor = Color(0xFF20242D);

const Color cyanColor = Color(0xFF5DE7E1);
const Color orangeColor = Color(0xFFFFB45C);
const Color pinkColor = Color(0xFFD86BFF);

const Color primaryText = Color(0xFFF4F5F7);
const Color secondaryText = Color(0xFFA8ADB8);
const Color borderColor = Color(0xFF303540);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do List',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: const ColorScheme.dark(
          primary: cyanColor,
          secondary: pinkColor,
          surface: surfaceColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundColor,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceColor,
          labelStyle: const TextStyle(
            color: secondaryText,
          ),
          hintStyle: const TextStyle(
            color: secondaryText,
          ),
          prefixIconColor: cyanColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(14),
            ),
            borderSide: BorderSide(
              color: borderColor,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(14),
            ),
            borderSide: BorderSide(
              color: borderColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(14),
            ),
            borderSide: BorderSide(
              color: cyanColor,
              width: 2,
            ),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Box todoBox = Hive.box('todoBox');

  String formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> addTask() async {
    final titleController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: surfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: const Text(
                'Add New Task',
                style: TextStyle(
                  color: primaryText,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      style: const TextStyle(
                        color: primaryText,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Task Title',
                        hintText: 'Enter your task...',
                        prefixIcon: Icon(
                          Icons.check_circle_outline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: cyanColor,
                                  secondary: pinkColor,
                                  surface: surfaceColor,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (pickedDate != null) {
                          setDialogState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: borderColor,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: cyanColor,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Task Date',
                                  style: TextStyle(
                                    color: secondaryText,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  formatDate(selectedDate),
                                  style: const TextStyle(
                                    color: primaryText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.chevron_right,
                              color: secondaryText,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                16,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: secondaryText,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cyanColor,
                    foregroundColor: backgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final title = titleController.text.trim();

                    if (title.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Task title cannot be empty.',
                          ),
                        ),
                      );
                      return;
                    }

                    await todoBox.add({
                      'title': title,
                      'date': selectedDate.toIso8601String(),
                    });

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Task added successfully.',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Add Task',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
  }

  Future<void> editTask(
    int index,
    Map task,
  ) async {
    final titleController = TextEditingController(
      text: task['title'] ?? '',
    );

    DateTime selectedDate =
        DateTime.tryParse(
              task['date'] ?? '',
            ) ??
            DateTime.now();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: surfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: const Text(
                'Edit Task',
                style: TextStyle(
                  color: primaryText,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      style: const TextStyle(
                        color: primaryText,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Task Title',
                        prefixIcon: Icon(
                          Icons.edit_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: cyanColor,
                                  secondary: pinkColor,
                                  surface: surfaceColor,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (pickedDate != null) {
                          setDialogState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: borderColor,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: cyanColor,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Task Date',
                                  style: TextStyle(
                                    color: secondaryText,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  formatDate(selectedDate),
                                  style: const TextStyle(
                                    color: primaryText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: secondaryText,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cyanColor,
                    foregroundColor: backgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final title = titleController.text.trim();

                    if (title.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Task title cannot be empty.',
                          ),
                        ),
                      );
                      return;
                    }

                    await todoBox.put(index, {
                      'title': title,
                      'date': selectedDate.toIso8601String(),
                    });

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Task updated successfully.',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
  }

  Widget buildTaskCard(
    int index,
    Map task,
  ) {
    final String title =
        task['title']?.toString() ?? 'Untitled Task';

    final DateTime date =
        DateTime.tryParse(
              task['date']?.toString() ?? '',
            ) ??
            DateTime.now();

    return Dismissible(
      key: ValueKey(
        '${todoBox.keyAt(index)}-$title',
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              backgroundColor: surfaceColor,
              title: const Text(
                'Delete Task?',
                style: TextStyle(
                  color: primaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                'Delete "$title"?',
                style: const TextStyle(
                  color: secondaryText,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: secondaryText,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pinkColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(dialogContext, true);
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) async {
        await todoBox.deleteAt(index);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Task deleted successfully.',
              ),
            ),
          );
        }
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.only(right: 24),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: pinkColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 28,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: borderColor,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            editTask(index, task);
          },
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: cyanColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: cyanColor.withOpacity(0.35),
                    ),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: cyanColor,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: primaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: orangeColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            formatDate(date),
                            style: const TextStyle(
                              color: secondaryText,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Edit task',
                  onPressed: () {
                    editTask(index, task);
                  },
                  icon: const Icon(
                    Icons.more_horiz,
                    color: secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "To-Do's",
          style: TextStyle(
            color: primaryText,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: surfaceColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
              ),
            ),
            child: const Icon(
              Icons.checklist_rounded,
              color: cyanColor,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: todoBox.listenable(),
          builder: (
            context,
            Box box,
            child,
          ) {
            if (box.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: cyanColor.withOpacity(0.10),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: cyanColor.withOpacity(0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.checklist_rounded,
                          color: cyanColor,
                          size: 45,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'No tasks yet',
                        style: TextStyle(
                          color: primaryText,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add your first task to get started.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                18,
                8,
                18,
                100,
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  margin: const EdgeInsets.only(
                    bottom: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF183C43),
                        Color(0xFF24212F),
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(20),
                    border: Border.all(
                      color: borderColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: cyanColor.withOpacity(0.12),
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.today_outlined,
                          color: cyanColor,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your Tasks',
                              style: TextStyle(
                                color: primaryText,
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${box.length} task${box.length == 1 ? '' : 's'} saved locally',
                              style: const TextStyle(
                                color: secondaryText,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${box.length}',
                        style: const TextStyle(
                          color: cyanColor,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    left: 4,
                    bottom: 12,
                  ),
                  child: Text(
                    'All Tasks',
                    style: TextStyle(
                      color: primaryText,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...List.generate(
                  box.length,
                  (index) {
                    final rawTask = box.getAt(index);

                    final task =
                        Map<String, dynamic>.from(
                      rawTask as Map,
                    );

                    return buildTaskCard(
                      index,
                      task,
                    );
                  },
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'Swipe a task left to delete • Tap a task to edit',
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addTask,
        backgroundColor: cyanColor,
        foregroundColor: backgroundColor,
        elevation: 8,
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          'Add Task',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}