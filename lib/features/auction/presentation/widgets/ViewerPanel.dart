import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:streaming/features/home/presentation/blocs/productState.dart';
import 'package:streaming/features/home/presentation/widgets/BidButton.dart';
import 'package:streaming/features/home/presentation/widgets/ProductRowItemViewer.dart';

class ViewerPanel extends StatelessWidget {
  const ViewerPanel({
    super.key,
    required this.roomId,
  });
  final String roomId;

  @override
  Widget build(BuildContext context) {
    return _ViewerPanelState(roomId: roomId);
  }
}

class _ViewerPanelState extends StatelessWidget {
  final String roomId;
  const _ViewerPanelState({required this.roomId});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: FloatingActionButton(
              child: Text("Show Products"),
              onPressed: () {
                showBottomSheetViewer(context, roomId);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> showBottomSheetViewer(
      BuildContext context, String roomId) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ChangeNotifierProvider(
          create: (_) => ProductState(roomId),
          child: Consumer<ProductState>(
            builder: (context, productState, child) {
              return SizedBox(
                height: 500,
                width: MediaQuery.of(context).size.width,
                child: productState.getProducts().isEmpty
                    ? Center(child: Text("No Products Added"))
                    : ListView.builder(
                        itemCount: productState.productList.length,
                        itemBuilder: (BuildContext context, int i) {
                          return Card(
                            child: ExpansionTile(
                                shape: Border(),
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(productState.getProduct(i).name),
                                    BidButton(
                                        prod: productState.getProduct(i),
                                        productState: productState)
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
                                ]),
                          );
                        },
                      ),
              );
            },
          ),
        );
      },
    );
  }
}
