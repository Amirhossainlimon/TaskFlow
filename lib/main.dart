
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

const primaryColor = Color(0xFF5146E5);
const pageColor = Color(0xFFF6F7FC);
const darkColor = Color(0xFF20213A);
const mutedColor = Color(0xFF8589A5);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: pageColor,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: pageColor,
          foregroundColor: darkColor,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: pageColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return snapshot.hasData ? const HomePage() : const LoginPage();
      },
    );
  }
}



class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Login failed')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Welcome back!',
      subtitle: 'Organize your work. Achieve your goals.',
      formKey: formKey,
      email: email,
      password: password,
      loading: loading,
      buttonText: 'Sign In',
      onSubmit: login,
      footerText: "Don't have an account? Sign up",
      onFooter: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RegisterPage()),
      ),
    );
  }
}



class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);
    try {
      final result =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text,
      );

      await result.user?.updateDisplayName(name.text.trim());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Registration failed')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Create account',
      subtitle: 'Start building better habits today.',
      formKey: formKey,
      name: name,
      email: email,
      password: password,
      loading: loading,
      buttonText: 'Create Account',
      onSubmit: register,
      footerText: 'Already have an account? Sign in',
      onFooter: () => Navigator.pop(context),
    );
  }
}

class AuthScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final GlobalKey<FormState> formKey;
  final TextEditingController? name;
  final TextEditingController email;
  final TextEditingController password;
  final bool loading;
  final String buttonText;
  final VoidCallback onSubmit;
  final String footerText;
  final VoidCallback onFooter;

  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.formKey,
    this.name,
    required this.email,
    required this.password,
    required this.loading,
    required this.buttonText,
    required this.onSubmit,
    required this.footerText,
    required this.onFooter,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 64,
                      width: 64,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.checklist_rounded,
                        size: 35,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: darkColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(subtitle, style: const TextStyle(color: mutedColor)),
                    const SizedBox(height: 30),
                    if (name != null) ...[
                      TextFormField(
                        controller: name,
                        decoration: const InputDecoration(
                          labelText: 'Full name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) =>
                        v == null || v.trim().isEmpty
                            ? 'Enter your name'
                            : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) => v == null || !v.contains('@')
                          ? 'Enter a valid email'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: password,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (v) =>
                      v == null || v.length < 6
                          ? 'Use at least 6 characters'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: loading ? null : onSubmit,
                        child: loading
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                            : Text(
                          buttonText,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: onFooter,
                        child: Text(footerText),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final searchController = TextEditingController();
  String filter = 'All';

  User get user => FirebaseAuth.instance.currentUser!;

  CollectionReference<Map<String, dynamic>> get tasks =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks');

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> showTaskDialog({
    DocumentSnapshot<Map<String, dynamic>>? task,
  }) async {
    final titleController = TextEditingController(
      text: task?.data()?['title'] as String? ?? '',
    );
    final descriptionController = TextEditingController(
      text: task?.data()?['description'] as String? ?? '',
    );
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(task == null ? 'Create a task' : 'Edit task'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Task title',
                    prefixIcon: Icon(Icons.task_alt),
                  ),
                  validator: (v) =>
                  v == null || v.trim().isEmpty
                      ? 'Title is required'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.notes),
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              try {
                final data = <String, dynamic>{
                  'title': titleController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'updatedAt': FieldValue.serverTimestamp(),
                };

                if (task == null) {
                  data['isCompleted'] = false;
                  data['createdAt'] = FieldValue.serverTimestamp();
                  await tasks.add(data);
                } else {
                  await tasks.doc(task.id).update(data);
                }

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              } catch (e) {
                if (!dialogContext.mounted) return;
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text('Could not save task: $e')),
                );
              }
            },
            child: Text(task == null ? 'Create Task' : 'Save Changes'),
          ),
        ],
      ),
    );

    titleController.dispose();
    descriptionController.dispose();
  }

  Future<void> deleteTask(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete task?'),
        content: const Text('This task will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await tasks.doc(id).delete();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  Future<void> toggleTask(String id, bool completed) async {
    try {
      await tasks.doc(id).update({
        'isCompleted': !completed,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : 'there';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.checklist_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'TaskFlow',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: logout,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        onPressed: () => showTaskDialog(),
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: tasks.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load tasks.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allTasks = snapshot.data?.docs ?? [];
          final completedCount = allTasks.where((task) {
            return task.data()['isCompleted'] == true;
          }).length;
          final pendingCount = allTasks.length - completedCount;
          final progress =
          allTasks.isEmpty ? 0.0 : completedCount / allTasks.length;

          final query = searchController.text.trim().toLowerCase();
          final visibleTasks = allTasks.where((task) {
            final data = task.data();
            final title = (data['title'] as String? ?? '').toLowerCase();
            final description =
            (data['description'] as String? ?? '').toLowerCase();
            final completed = data['isCompleted'] == true;

            final matchesSearch =
                title.contains(query) || description.contains(query);
            final matchesFilter = filter == 'All' ||
                (filter == 'Completed' && completed) ||
                (filter == 'Pending' && !completed);

            return matchesSearch && matchesFilter;
          }).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            children: [
              Text(
                'Good to see you,',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                '$displayName 👋',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: darkColor,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Let’s make today productive.',
                style: TextStyle(color: mutedColor),
              ),
              const SizedBox(height: 24),

              // Statistics
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Total Tasks',
                      value: allTasks.length.toString(),
                      icon: Icons.format_list_bulleted_rounded,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Completed',
                      value: completedCount.toString(),
                      icon: Icons.check_circle_outline_rounded,
                      color: const Color(0xFF159D75),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Pending',
                      value: pendingCount.toString(),
                      icon: Icons.schedule_rounded,
                      color: const Color(0xFFE59A27),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Progress
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5146E5), Color(0xFF7770F0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your progress',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      allTasks.isEmpty
                          ? 'Add your first task to get started.'
                          : '$completedCount of ${allTasks.length} tasks completed',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 18),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 9,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${(progress * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              const Text(
                'My Tasks',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: darkColor,
                ),
              ),
              const SizedBox(height: 14),

              // Search
              TextField(
                controller: searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search your tasks...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: searchController.text.isEmpty
                      ? null
                      : IconButton(
                    onPressed: () {
                      searchController.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.close),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Filters
              Wrap(
                spacing: 8,
                children: ['All', 'Pending', 'Completed'].map((value) {
                  return ChoiceChip(
                    label: Text(value),
                    selected: filter == value,
                    selectedColor: primaryColor.withValues(alpha: 0.14),
                    onSelected: (_) => setState(() => filter = value),
                    side: BorderSide(
                      color: filter == value
                          ? primaryColor
                          : Colors.grey.shade300,
                    ),
                    labelStyle: TextStyle(
                      color: filter == value ? primaryColor : darkColor,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              if (visibleTasks.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        query.isNotEmpty
                            ? Icons.search_off_rounded
                            : Icons.task_alt_rounded,
                        size: 54,
                        color: primaryColor.withValues(alpha: 0.65),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        query.isNotEmpty || filter != 'All'
                            ? 'No matching tasks'
                            : 'Nothing on your list yet',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Create a task and start making progress.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: mutedColor),
                      ),
                    ],
                  ),
                )
              else
                ...visibleTasks.map((task) {
                  final data = task.data();
                  final title = data['title'] as String? ?? 'Untitled';
                  final description =
                      data['description'] as String? ?? '';
                  final completed = data['isCompleted'] == true;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFEAEBF3)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: completed,
                            activeColor: const Color(0xFF159D75),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            onChanged: (_) =>
                                toggleTask(task.id, completed),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                              const EdgeInsets.only(top: 12, bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      decoration: completed
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: completed
                                          ? mutedColor
                                          : darkColor,
                                    ),
                                  ),
                                  if (description.isNotEmpty) ...[
                                    const SizedBox(height: 5),
                                    Text(
                                      description,
                                      style: const TextStyle(
                                        color: mutedColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 9),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: completed
                                          ? const Color(0xFFE2F7EE)
                                          : const Color(0xFFFFF2D9),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      completed ? 'Completed' : 'Pending',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: completed
                                            ? const Color(0xFF12845F)
                                            : const Color(0xFFB77916),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                showTaskDialog(task: task);
                              } else if (value == 'delete') {
                                deleteTask(task.id);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, size: 20),
                                    SizedBox(width: 10),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      size: 20,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 10),
                                    Text('Delete'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAEBF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: darkColor,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: mutedColor,
            ),
          ),
        ],
      ),
    );
  }
}
