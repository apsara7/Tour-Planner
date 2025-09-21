import 'package:flutter/material.dart';
import 'package:tour_planner1/views/home/widgets/explore_srilanka_section.dart';
import 'package:tour_planner1/views/navigation/sidebar_menu.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tour Planner'),
      ),
      drawer: const SidebarMenu(),
      body: const Column(
        children: [
          Expanded(child: ExploreSriLankaSection()),
        ],
      ),
    );
  }
}
