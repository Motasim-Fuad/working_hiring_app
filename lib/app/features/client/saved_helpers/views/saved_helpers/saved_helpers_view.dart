import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/client/helper_list/controllers/helper_list_controller.dart';
import 'package:working_hiring/app/core/widgets/custom_appBar/custom_app_bar.dart';
import 'package:working_hiring/app/data/models/saved_helper_model.dart';
import 'package:working_hiring/app/data/repositories/helper_repository.dart';
import 'package:working_hiring/app/data/repositories/category_repository.dart';
import 'package:working_hiring/app/features/client/saved_helpers/views/saved_helpers/widgets/saved_helpers_saved_card.dart';
import 'package:working_hiring/app/features/client/saved_helpers/views/saved_helpers/widgets/shimmer/saved_helpers_shimmer.dart';

part 'saved_helpers_view_state.dart';

class SavedHelpersView extends StatefulWidget {
  const SavedHelpersView({super.key});

  @override
  State<SavedHelpersView> createState() => _SavedHelpersViewState();
}
