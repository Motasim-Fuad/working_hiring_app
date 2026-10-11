/// Wire schema for `event.reference_object` — populated for COUNTER, CANCEL,
/// CHANGE_REQUEST, and HOUR_SET events. Carries the `OrderChangesRequest.id`
/// the receiver echoes back when responding via REST.
class OrderChangesRequest {
  final int id;
  final String? requestBy;
  final String? status;
  final String? changesType;
  final Map<String, dynamic> changesData;
  final String? createdAt;
  final String? updatedAt;

  OrderChangesRequest({
    required this.id,
    this.requestBy,
    this.status,
    this.changesType,
    this.changesData = const {},
    this.createdAt,
    this.updatedAt,
  });

  factory OrderChangesRequest.fromJson(Map<String, dynamic> j) {
    final changesData = (j['changes_data'] is Map)
        ? Map<String, dynamic>.from(j['changes_data'] as Map)
        : <String, dynamic>{};
    if (!changesData.containsKey('budget')) {
      final budget = j['proposed_budget'] ?? j['budget'];
      if (budget != null) changesData['budget'] = budget;
    }
    if (!changesData.containsKey('message') && j['message'] != null) {
      changesData['message'] = j['message'];
    }
    return OrderChangesRequest(
      id: (j['id'] as num?)?.toInt() ?? 0,
      requestBy: j['request_by'] as String?,
      status: j['status'] as String?,
      changesType: j['changes_type'] as String?,
      changesData: changesData,
      createdAt: j['created_at'] as String?,
      updatedAt: j['updated_at'] as String?,
    );
  }

  /// Proposed budget for COUNTER events. Always returned as string per spec §2.2.
  double? get proposedBudget =>
      double.tryParse(changesData['budget']?.toString() ?? '');

  /// Proposed working date for TIME/DATE/TIME_AND_DATE events ("YYYY-MM-DD").
  String? get proposedDate => changesData['date'] as String?;

  /// Proposed working time for TIME/TIME_AND_DATE events (e.g. "10:00 AM").
  String? get proposedTime => changesData['time'] as String?;

  /// Proposed work hour for SET_HOUR events.
  int? get proposedHour => (changesData['set_hour'] as num?)?.toInt();

  /// Free-text message attached to the proposal.
  String? get message => changesData['message'] as String?;
}
