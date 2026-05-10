import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class CustomDropdownSearch<T> extends StatelessWidget {
  final List<T> items;
  final T? selectedItem;
  final String Function(T) itemLabelBuilder;
  final bool Function(T, T)? compareFn;
  final Function(T?) onChanged;
  final String hintText;
  var enabled;

  CustomDropdownSearch({
    super.key,
    required this.items,
    this.selectedItem,
    required this.itemLabelBuilder,
    this.compareFn,
    required this.onChanged,
    this.hintText = "Select Option",
    this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<T>(
      enabled: enabled ?? true,
      items: (filter, loadProps) => items,
      itemAsString: itemLabelBuilder,
      compareFn: compareFn,
      selectedItem: selectedItem,
      onChanged: onChanged,
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xff0084f7)),
          ),
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 12),
        ),
      ),
      popupProps: PopupProps.menu(
        showSearchBox: true,
        fit: FlexFit.loose,
        // 1. Popup ka background white karne ke liye
        containerBuilder: (context, popupWidget) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: popupWidget,
          );
        },
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            isDense: true,
            hintText: "Search...",
            hintStyle: const TextStyle(fontSize: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
        // 2. Item ka font size 13 karne ke liye
        itemBuilder: (context, item, isSelected, isHovered) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Text(
              itemLabelBuilder(item),
              style: const TextStyle(
                fontSize: 13, // Aapka bataya hua font size
                color: Colors.black87,
              ),
            ),
          );
        },
      ),
    );
  }
}