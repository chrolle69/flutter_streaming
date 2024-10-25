import 'package:flutter/material.dart';
import 'package:streaming/features/home/domain/entities/stream.dart';
import 'package:provider/provider.dart';
import 'package:streaming/features/home/presentation/blocs/addStreamState.dart';




class AddStreamForm extends StatefulWidget {
  @override
  State<AddStreamForm> createState() => _AddStreamFormState();
}

class _AddStreamFormState extends State<AddStreamForm> {
  @override
  Widget build(BuildContext context) {    
    var addStreamState = context.watch<AddStreamState>();

    return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: TitleTextField(addStreamState: addStreamState),
            ),
            Flexible(
              child: DescriptionTextField(addStreamState: addStreamState),
            ),
            PickTypesCard(addStreamState: addStreamState),
          ],
        ),
    );
  }
}

class TitleTextField extends StatelessWidget {
  const TitleTextField({
    super.key,
    required this.addStreamState,
  });

  final AddStreamState addStreamState;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: "Title",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: (String str) {
        addStreamState.setTitle(str);
      },
    );
  }
}

class DescriptionTextField extends StatelessWidget {
  const DescriptionTextField({
    super.key,
    required this.addStreamState,
  });

  final AddStreamState addStreamState;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: "Description",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: (String str) {
        addStreamState.setDescription(str);
      },
    );
  }
}

class PickTypesCard extends StatelessWidget {
  const PickTypesCard({
    super.key,
    required this.addStreamState,
  });

  final AddStreamState addStreamState;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              "Products",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
              ),
            Wrap(
              spacing: 5,
              children: List<Widget>.generate(ProductType.values.length, (i) {
                return ChoiceChip(
                  label: Text(ProductType.values[i].name), 
                  selected: addStreamState.contains(ProductType.values[i]),
                  onSelected: (bool isSelected) {
                    if (isSelected) {
                      addStreamState.addType(ProductType.values[i]);
                    } else {
                      addStreamState.removeType(ProductType.values[i]);
                    }
                  },
                  );
              })
            ),
          ],
        ),
      ),
    );
  }
}