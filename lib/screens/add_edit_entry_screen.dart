import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../widgets/entry_form_stepper.dart';

class AddEditEntryScreen extends StatelessWidget {
  final DiaryEntry? entry;

  const AddEditEntryScreen({super.key, this.entry});

  @override
  Widget build(BuildContext context) {
    return EntryFormStepper(initialEntry: entry);
  }
}
