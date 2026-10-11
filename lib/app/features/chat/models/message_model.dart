import 'package:working_hiring/app/features/chat/models/message_type.dart';

class MessageModel {
  final int? id;
  final String text;
  final bool isMe;
  String senderRole;
  final String time;
  final MessageType type;

  final String? taskTitle;
  final String? category;
  final String? address;
  final DateTime? date;
  String offerStatus;
  String? timeSlot;
  String? endTime;
  String? jobState;
  double? budget;
  double? proposedBudget;
  bool isRescheduleRequest;
  DateTime? proposedDate;
  String? proposedTimeSlot;
  double? laborCost;
  double? materialsCost;
  String? duration;
  DateTime? quoteExpiryTime;
  String? description;
  String? photoUrl;
  double? clientRating;
  String? cancellationReason;
  String? counterMessage;
  String? attachmentUrl;
  String? attachmentName;
  int? attachmentSize;
  String? attachmentMime;
  List<String> orderAttachments;
  final int? orderId;
  String? eventType;
  int? changesRequestId;
  String? changesType;
  String? changesRequestStatus;
  int? proposedHour;
  String? proposedDateStr;
  String? proposedTime;
  String? proposedMessage;
  String? confirmationOtp;

  int counterCount;

  bool hoursSet;
  bool workCompleted;
  bool feedbackGiven;

  bool get isTemporary => id != null && id! < 0;

  MessageModel copyWith({
    int? id,
    String? text,
    bool? isMe,
    String? senderRole,
    String? time,
    MessageType? type,
    String? taskTitle,
    String? category,
    String? address,
    DateTime? date,
    String? offerStatus,
    String? timeSlot,
    String? endTime,
    String? jobState,
    double? budget,
    double? proposedBudget,
    bool? isRescheduleRequest,
    DateTime? proposedDate,
    String? proposedTimeSlot,
    double? laborCost,
    double? materialsCost,
    String? duration,
    DateTime? quoteExpiryTime,
    String? description,
    String? photoUrl,
    double? clientRating,
    String? cancellationReason,
    String? counterMessage,
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
    String? attachmentMime,
    List<String>? orderAttachments,
    int? orderId,
    String? eventType,
    int? changesRequestId,
    String? changesType,
    String? changesRequestStatus,
    int? proposedHour,
    String? proposedDateStr,
    String? proposedTime,
    String? proposedMessage,
    String? confirmationOtp,
    int? counterCount,
    bool? hoursSet,
    bool? workCompleted,
    bool? feedbackGiven,
  }) {
    return MessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      isMe: isMe ?? this.isMe,
      senderRole: senderRole ?? this.senderRole,
      time: time ?? this.time,
      type: type ?? this.type,
      taskTitle: taskTitle ?? this.taskTitle,
      category: category ?? this.category,
      address: address ?? this.address,
      date: date ?? this.date,
      offerStatus: offerStatus ?? this.offerStatus,
      timeSlot: timeSlot ?? this.timeSlot,
      endTime: endTime ?? this.endTime,
      jobState: jobState ?? this.jobState,
      budget: budget ?? this.budget,
      proposedBudget: proposedBudget ?? this.proposedBudget,
      isRescheduleRequest: isRescheduleRequest ?? this.isRescheduleRequest,
      proposedDate: proposedDate ?? this.proposedDate,
      proposedTimeSlot: proposedTimeSlot ?? this.proposedTimeSlot,
      laborCost: laborCost ?? this.laborCost,
      materialsCost: materialsCost ?? this.materialsCost,
      duration: duration ?? this.duration,
      quoteExpiryTime: quoteExpiryTime ?? this.quoteExpiryTime,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      clientRating: clientRating ?? this.clientRating,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      counterMessage: counterMessage ?? this.counterMessage,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentName: attachmentName ?? this.attachmentName,
      attachmentSize: attachmentSize ?? this.attachmentSize,
      attachmentMime: attachmentMime ?? this.attachmentMime,
      orderAttachments: orderAttachments ?? this.orderAttachments,
      orderId: orderId ?? this.orderId,
      eventType: eventType ?? this.eventType,
      changesRequestId: changesRequestId ?? this.changesRequestId,
      changesType: changesType ?? this.changesType,
      changesRequestStatus: changesRequestStatus ?? this.changesRequestStatus,
      proposedHour: proposedHour ?? this.proposedHour,
      proposedDateStr: proposedDateStr ?? this.proposedDateStr,
      proposedTime: proposedTime ?? this.proposedTime,
      proposedMessage: proposedMessage ?? this.proposedMessage,
      confirmationOtp: confirmationOtp ?? this.confirmationOtp,
      counterCount: counterCount ?? this.counterCount,
      hoursSet: hoursSet ?? this.hoursSet,
      workCompleted: workCompleted ?? this.workCompleted,
      feedbackGiven: feedbackGiven ?? this.feedbackGiven,
    );
  }

  MessageModel({
    this.id,
    required this.text,
    required this.isMe,
    this.senderRole = 'client',
    required this.time,
    this.type = MessageType.text,
    this.taskTitle,
    this.category,
    this.address,
    this.date,
    this.offerStatus = 'pending',
    this.budget,
    this.proposedBudget,
    this.isRescheduleRequest = false,
    this.proposedDate,
    this.proposedTimeSlot,
    this.laborCost,
    this.materialsCost,
    this.duration,
    this.timeSlot,
    this.endTime,
    this.jobState,
    this.description,
    this.photoUrl,
    this.clientRating,
    this.cancellationReason,
    this.counterMessage,
    this.orderId,
    this.attachmentUrl,
    this.attachmentName,
    this.attachmentSize,
    this.attachmentMime,
    this.orderAttachments = const [],
    this.eventType,
    this.changesRequestId,
    this.changesType,
    this.changesRequestStatus,
    this.proposedHour,
    this.proposedDateStr,
    this.proposedTime,
    this.proposedMessage,
    this.confirmationOtp,
    this.counterCount = 0,
    this.hoursSet = false,
    this.workCompleted = false,
    this.feedbackGiven = false,
    DateTime? quoteExpiryTime,
  }) {
    if ((type == MessageType.offer || type == MessageType.quote) &&
        offerStatus == 'pending') {
      this.quoteExpiryTime =
          quoteExpiryTime ?? DateTime.now().add(Duration(hours: 12));
    } else {
      this.quoteExpiryTime = quoteExpiryTime;
    }
  }

  @override
  String toString() =>
      'MessageModel(id: $id, text: $text, isMe: $isMe, time: $time)';
}
