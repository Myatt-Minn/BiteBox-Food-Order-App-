import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:foodorderapplication/screens/cartscreen.dart';
import 'package:foodorderapplication/screens/categoryscreen.dart';
import 'package:foodorderapplication/screens/homescreen.dart';
import 'package:foodorderapplication/screens/ordersscreen.dart';
import 'package:foodorderapplication/utils/consts.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});
  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int selectedIndex = 0;
  var screens = [
    const Homescreen(),
    const CategoryScreen(),
    const Cartscreen(),
    const OrderListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        color: primaryColor, // Color of the navigation bar
        buttonBackgroundColor: secondaryColor, // Active button color
        backgroundColor: Colors.transparent,

        height: 60,
        animationDuration: const Duration(milliseconds: 300),
        items: [
          Icon(
            Icons.home,
            size: 30,
            color: selectedIndex == 0 ? Colors.white : Colors.white,
          ),
          Icon(
            Icons.category,
            size: 30,
            color: selectedIndex == 1 ? Colors.white : Colors.white,
          ),
          Icon(
            Icons.shopping_cart,
            size: 30,
            color: selectedIndex == 2 ? Colors.white : Colors.white,
          ),
          Icon(
            Icons.receipt,
            size: 30,
            color: selectedIndex == 3 ? Colors.white : Colors.white,
          ),
        ],
        onTap: (index) {
          setState(() {
            selectedIndex = index; // Change selected page
          });
        },
      ),
    );
  }
}
