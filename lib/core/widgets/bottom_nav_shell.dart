import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shell qui contient une BottomNavigationBar persistante
class BottomNavShell extends StatefulWidget {
  final Widget child;
  const BottomNavShell({super.key, required this.child});

  @override
  State<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends State<BottomNavShell> {
  static const List<String> _paths = [
    '/home',
    '/search',
    '/saved',
    '/conversations',
    '/profile',
  ];

  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).uri.toString();
    _currentIndex = _indexFromLocation(location);
  }

  int _indexFromLocation(String location) {
    for (var i = 0; i < _paths.length; i++) {
      if (location.startsWith(_paths[i])) return i;
    }
    return 0;
  }

  void _onTap(int index) {
    if (index == _currentIndex) return;
    context.go(_paths[index]);
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Recherche'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Favoris'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}
