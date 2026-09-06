import '../../service/api_service.dart';
import '../../service/api_url.dart';
import '../models/availability_model.dart';

class AvailabilityRepository {
  final ApiClient _client;

  AvailabilityRepository(this._client);

  String _fullUrl(String path) => '${ApiUrl.baseUrl}$path';

  /// Availability endpoints (spec §2.3) use DD-MM-YYYY in URL params.
  /// Accept either a [DateTime] or a [String] for convenience; if a [String]
  /// is already in DD-MM-YYYY it passes through, ISO is converted.
  static String formatDateForAvailability(Object date) {
    if (date is DateTime) return _ddmmyyyy(date);
    if (date is String) {
      // Already DD-MM-YYYY (10 chars, dashes at 2 and 5)
      if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(date)) return date;
      final parsed = DateTime.tryParse(date);
      if (parsed != null) return _ddmmyyyy(parsed);
      return date;
    }
    throw ArgumentError('date must be DateTime or String');
  }

  static String _ddmmyyyy(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd-$mm-${d.year}';
  }

  Future<List<WeeklyDayAvailability>> getWeeklyAvailability({String? profileType}) async {
    _client.profileType = profileType ?? 'provider';
    final response = await _client.get(url: _fullUrl(ApiUrl.helperWeeklyAvailability));
    final data = parseApiResponse(response);
    final list = data as List<dynamic>;
    return list.map((e) => WeeklyDayAvailability.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> setWeeklyAvailability(Map<String, dynamic> body, {String? profileType}) async {
    _client.profileType = profileType ?? 'provider';
    await _client.post(url: _fullUrl(ApiUrl.helperSetWeeklyAvailability), body: body);
  }

  Future<WeeklyDayAvailability> updateDayAvailability(String day, Map<String, dynamic> body, {String? profileType}) async {
    _client.profileType = profileType ?? 'provider';
    final response = await _client.post(url: _fullUrl(ApiUrl.helperUpdateAvailability(day)), body: body);
    final data = parseApiResponse(response);
    return WeeklyDayAvailability.fromJson(data as Map<String, dynamic>);
  }

  Future<List<DateSlot>> getDateSlotList(Object date, {String? profileType}) async {
    _client.profileType = profileType ?? 'provider';
    final formatted = formatDateForAvailability(date);
    final response = await _client.get(url: _fullUrl(ApiUrl.helperDateSlotList(formatted)));
    final data = parseApiResponse(response);
    final map = data as Map<String, dynamic>;
    final list = map['slots'] as List<dynamic>;
    return list.map((e) => DateSlot.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Customer-side: a SPECIFIC helper's hourly slots for a date.
  /// GET /get-helper-availablity/{providerId}/{date}/   (date = DD-MM-YYYY)
  Future<List<DateSlot>> getHelperDateSlots(
      int providerId,
      Object date, {
        String? profileType,
      }) async {
    _client.profileType = profileType ?? 'customer';
    final formatted = formatDateForAvailability(date);
    final response = await _client.get(
      url: _fullUrl('/get-helper-availablity/$providerId/$formatted/'),
    );
    final data = parseApiResponse(response);
    final map = data as Map<String, dynamic>;
    final list = map['slots'] as List<dynamic>;
    return list.map((e) => DateSlot.fromJson(e as Map<String, dynamic>)).toList();
  }


  /// Hours-wise check: is [startTime] free for [workingHour] hours on [date]?
  /// GET /get-helper-availablity/{id}/{date}/?working_hour=H&start_time=09:00 AM
  Future<HourSlotCheck> checkHelperSlot(
      int providerId,
      Object date, {
        required int workingHour,
        required String startTime, // "12:00 PM"
        String? profileType,
      }) async {
    _client.profileType = profileType ?? 'customer';
    final formatted = formatDateForAvailability(date);
    final qp = Uri(queryParameters: {
      'working_hour': workingHour.toString(),
      'start_time': startTime,
    }).query;
    final response = await _client.get(
      url: _fullUrl('/get-helper-availablity/$providerId/$formatted/?$qp'),
    );
    final body = response.body;
    final map = body is Map<String, dynamic> ? body : <String, dynamic>{};
    return HourSlotCheck.fromJson(map);
  }
  Future<void> setSlotException(Object date, Map<String, dynamic> body, {String? profileType}) async {
    _client.profileType = profileType ?? 'provider';
    final formatted = formatDateForAvailability(date);
    await _client.post(url: _fullUrl(ApiUrl.helperSlotException(formatted)), body: body);
  }

  Future<void> setSpecialDate(Object date, Map<String, dynamic> body, {String? profileType}) async {
    _client.profileType = profileType ?? 'provider';
    final formatted = formatDateForAvailability(date);
    await _client.post(url: _fullUrl(ApiUrl.helperSpecialDate(formatted)), body: body);
  }

  Future<List<WeeklyDayAvailability>> getWeeklyDayList({String? profileType}) async {
    _client.profileType = profileType ?? 'provider';
    final response = await _client.get(url: _fullUrl(ApiUrl.helperWeeklyDayList));
    final data = parseApiResponse(response);
    final list = data as List<dynamic>;
    return list.map((e) => WeeklyDayAvailability.fromJson(e as Map<String, dynamic>)).toList();
  }
}
