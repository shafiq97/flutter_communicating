import 'package:flutter/material.dart';
import 'package:flutter_comunicating/manager/manager_screen.dart';
import 'package:flutter_comunicating/manager/tasks.dart';
import 'package:flutter_comunicating/user/user_screen.dart';
import 'auth/login.dart';
import 'auth/register.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/home': (context) => const HomeScreen(),
        '/employee': (context) => UserHomeScreen(
            userEmail: ModalRoute.of(context)!.settings.arguments as String),
        '/manager': (context) => ManagerScreen(
            userEmail: ModalRoute.of(context)!.settings.arguments as String),
        '/manager_task_screen': (context) => ManagerManageTasks(
            email: ModalRoute.of(context)!.settings.arguments as String),
        '/login': (context) => const LoginScreen()
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const NotFoundScreen(),
        );
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'My App',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/user');
              },
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/');
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Welcome to the home screen!'),
      ),
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('404 Not Found'),
      ),
      body: const Center(
        child: Text('Oops! The page you are looking for does not exist.'),
      ),
    );
  }
}
