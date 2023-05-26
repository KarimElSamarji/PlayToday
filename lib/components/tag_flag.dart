import 'package:flutter/material.dart';

class Tag extends StatefulWidget {
  final bool available;
  final String option1;
  final String option2;
  const Tag(
      {super.key,
      required this.available,
      required this.option1,
      required this.option2});

  @override
  State<Tag> createState() => _TagState();
}

class _TagState extends State<Tag> {
  late bool available;
  late String option1;
  late String option2;

  @override
  void initState() {
    available = widget.available;
    option1 = widget.option1;
    option2 = widget.option2;
    super.initState();
  }

  

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: available
              ? const Color.fromARGB(255, 35, 177, 40)
              : const Color.fromARGB(255, 181, 22, 22),
        ),
        child: Text(
          available ? option1 : option2,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ));
  }
}
