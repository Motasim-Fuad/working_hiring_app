import 'package:working_hiring/app/data/repositories/helper_repository.dart';
import 'package:working_hiring/app/data/models/helper_list_model.dart';

class HelperListResult {
  final List<HelperListModel> helpers;
  final String? nextUrl;

  HelperListResult({required this.helpers, this.nextUrl});
}
