import 'package:uuid/uuid.dart';

class DiaryEntry {
  final String id;
  final DateTime dateTime;
  final int dateMs; // Для сортировки
  final String situationDescription;
  final String attentionFocus;
  final String thoughts;
  final String bodySensations;
  final String actions;
  final String futureActions;

  DiaryEntry({
    String? id,
    DateTime? dateTime,
    required this.situationDescription,
    required this.attentionFocus,
    required this.thoughts,
    required this.bodySensations,
    required this.actions,
    required this.futureActions,
  })  : id = id ?? const Uuid().v4(),
        dateTime = dateTime ?? DateTime.now(),
        dateMs = (dateTime ?? DateTime.now()).millisecondsSinceEpoch;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'dateMs': dateMs,
      'situationDescription': situationDescription,
      'attentionFocus': attentionFocus,
      'thoughts': thoughts,
      'bodySensations': bodySensations,
      'actions': actions,
      'futureActions': futureActions,
    };
  }

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'] as String,
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        json['dateMs'] as int? ?? json['dateTime'] as int,
      ),
      situationDescription: json['situationDescription'] as String? ?? '',
      attentionFocus: json['attentionFocus'] as String? ?? '',
      thoughts: json['thoughts'] as String? ?? '',
      bodySensations: json['bodySensations'] as String? ?? '',
      actions: json['actions'] as String? ?? '',
      futureActions: json['futureActions'] as String? ?? '',
    );
  }

  DiaryEntry copyWith({
    String? id,
    DateTime? dateTime,
    String? situationDescription,
    String? attentionFocus,
    String? thoughts,
    String? bodySensations,
    String? actions,
    String? futureActions,
  }) {
    final newDateTime = dateTime ?? this.dateTime;
    return DiaryEntry(
      id: id ?? this.id,
      dateTime: newDateTime,
      situationDescription: situationDescription ?? this.situationDescription,
      attentionFocus: attentionFocus ?? this.attentionFocus,
      thoughts: thoughts ?? this.thoughts,
      bodySensations: bodySensations ?? this.bodySensations,
      actions: actions ?? this.actions,
      futureActions: futureActions ?? this.futureActions,
    );
  }
}
