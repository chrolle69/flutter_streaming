import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:streaming/features/home/data/models/enums.dart';
import 'package:streaming/features/home/data/repository/stream_repository_impl.dart';
import 'package:streaming/features/home/domain/stream_repository.dart';
import 'package:streaming/features/home/presentation/blocs/productState.dart';
import 'package:streaming/features/home/presentation/widgets/ProductDialog_PickColor.dart';
import 'package:streaming/features/home/presentation/widgets/ProductDialog_PickDescr.dart';
import 'package:streaming/features/home/presentation/widgets/ProductDialog_PickIncrement.dart';
import 'package:streaming/features/home/presentation/widgets/ProductDialog_PickName.dart';
import 'package:streaming/features/home/presentation/widgets/ProductDialog_PickPrice.dart';
import 'package:streaming/features/home/presentation/widgets/ProductDialog_PickSize.dart';
import 'package:streaming/features/home/presentation/widgets/ProductDialog_PickType.dart';
import 'package:streaming/features/home/presentation/widgets/ProductRowItemOwner.dart';

class OwnerPanel extends StatelessWidget {
  const OwnerPanel({
    super.key,
    required this.roomId,
  });
  final String roomId;

  @override
  Widget build(BuildContext context) {
    return _OwnerPanelState(roomId: roomId);
  }
}

class _OwnerPanelState extends StatelessWidget {
  final String roomId;
  const _OwnerPanelState({required this.roomId});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: FloatingActionButton(
                  child: Text("Add Product"),
                  onPressed: () => _dialogBuilder(context, roomId)),
            ),
            Expanded(
              child: FloatingActionButton(
                child: Text("Show Products"),
                onPressed: () {
                  showBottomSheetOwner(context, roomId);
                },
              ),
            ),
          ]),
    );
  }

  Future<void> showBottomSheetOwner(BuildContext context, String roomId) async {
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
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ProductRowItemOwner(
                              productState: productState,
                              index: i,
                            ),
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

Future<void> _dialogBuilder(BuildContext context, String roomId) {
  String productName = "";
  String productDescr = "";
  double startPrice = 0;
  double increase = 0;
  ProductType productType = ProductType.other;
  SimpleColor color = SimpleColor.other;
  ClothingSize size = ClothingSize.M;
  StreamRepository streamRep = StreamRepositoryImpl();

  void setName(String newName) {
    productName = newName;
  }

  void setDescr(String newDescr) {
    productDescr = newDescr;
  }

  void setPrice(double newPrice) {
    startPrice = newPrice;
  }

  void setIncrease(double newIncrease) {
    increase = newIncrease;
  }

  void setProductType(ProductType newType) {
    productType = newType;
  }

  void setColor(SimpleColor newColor) {
    color = newColor;
  }

  void setSize(ClothingSize newSize) {
    size = newSize;
  }

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return SingleChildScrollView(
        child: AlertDialog(
          title: const Text('New Product'),
          content: Column(
            children: [
              ProductDialogPickName(setName: setName),
              ProductDialogPickDescr(setDescr: setDescr),
              ProductDialogPickPrice(setPrice: setPrice),
              ProductDialogPickIncrement(setIncrease: setIncrease),
              ProductDialogPickType(setType: setProductType),
              ProductDialogPickColor(setColor: setColor),
              ProductDialogPickSize(setSize: setSize)
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Confirm'),
              onPressed: () {
                try {
                  streamRep.addProductOffer(roomId, productName, productDescr,
                      productType, size, color, startPrice, increase);
                } catch (e) {
                  print("Error: $e");
                  return;
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}
