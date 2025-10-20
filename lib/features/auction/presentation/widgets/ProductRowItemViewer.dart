import 'package:flutter/material.dart';
import 'package:streaming/features/auction/domain/entities/productOffer.dart';
import 'package:streaming/features/auction/presentation/blocs/productState.dart';

class ProductRowItemViewer extends StatelessWidget {
  const ProductRowItemViewer({
    super.key,
    required this.productState,
    required this.index,
  });

  final ProductState productState;
  final int index;

  @override
  Widget build(BuildContext context) {
    final ProductOffer prod = productState.getProduct(index);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Container without Expanded but with full width
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color.fromARGB(255, 211, 211, 211)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Product Description",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                prod.descr.isEmpty ? "No Description" : prod.descr,
              ),
            ],
          ),
        ),
        // Row for Type, Size, Color
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Text("Type",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(prod.typeToString()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Text("Size",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(prod.sizeToString()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Text("Color",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(prod.colorToString()),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
