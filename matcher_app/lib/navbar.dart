import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:subtil_app/custom_icons_icons.dart';
import 'package:subtil_app/main.dart';
import 'package:subtil_app/models/user_model.dart';
import 'package:subtil_app/providers/user_provider.dart';
import 'package:subtil_app/screens/profile_screen.dart';
import 'package:subtil_app/screens/scrolls_screen.dart';
import 'package:subtil_app/screens/likes_screen.dart';

class NavBar extends StatefulWidget {
  final int? indexAsked;
  final int ? secondaryIndexAsked;

  const NavBar({super.key, this.indexAsked, this.secondaryIndexAsked});

  @override
  _NavBarState createState() => _NavBarState(indexAsked: this.indexAsked, secondaryIndexAsked: this.secondaryIndexAsked);
}

class _NavBarState extends State<NavBar> {
  int? indexAsked;
  int ? secondaryIndexAsked;

  _NavBarState({this.indexAsked, this.secondaryIndexAsked});

  late int _currentIndex;
  late List<Widget> _screens;
  late List<Widget> _items;

  late User currentUser;

  @override
  void initState(){
    super.initState();

    _screens = [
      const LikesScreen(),
      ScrollsScreen(),
      ProfileScreen(),
    ];

    _items = [
      const NavigationDestination(
        icon: Icon(CustomIcons.heart),
        selectedIcon: Icon(CustomIcons.heart, color: AppColors.salmon,),
        label: "",
      ),
      const NavigationDestination(
        icon: Icon(CustomIcons.cards_v2),
        selectedIcon: Icon(CustomIcons.cards_v2, color: AppColors.salmon),
        label: "",
      ), 
      const NavigationDestination(
        icon: Icon(CustomIcons.profile),
        selectedIcon: Icon(CustomIcons.profile, color: AppColors.salmon,),
        label: "",
      ),
    ];
    
    _currentIndex = indexAsked??0;

    currentUser = Provider.of<UserProvider>(context, listen: false).user!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens.map((screen) {
          return Offstage(
            offstage: _screens.indexOf(screen) != _currentIndex,
            child: TickerMode(
              enabled: _screens.indexOf(screen) == _currentIndex,
              child: screen,
            ),
          );
        }).toList(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
/*         iconSize: 28,
        selectedFontSize: 0,
        unselectedFontSize: 0, */
        destinations: _items
      ),
    );
  }
}