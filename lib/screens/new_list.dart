import 'package:flutter/material.dart';
import 'package:flutter_shopping_list/data/categories.dart';
import 'package:flutter_shopping_list/models/category.dart';
import 'package:flutter_shopping_list/models/grocery_item.dart';

class NewList extends StatefulWidget {
  const NewList({super.key});

  @override
  State<NewList> createState() {
    return _NewListState();
  }
}

class _NewListState extends State<NewList> {
  final _keyForm = GlobalKey<FormState>();
  var _titleValue = '';
  var _quantityValue = 0;
  var _selectedCategory = categories[Categories.vegetables];

  void _addNewItem() {
    if(_keyForm.currentState!.validate()) {
      _keyForm.currentState!.save();

      Navigator.of(context).pop(GroceryItem(
          id: DateTime.now().toString(),
          name: _titleValue,
          quantity: _quantityValue,
          category: _selectedCategory!
          )
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add your new item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _keyForm,
          child: Column(
          children: [
            TextFormField(
              maxLength: 50,
              decoration: const InputDecoration(
                label: Text('Title'),
              ),
              validator: (value) {
                if(value == null || value.isEmpty || value.trim().length <= 1 || value.trim().length > 50) {
                  return 'Make sure to enter the value between 1 - 50 characters';
                }
                return null;
              },
              onSaved: (value) {
                _titleValue = value!;
              },
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      label: Text('Quantity'),
                    ),
                    initialValue: '1',
                    validator: (value) {
                      if(value == null || value.isEmpty || int.tryParse(value) == null || int.tryParse(value)! <= 0) {
                        return 'Make sure to enter only positive number';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _quantityValue = int.parse(value!);
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        for(final category in categories.entries)
                          DropdownMenuItem(
                              value: category.value,
                              child: Row(
                                children: [
                                  Container(
                                    width: 14,
                                    height: 14,
                                    color: category.value.color,
                                  ),
                                  const SizedBox(width: 14),
                                  Text(category.value.title)
                                ],
                              )
                          )
                      ],
                      onChanged: (category) {
                        _selectedCategory = category;
                      }
                  ),
                )
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () {
                      _keyForm.currentState!.reset();
                    },
                    child: const Text('Reset')
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                    onPressed: _addNewItem,
                    child: const Text('Submit')
                )
              ],
            )
          ],
        ),
        ),
      ),
    );
  }
}