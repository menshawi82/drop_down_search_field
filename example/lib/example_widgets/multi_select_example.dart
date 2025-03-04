import 'dart:math';

import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';

class MultiSelectDropdown extends StatefulWidget {
  const MultiSelectDropdown({super.key});

  @override
  State<MultiSelectDropdown> createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown> {
  final TextEditingController _dropdownSearchFieldController =
      TextEditingController();
  final List<String> _selectedNames = [];
  final List<String> names = [];
  SuggestionsBoxController suggestionBoxController = SuggestionsBoxController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String generateRandomName() {
    const characters = 'abcdefghijklmnopqrstuvwxyz';
    final random = Random();
    final length = random.nextInt(5) + 4; // Generates a length between 4 and 8
    return String.fromCharCodes(Iterable.generate(
      length,
      (_) => characters.codeUnitAt(random.nextInt(characters.length)),
    ));
  }

  List<String> getSuggestions(String query) {
    if (query.isNotEmpty) {
      final tempList = names
          .where((s) => s.toLowerCase().contains(query.toLowerCase()))
          .toList();
      return tempList;
    }
    int i = 0;
    while (i < 10) {
      names.add(generateRandomName());
      i++;
    }
    return names;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi Select Example'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const Text('What are your favorite names?'),
              MultiSelectDropdownSearchFormField<String>(
                textFieldConfiguration: TextFieldConfiguration(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Type to search',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  controller: _dropdownSearchFieldController,
                ),
                chipBuilder: (context, itemData) {
                  return Chip(
                    label: Text(itemData),
                    onDeleted: () {
                      _selectedNames.remove(itemData);
                      setState(() {});
                    },
                    backgroundColor: Colors.orange,
                    labelStyle: const TextStyle(color: Colors.white),
                    deleteIcon: const Icon(Icons.close, color: Colors.white),
                    deleteIconColor: Colors.white,
                    deleteButtonTooltipMessage: '',
                    side: const BorderSide(color: Colors.orange),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                },
                paginatedSuggestionsCallback: (pattern) async {
                  final suggestionsToReturn = getSuggestions(pattern);
                  return suggestionsToReturn;
                },
                initiallySelectedItems: _selectedNames,
                itemBuilder: (context, String suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                  );
                },
                suggestionsBoxDecoration: SuggestionsBoxDecoration(
                  scrollBarDecoration: ScrollBarDecoration(
                      thumbColor: Colors.orange, thickness: 10),
                ),
                itemSeparatorBuilder: (context, index) {
                  return const Divider();
                },
                transitionBuilder: (context, suggestionsBox, controller) {
                  return suggestionsBox;
                },
                onMultiSuggestionSelected:
                    (String suggestion, bool isSelected) {
                  // No need to set the text field value for multi-select
                  if (isSelected) {
                    _selectedNames.add(suggestion);
                  } else {
                    _selectedNames.remove(suggestion);
                  }
                  setState(() {});
                },
                suggestionsBoxController: suggestionBoxController,
                displayAllSuggestionWhenTap: true,
                dropdownBoxConfiguration: DropdownBoxConfiguration(
                  scrollbarConfiguration: ScrollbarConfiguration(thickness: 5),
                  enabled: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Selected Items',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                child: const Text('Submit'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Your favorite names are $_selectedNames.'),
                      ),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
