import 'package:get/get.dart';
// category_multi_select.dart
import 'package:flutter/material.dart';
import 'package:working_hiring/app/data/models/category_model.dart';

class CategoryMultiSelect extends StatefulWidget {
  final List<CategoryModel> categories;
  final List<int> selectedIds;
  final Function(int) onToggle;

  CategoryMultiSelect({
    Key? key,
    required this.categories,
    required this.selectedIds,
    required this.onToggle,
  }) : super(key: key);

  @override
  State<CategoryMultiSelect> createState() => _CategoryMultiSelectState();
}

class _CategoryMultiSelectState extends State<CategoryMultiSelect> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          'Service Categories'.tr,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        SizedBox(height: 8),

        // Dropdown field (always visible)
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: _getSelectedChips(),
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),

        // Expanded dropdown list with checkboxes
        AnimatedSize(
          duration: Duration(milliseconds: 200),
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
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 200),
              child: ListView(
                shrinkWrap: true,
                children: widget.categories.map((cat) {
                  final isSelected = widget.selectedIds.contains(cat.id);
                  return CheckboxListTile(
                    title: Text(cat.title ?? ''),
                    value: isSelected,
                    onChanged: (_) => widget.onToggle(cat.id),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  );
                }).toList(),
              ),
            ),
          )
              : SizedBox.shrink(),
        ),
      ],
    );
  }

  List<Widget> _getSelectedChips() {
    if (widget.selectedIds.isEmpty) {
      return [
        Text(
          'Select categories'.tr,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        ),
      ];
    }

    return widget.selectedIds.map((id) {
      final cat = widget.categories.firstWhere(
            (c) => c.id == id,
        orElse: () => CategoryModel(id: id, title: 'Unknown'.tr),
      );
      return Chip(
        label: Text(cat.title ?? ''),
        backgroundColor: Color(0xFF4CAF50).withOpacity(0.1),
        labelStyle: TextStyle(fontSize: 12, color: Color(0xFF4CAF50)),
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        deleteIcon: Icon(Icons.close, size: 14, color: Color(0xFF4CAF50)),
        onDeleted: () => widget.onToggle(id),
      );
    }).toList();
  }
}
