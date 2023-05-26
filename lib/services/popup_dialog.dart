import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:playtoday/services/match_services.dart';

class MyPopup extends StatefulWidget {
  @override
  _MyPopupDialogState createState() => _MyPopupDialogState();
}

class _MyPopupDialogState extends State<MyPopup> {
  DateTime selectedDate = DateTime.now();
  String selectedDateFormatted = 'dd/mm/yyyy';
  TimeOfDay selectedTime = TimeOfDay.now();
  String selectedOption = 'Public';
  String selectedStade = '';
  late String username = '';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime(2024),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      final formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      setState(() {
        selectedDate = pickedDate;
        selectedDateFormatted = formattedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  void _showOptionPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return OptionPickerDialog(
          selectedOption: selectedOption,
          onOptionChanged: (option) {
            setState(() {
              selectedOption = option;
            });
          },
        );
      },
    );
  }

  void _showStadiumPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StadiumPickerDialog(
          selectedStade: selectedOption,
          onStadeChanged: (stade) {
            setState(() {
              selectedStade = stade;
            });
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        // Document exists, you can access its data
        var data = snapshot.data();
        if (data is Map<String, dynamic>) {
          setState(() {
            username = data['username'];
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Match'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(
            onPressed: () => _selectDate(context),
            child: Text(
              'Select Date: $selectedDateFormatted',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          TextButton(
            onPressed: () => _selectTime(context),
            child: Text('Select Time: ${selectedTime.format(context)}',
                style: const TextStyle(fontSize: 18)),
          ),
          TextButton(
            onPressed: () => _showOptionPicker(context),
            child: Text('Select Option: $selectedOption',
                style: const TextStyle(fontSize: 18)),
          ),
          TextButton(
            onPressed: () => _showStadiumPicker(context),
            child: Text('Select Stade: $selectedStade',
                style: const TextStyle(fontSize: 18)),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel',
              style: TextStyle(fontSize: 18, color: Colors.red)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Create', style: TextStyle(fontSize: 18)),
          onPressed: () {
            // Perform create operation
            createMatch(context, username, selectedDateFormatted,
                selectedTime.format(context), selectedOption, selectedStade);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class OptionPickerDialog extends StatefulWidget {
  final String selectedOption;
  final ValueChanged<String> onOptionChanged;

  const OptionPickerDialog({
    super.key,
    required this.selectedOption,
    required this.onOptionChanged,
  });

  @override
  _OptionPickerDialogState createState() => _OptionPickerDialogState();
}

class _OptionPickerDialogState extends State<OptionPickerDialog> {
  late String selectedOption;

  @override
  void initState() {
    super.initState();
    selectedOption = widget.selectedOption;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Option'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Public'),
            onTap: () {
              setState(() {
                selectedOption = 'Public';
              });
              widget.onOptionChanged(selectedOption);
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: const Text('Private'),
            onTap: () {
              setState(() {
                selectedOption = 'Private';
              });
              widget.onOptionChanged(selectedOption);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class StadiumPickerDialog extends StatefulWidget {
  final String selectedStade;
  final ValueChanged<String> onStadeChanged;

  const StadiumPickerDialog({
    super.key,
    required this.selectedStade,
    required this.onStadeChanged,
  });

  @override
  _StadiumPickerDialogState createState() => _StadiumPickerDialogState();
}

class _StadiumPickerDialogState extends State<StadiumPickerDialog> {
  late String selectedStade;

  @override
  void initState() {
    super.initState();
    selectedStade = widget.selectedStade;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Option'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('PARC DE FRANCE'),
            onTap: () {
              setState(() {
                selectedStade = 'PARC DE FRANCE';
              });
              widget.onStadeChanged(selectedStade);
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: const Text('PARC DES PRINCES'),
            onTap: () {
              setState(() {
                selectedStade = 'PARC DES PRINCES';
              });
              widget.onStadeChanged(selectedStade);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
