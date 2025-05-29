class DiaryEntry {
  final int? id;
  final DateTime dateTime;
  final String situationDescription;
  final String attentionFocus;
  final String thoughts;
  final String bodySensations;
  final String actions;
  final String futureActions;

  DiaryEntry({
    this.id,
    required this.dateTime,
    required this.situationDescription,
    required this.attentionFocus,
    required this.thoughts,
    required this.bodySensations,
    required this.actions,
    required this.futureActions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'situationDescription': situationDescription,
      'attentionFocus': attentionFocus,
      'thoughts': thoughts,
      'bodySensations': bodySensations,
      'actions': actions,
      'futureActions': futureActions,
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'],
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime']),
      situationDescription: map['situationDescription'] ?? '',
      attentionFocus: map['attentionFocus'] ?? '',
      thoughts: map['thoughts'] ?? '',
      bodySensations: map['bodySensations'] ?? '',
      actions: map['actions'] ?? '',
      futureActions: map['futureActions'] ?? '',
    );
  }

  DiaryEntry copyWith({
    int? id,
    DateTime? dateTime,
    String? situationDescription,
    String? attentionFocus,
    String? thoughts,
    String? bodySensations,
    String? actions,
    String? futureActions,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      situationDescription: situationDescription ?? this.situationDescription,
      attentionFocus: attentionFocus ?? this.attentionFocus,
      thoughts: thoughts ?? this.thoughts,
      bodySensations: bodySensations ?? this.bodySensations,
      actions: actions ?? this.actions,
      futureActions: futureActions ?? this.futureActions,
    );
  }
}
