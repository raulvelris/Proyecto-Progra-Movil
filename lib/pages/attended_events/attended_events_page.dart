import 'package:flutter/material.dart';
import '../../components/event_item_list/event_item_list.dart';

class AttendedEventsPage extends StatelessWidget {
  const AttendedEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos que Asistiré'),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: EventItemList(eventType: 'attended'),
    );
  }
}