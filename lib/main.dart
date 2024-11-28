import 'package:flutter/material.dart';
import 'pages/catalog_page.dart';
import 'pages/favorites_page.dart';
import 'pages/profile_page.dart';
import 'pages/login_page.dart';
import 'components/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const PhotoRoomApp());
}

class PhotoRoomApp extends StatelessWidget {
  const PhotoRoomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PhotoRoom',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthHandler(),
    );
  }
}

class AuthHandler extends StatefulWidget {
  const AuthHandler({super.key});

  @override
  State<AuthHandler> createState() => _AuthHandlerState();
}

class _AuthHandlerState extends State<AuthHandler> {
  final AuthService _authService = AuthService();
  bool _isAuthenticated = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final user = _authService.currentUser();
    setState(() {
      _isAuthenticated = user != null;
      _userId = user?.uid;
    });
  }

  void _onLogin(String email, String password) async {
    final user = await _authService.signIn(email, password);
    if (user != null) {
      setState(() {
        _isAuthenticated = true;
        _userId = user.uid;
      });
    }
  }

  void _onLogout() async {
    await _authService.signOut();
    setState(() {
      _isAuthenticated = false;
      _userId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isAuthenticated
        ? MainPage(userId: _userId!, onLogout: _onLogout)
        : LoginPage(onLogin: _onLogin);
  }
}

class MainPage extends StatefulWidget {
  final String userId;
  final VoidCallback onLogout;

  const MainPage({required this.userId, required this.onLogout, super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  String userName = "User Name";
  String userEmail = "user@example.com";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final userDoc = await AuthService().getUserData(widget.userId);
    setState(() {
      userName = userDoc?['name'] ?? "User Name";
      userEmail = userDoc?['email'] ?? "user@example.com";
    });
  }

  void _updateProfile(String name, String email) {
    setState(() {
      userName = name;
      userEmail = email;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      CatalogPage(),
      FavoritesPage(userId: widget.userId),
      ProfilePage(
        name: userName,
        email: userEmail,
        onEdit: _updateProfile,
        onLogout: widget.onLogout,
      ),
    ];

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shop), label: 'Catalog'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}