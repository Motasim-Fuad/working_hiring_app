part of 'category_dropdown.dart';

class _CategoryDropdownState extends State<CategoryDropdown> {
  bool _isExpanded = false;
  HelperProfileController get c => Get.find<HelperProfileController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Categories'.tr,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isExpanded ? Color(0xFF4CAF50) : Colors.grey.shade300,
                width: _isExpanded ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() {
                    final selected = c.selectedCategoryIds;
                    if (selected.isEmpty) {
                      return Text(
                        'Select categories'.tr,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      );
                    }
                    return Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: selected.map((id) {
                        final cat = c.availableCategories.firstWhere(
                          (cat) => cat.id == id,
                          orElse: () =>
                              CategoryModel(id: id, title: 'Unknown'.tr),
                        );
                        return Chip(
                          label: Text(cat.title ?? ''),
                          backgroundColor: Color(
                            0xFF4CAF50,
                          ).withValues(alpha: 0.1),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4CAF50),
                          ),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          deleteIcon: Icon(
                            Icons.close,
                            size: 14,
                            color: Color(0xFF4CAF50),
                          ),
                          onDeleted: () => c.toggleCategory(id),
                        );
                      }).toList(),
                    );
                  }),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: _isExpanded
              ? Container(
                  margin: EdgeInsets.only(top: 4),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: Obx(() {
                      final categories = c.availableCategories;
                      final selectedIds = c.selectedCategoryIds;
                      if (categories.isEmpty && c.isLoading.value) {
                        return Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (categories.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Text('No categories available'.tr),
                          ),
                        );
                      }
                      return ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 200),
                        child: ListView(
                          shrinkWrap: true,
                          children: categories.map((cat) {
                            final isSelected = selectedIds.contains(cat.id);
                            return CheckboxListTile(
                              title: Text(cat.title ?? ''),
                              value: isSelected,
                              onChanged: (_) => c.toggleCategory(cat.id),
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }),
                  ),
                )
              : SizedBox.shrink(),
        ),
      ],
    );
  }
}
