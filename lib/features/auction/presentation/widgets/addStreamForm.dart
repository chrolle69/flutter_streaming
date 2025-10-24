import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streaming/features/auction/presentation/blocs/streamBloc.dart';
import 'package:streaming/features/auction/presentation/blocs/streamEvent.dart';
import 'package:streaming/features/auction/presentation/blocs/streamState.dart';
import 'package:streaming/shared/data/models/enums.dart';

class AddStreamForm extends StatefulWidget {
  @override
  State<AddStreamForm> createState() => _AddStreamFormState();
}

class _AddStreamFormState extends State<AddStreamForm> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
            child: TitleTextField(),
          ),
          Flexible(
            child: DescriptionTextField(),
          ),
          PickTypesCard(),
        ],
      ),
    );
  }
}

class TitleTextField extends StatelessWidget {
  const TitleTextField({
    super.key,
  });

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
        context.read<StreamBloc>().add(SetTitleEvent(title: str));
      },
    );
  }
}

class DescriptionTextField extends StatelessWidget {
  const DescriptionTextField({
    super.key,
  });

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
        context.read<StreamBloc>().add(SetDescriptionEvent(description: str));
      },
    );
  }
}

class PickTypesCard extends StatelessWidget {
  const PickTypesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text(
              "Products",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            BlocBuilder<StreamBloc, StreamState>(
              builder: (context, state) {
                return Wrap(
                  spacing: 5,
                  children: ProductType.values.map((type) {
                    return ChoiceChip(
                      label: Text(type.name),
                      selected: state.types.contains(type),
                      onSelected: (bool isSelected) {
                        if (isSelected) {
                          context
                              .read<StreamBloc>()
                              .add(AddTypeEvent(type: type));
                        } else {
                          context
                              .read<StreamBloc>()
                              .add(RemoveTypeEvent(type: type));
                        }
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
