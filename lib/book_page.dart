import 'package:flutter/material.dart';

class BookPage extends StatelessWidget {
  const BookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // خلفية بيضاء
      child: const Center(
        child: Text(
          'Book Page',
          style: TextStyle(fontSize: 24, color: Colors.black),
        ),
      ),
    );
  }
}