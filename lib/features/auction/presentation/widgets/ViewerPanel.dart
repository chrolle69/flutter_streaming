import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streaming/features/auction/domain/repository/stream_repository.dart';
import 'package:streaming/features/auction/presentation/blocs/productBloc.dart';
import 'package:streaming/features/auction/presentation/blocs/productEvent.dart';
import 'package:streaming/features/auction/presentation/blocs/productState.dart';
import 'package:streaming/features/auction/presentation/widgets/BidButton.dart';
import 'package:streaming/features/auction/presentation/widgets/ProductRowItemViewer.dart';

class ViewerPanel extends StatelessWidget {
  const ViewerPanel({super.key, required this.roomId});
  final String roomId;

  @override
  Widget build(BuildContext context) {
    print("ViewerPanel roomId: $roomId");
    return Expanded(
      child: Center(
        child: FloatingActionButton(
          child: Text("Show Products"),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                // Provide a fresh ProductBloc here for this bottom sheet
                return BlocProvider(
                  create: (_) =>
                      ProductBloc(streamRep: context.read<StreamRepository>())
                        ..add(InitializeProductListener(roomId: roomId)),
                  child: _ProductBottomSheet(
                    roomId: roomId,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ProductBottomSheet extends StatelessWidget {
  final dynamic roomId;

  const _ProductBottomSheet({required this.roomId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, productState) {
        if (productState.products.isEmpty) {
          return SizedBox(
            height: 300,
            child: Center(child: Text("No Products Added")),
          );
        }

        return SizedBox(
          height: 500,
          child: ListView.builder(
            itemCount: productState.products.length,
            itemBuilder: (context, i) {
              final product = productState.products[i];

              return Card(
                child: ExpansionTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(product.name),
                      BidButton(
                        prod: product,
                        productState: productState,
                        roomId: roomId, // or roomId
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ProductRowItemViewer(
                        productState: productState,
                        index: i,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
