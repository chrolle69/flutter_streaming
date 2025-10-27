import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streaming/shared/data/models/enums.dart';
import 'package:streaming/features/auction/domain/repository/stream_repository.dart';
import 'package:streaming/features/auction/presentation/blocs/productEvent.dart';
import 'package:streaming/features/auction/presentation/blocs/productBloc.dart';
import 'package:streaming/features/auction/presentation/blocs/productState.dart';
import 'package:streaming/features/auction/presentation/widgets/ProductDialog_PickColor.dart';
import 'package:streaming/features/auction/presentation/widgets/ProductDialog_PickDescr.dart';
import 'package:streaming/features/auction/presentation/widgets/ProductDialog_PickIncrement.dart';
import 'package:streaming/features/auction/presentation/widgets/ProductDialog_PickName.dart';
import 'package:streaming/features/auction/presentation/widgets/ProductDialog_PickPrice.dart';
import 'package:streaming/features/auction/presentation/widgets/ProductDialog_PickSize.dart';
import 'package:streaming/features/auction/presentation/widgets/ProductDialog_PickType.dart';
import 'package:streaming/features/auction/presentation/widgets/ProductRowItemOwner.dart';

class OwnerPanel extends StatelessWidget {
  const OwnerPanel({super.key, required this.roomId});
  final String roomId;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: FloatingActionButton(
              child: Text("Add Product"),
              onPressed: () => _showAddProductDialog(context),
            ),
          ),
          Expanded(
            child: FloatingActionButton(
              child: Text("Show Products"),
              onPressed: () => _showProductsBottomSheet(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showProductsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return BlocProvider(
          create: (_) =>
              ProductBloc(streamRep: context.read<StreamRepository>())
                ..add(InitializeProductListener(roomId: roomId)),
          child: _ProductBottomSheetOwner(),
        );
      },
    );
  }

  void _showAddProductDialog(BuildContext context) {
    String name = "";
    String description = "";
    double startPrice = 0;
    double increase = 0;
    ProductType type = ProductType.other;
    SimpleColor color = SimpleColor.other;
    ClothingSize size = ClothingSize.M;

    showDialog<void>(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: const Text('New Product'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProductDialogPickName(setName: (val) => name = val),
                ProductDialogPickDescr(setDescr: (val) => description = val),
                ProductDialogPickPrice(setPrice: (val) => startPrice = val),
                ProductDialogPickIncrement(
                    setIncrease: (val) => increase = val),
                ProductDialogPickType(setType: (val) => type = val),
                ProductDialogPickColor(setColor: (val) => color = val),
                ProductDialogPickSize(setSize: (val) => size = val),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('Confirm'),
                onPressed: () {
                  // Add product using the Bloc from the bottom sheet if open
                  final bloc = context.read<ProductBloc>();
                  bloc.add(AddProductOfferEvent(
                    roomId: roomId,
                    name: name,
                    description: description,
                    type: type,
                    size: size,
                    color: color,
                    startPrice: startPrice,
                    increase: increase,
                  ));
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProductBottomSheetOwner extends StatelessWidget {
  const _ProductBottomSheetOwner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state.products.isEmpty) {
          return SizedBox(
            height: 300,
            child: Center(child: Text("No Products Added")),
          );
        }

        return SizedBox(
          height: 500,
          child: ListView.builder(
            itemCount: state.products.length,
            itemBuilder: (context, i) {
              final product = state.products[i];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ProductRowItemOwner(productOffer: product),
              );
            },
          ),
        );
      },
    );
  }
}
