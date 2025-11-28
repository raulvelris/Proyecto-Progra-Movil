import 'package:flutter/material.dart';
import '../../components/event_item_list/event_item_list.dart';

class PublicEventsPage extends StatelessWidget {
  const PublicEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Eventos Públicos',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: const EventItemList(eventType: 'public'),
    );
  }
}
