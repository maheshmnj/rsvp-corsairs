import 'package:flutter/material.dart';

class EventsSearch extends StatefulWidget {
  const EventsSearch({super.key});

  @override
  State<EventsSearch> createState() => _EventsSearchState();
}

class _EventsSearchState extends State<EventsSearch> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Material(
        child: Column(
          children: [
            Container(),
          ],
        ),
      ),
    );
  }
}
