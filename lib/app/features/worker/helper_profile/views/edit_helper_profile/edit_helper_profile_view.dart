import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/worker/helper_profile/controllers/helper_profile_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:working_hiring/app/features/auth/sign_up/views/map_picker/map_picker_view.dart';
import 'package:working_hiring/app/core/widgets/responsive_layout.dart';
import 'package:working_hiring/app/features/worker/helper_profile/widgets/category_dropdown.dart';
import 'package:working_hiring/app/features/worker/helper_profile/views/edit_helper_profile/widgets/edit_helper_profile_text_field.dart';
import 'package:working_hiring/app/features/worker/helper_profile/views/edit_helper_profile/widgets/edit_helper_profile_read_only_text_field.dart';

part 'edit_helper_profile_view_state.dart';

class EditHelperProfileView extends StatefulWidget {
  const EditHelperProfileView({super.key});

  @override
  State<EditHelperProfileView> createState() => _EditHelperProfileViewState();
}
