import 'package:flutter/material.dart';
import 'package:streaming/features/home/data/models/enums.dart';

class ProductDialogPickType extends StatefulWidget {
  const ProductDialogPickType({
    super.key,
    required this.setType,
  });
  final Function(ProductType) setType;

  @override
  State<ProductDialogPickType> createState() => _PickTypeState();
}

class _PickTypeState extends State<ProductDialogPickType> {
  ProductType? selectedColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownMenu<ProductType>(
        initialSelection: ProductType.other,
        requestFocusOnTap: true,
        label: const Text('Product Type'),
        onSelected: (ProductType? type) {
          setState(() {
            selectedColor = type;
          });
          widget.setType(type!);
        },
        dropdownMenuEntries: ProductType.values
            .map<DropdownMenuEntry<ProductType>>((ProductType type) {
          return DropdownMenuEntry<ProductType>(
            value: type,
            label: type.name,
          );
        }).toList(),
      ),
    );
  }
}
