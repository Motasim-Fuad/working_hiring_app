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
  final String? sender; // 'PROVIDER' or 'CUSTOMER'

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
      proposedHour:
          ((json['proposed_hour'] ?? changesData['set_hour']) as num?)?.toInt(),
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

class OrderModel {
  final int id;
  final String? title;
  final String? description;
  final String? status;
  final String? paymentStatus;
  final double? amount;
  final double? budget;
  final String? workingDate;
  final String? workingStartTime;
  final String? endTime;
  final int? workingHour;
  final String? address;
  final double? lat;
  final double? lng;
  final int? provider;
  final int? customer;
  final String? providerName;
  final String? customerName;
  final String? categoryName;
  final String? subCategoryName;
  final List<String>? attachments;
  final List<ChangesRequestModel>? changesRequests;
  final ChangesRequestModel? changesRequestPending;
  final String? confirmationOtp;
  final String? acceptedAt;
  final String? startedAt;
  final String? completedAt;
  final String? createdAt;
  final bool isProviderReview;
  final bool isCustomerReview;
  final bool isCancelRequest;
  final String? cancelRequestBy;
  final String? cancelRequestAcceptBy;

  // ✅ NEW: latest action on the order from provider or customer
  final String? orderChangeAction;

  OrderModel({
    required this.id,
    this.title,
    this.description,
    this.status,
    this.paymentStatus,
    this.amount,
    this.budget,
    this.workingDate,
    this.workingStartTime,
    this.endTime,
    this.workingHour,
    this.address,
    this.lat,
    this.lng,
    this.provider,
    this.customer,
    this.providerName,
    this.customerName,
    this.categoryName,
    this.subCategoryName,
    this.attachments,
    this.changesRequests,
    this.changesRequestPending,
    this.confirmationOtp,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.createdAt,
    this.isProviderReview = false,
    this.isCustomerReview = false,
    this.isCancelRequest = false,
    this.cancelRequestBy,
    this.cancelRequestAcceptBy,
    this.orderChangeAction,
  });

  /// How many COUNTER changes requests exist for this order.
  int get counterCount {
    if (changesRequests == null) return 0;
    return changesRequests!.where((r) => r.isCounter).length;
  }

  /// True if the PROVIDER has already sent a counter on this order.
  bool get providerAlreadyCountered {
    if (changesRequests == null) return false;
    final counters = changesRequests!.where((r) => r.isCounter).toList();
    if (counters.isEmpty) return false;
    final hasSenderInfo = counters.any((r) => r.sender != null);
    if (hasSenderInfo) {
      return counters.any((r) => (r.sender ?? '').toUpperCase() == 'PROVIDER');
    }
    return counters.isNotEmpty;
  }

  /// The most recent PENDING time-change request, if any.
  ChangesRequestModel? get pendingTimeChangeRequest {
    if (changesRequests == null) return null;
    final pending = changesRequests!
        .where((r) => r.isTimeChange && r.isPending)
        .toList();
    if (pending.isEmpty) return null;
    pending.sort((a, b) => b.id.compareTo(a.id));
    return pending.first;
  }

  ChangesRequestModel? get pendingCancellationRequest {
    final direct = changesRequestPending;
    if (direct != null && direct.isCancellation && direct.isPending) {
      return direct;
    }
    final pending = (changesRequests ?? const <ChangesRequestModel>[])
        .where((r) => r.isCancellation && r.isPending)
        .toList();
    if (pending.isEmpty) return null;
    pending.sort((a, b) => b.id.compareTo(a.id));
    return pending.first;
  }

  /// Backend keeps CANCELLATION_REQUEST after a request is declined. Once the
  /// pending request is cleared, a paid order is functionally CONFIRM again.
  String get effectiveStatus {
    final raw = (status ?? '').toUpperCase();

    // The current backend keeps REFUND_REQUEST/REFUND after an in-progress
    // cancellation has been declined, while clearing both the requester and
    // the pending change request.  In that state the cancellation is over and
    // the order must remain in its pre-cancellation workflow state.
    if (raw == 'REFUND_REQUEST' &&
        isCancelRequest &&
        pendingCancellationRequest == null &&
        (cancelRequestBy ?? '').trim().isEmpty &&
        (cancelRequestAcceptBy ?? '').trim().isEmpty) {
      if ((completedAt ?? '').trim().isNotEmpty) return 'COMPLETED';
      if ((startedAt ?? '').trim().isNotEmpty) return 'IN_PROGRESS';
      return 'CONFIRM';
    }

    if (raw == 'CANCELLATION_REQUEST' &&
        pendingCancellationRequest == null &&
        (paymentStatus ?? '').toUpperCase() == 'PAID') {
      return 'CONFIRM';
    }
    return raw;
  }

  String get effectivePaymentStatus {
    final raw = (paymentStatus ?? '').toUpperCase();
    if ((status ?? '').toUpperCase() == 'REFUND_REQUEST' &&
        effectiveStatus != 'REFUND_REQUEST' &&
        isCancelRequest &&
        pendingCancellationRequest == null) {
      return 'PAID';
    }
    return raw;
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    int? parseIdField(dynamic val) {
      if (val is int) return val;
      if (val is Map) return val['id'] as int?;
      return null;
    }

    String? parseNameField(dynamic val, String nameKey) {
      if (val is Map) {
        final fullName = val['full_name'] as String?;
        if (fullName != null && fullName.trim().isNotEmpty) {
          return fullName.trim();
        }
        final first = val['first_name'] as String? ?? '';
        final last = val['last_name'] as String? ?? '';
        final combined = '$first $last'.trim();
        if (combined.isNotEmpty) return combined;
        return val[nameKey] as String?;
      }
      return null;
    }

    String? parseCategoryName(dynamic val) {
      if (val is Map) return val['title'] as String?;
      return null;
    }

    return OrderModel(
      id: json['id'] as int,
      title: json['title'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String?,
      paymentStatus: json['payment_status'] as String?,
      amount: double.tryParse(json['amount']?.toString() ?? '') ??
          (json['amount'] as num?)?.toDouble(),
      budget: double.tryParse(json['budget']?.toString() ?? '') ??
          (json['budget'] as num?)?.toDouble(),
      workingDate: json['working_date'] as String?,
      workingStartTime: json['working_start_time'] as String?,
      endTime: json['end_time'] as String?,
      workingHour: json['working_hour'] as int?,
      address: json['area'] as String?,
      lat: double.tryParse(json['lat']?.toString() ?? '') ??
          (json['lat'] as num?)?.toDouble(),
      lng: double.tryParse(json['lng']?.toString() ?? '') ??
          (json['lng'] as num?)?.toDouble(),
      provider: parseIdField(json['provider']),
      customer: parseIdField(json['customer']),
      // Customers must only see the provider's company name, never the
      // provider's personal name.
      providerName: json['provider'] is Map
          ? (json['provider'] as Map)['company_name'] as String?
          : json['provider_name'] as String?,
      customerName: json['customer_name'] as String? ??
          parseNameField(json['customer'], 'first_name'),
      categoryName: json['category_name'] as String? ??
          parseCategoryName(json['category']),
      subCategoryName: json['sub_category_name'] as String?,
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) {
            if (e is Map) {
              return (e['file'] ?? e['file_url'] ?? e['url'])?.toString() ?? '';
            }
            return e?.toString() ?? '';
          })
          .where((e) => e.trim().isNotEmpty)
          .toList(),
      changesRequests: (json['changes_requests'] as List<dynamic>?)
          ?.map((e) => ChangesRequestModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      changesRequestPending: json['changes_request_pending'] is Map
          ? ChangesRequestModel.fromJson(Map<String, dynamic>.from(
              json['changes_request_pending'] as Map))
          : null,
      confirmationOtp: json['confirmation_OTP'] as String?,
      acceptedAt: json['accepted_at'] as String?,
      startedAt: json['started_at'] as String?,
      completedAt: json['completed_at'] as String?,
      createdAt: json['created_at'] as String?,
      isProviderReview: json['is_provider_review'] as bool? ?? false,
      isCustomerReview: json['is_customer_review'] as bool? ?? false,
      isCancelRequest: json['is_cancel_request'] as bool? ?? false,
      cancelRequestBy: json['cancel_request_by']?.toString(),
      cancelRequestAcceptBy: json['cancel_request_accept_by']?.toString(),
      // ✅ Parse the new field
      orderChangeAction: json['order_change_action'] as String?,
    );
  }
}
