import 'package:flutter/material.dart';
import '../../components/event_item_list/event_item_list.dart';

class CreatedEventsPage extends StatelessWidget {
  const CreatedEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Eventos Creados'),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: EventItemList(eventType: 'created'),
    );
  }
}