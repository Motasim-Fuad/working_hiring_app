class ChangesRequestModel {
  final int id;
  final String? requestType;
  final String? changesType;
  final String? status;
  final String? message;
  final String? proposedDate;
  final String? proposedTime;
  final double? proposedAmount;
  final double? proposedBudget;
  final int? proposedHour;
  final String? sender;

  ChangesRequestModel({
    required this.id,
    this.requestType,
    this.changesType,
    this.status,
    this.message,
    this.proposedDate,
    this.proposedTime,
    this.proposedAmount,
    this.proposedBudget,
    this.proposedHour,
    this.sender,
  });

  factory ChangesRequestModel.fromJson(Map<String, dynamic> json) {
    final changesData = json['changes_data'] is Map
        ? Map<String, dynamic>.from(json['changes_data'] as Map)
        : const <String, dynamic>{};
    return ChangesRequestModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      requestType: (json['request_type'] ?? json['changes_type']) as String?,
      changesType: json['changes_type'] as String?,
      status: json['status'] as String?,
      message: (json['message'] ?? changesData['message']) as String?,
      proposedDate: (json['proposed_date'] ?? changesData['date']) as String?,
      proposedTime: (json['proposed_time'] ?? changesData['time']) as String?,
      proposedAmount: (json['proposed_amount'] as num?)?.toDouble(),
      proposedBudget: (json['proposed_budget'] as num?)?.toDouble(),
      proposedHour: ((json['proposed_hour'] ?? changesData['set_hour']) as num?)
          ?.toInt(),
      sender: (json['sender'] ?? json['request_by']) as String?,
    );
  }

  /// True if this change request is a counter offer
  bool get isCounter {
    final t = (changesType ?? requestType ?? '').toUpperCase();
    return t == 'COUNTER';
  }

  /// True if this change request is a time/date proposal from provider.
  bool get isTimeChange {
    final t = (changesType ?? requestType ?? '').toUpperCase();
    return t == 'TIME' ||
        t == 'DATE' ||
        t == 'TIME_AND_DATE' ||
        t == 'TIME_CHANGE';
  }

  bool get isCancellation {
    final t = (changesType ?? requestType ?? '').toUpperCase();
    return t == 'CANCEL' || t == 'CANCELLATION';
  }

  /// True if this change request is still awaiting a response.
  bool get isPending {
    final s = (status ?? '').toUpperCase();
    return s.isEmpty || s == 'PENDING' || s == 'NO_RESPONSE';
  }
}
