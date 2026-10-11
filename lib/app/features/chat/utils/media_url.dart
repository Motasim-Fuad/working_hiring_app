import 'package:working_hiring/app/service/api_url.dart';

String absoluteMediaUrl(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  if (raw.startsWith('http')) return raw;
  final u = Uri.parse(ApiUrl.baseUrl);
  final host = '${u.scheme}://${u.host}${u.hasPort ? ':${u.port}' : ''}';
  return raw.startsWith('/') ? '$host$raw' : '$host/$raw';
}
