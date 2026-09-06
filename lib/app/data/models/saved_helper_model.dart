// lib/data/models/saved_helper_model.dart
import 'package:working_hiring/app/data/repositories/helper_repository.dart';

import 'helper_model.dart';

class SavedHelperEntry {
  final int entryId;
  final HelperListModel helper;

  const SavedHelperEntry({required this.entryId, required this.helper});

  factory SavedHelperEntry.fromJson(Map<String, dynamic> json) {
    final helperJson = json['helper'] as Map<String, dynamic>? ?? json;
    return SavedHelperEntry(
      entryId: json['id'] as int,
      helper: HelperListModel.fromJson(helperJson),
    );
  }
}