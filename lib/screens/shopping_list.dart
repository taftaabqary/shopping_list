import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_shopping_list/data/categories.dart';
import 'package:flutter_shopping_list/screens/new_list.dart';
import 'package:http/http.dart' as http;
import '../models/grocery_item.dart';

class ShoppingList extends StatefulWidget {
  const ShoppingList({super.key});

  @override
  State<ShoppingList> createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  List<GroceryItem> groceryItem = [];

  @override
  void initState() {
    super.initState();
    _loadNewListItem();
  }

  void _loadNewListItem() async {
    final url = Uri.https(
        'flutterprep-36c21-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping_list.json');
    final response = await http.get(url);
    final Map<String, dynamic> listData = json.decode(response.body);

    final List<GroceryItem> newListItem = [];

    for (final data in listData.entries) {
      final category = categories.entries.firstWhere((value) => value.value.title == data.value['category']).value;
      newListItem.add(GroceryItem(
          id: data.key,
          name: data.value['name'],
          quantity: data.value['quantity'],
          category: category
      ));
    }

    setState(() {
      groceryItem = newListItem;
    });
  }

  void _addNewItem() async {
    await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (ctx) => const NewList()));

    _loadNewListItem();
  }

  void _deleteGroceryItem(GroceryItem item) {
    final indexItem = groceryItem.indexOf(item);
    setState(() {
      groceryItem.remove(item);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Remove ${item.name} from the list'),
      action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              groceryItem.insert(indexItem, item);
            });
          }),
    ));
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent = Center(
        child: Text('You dont have any items yet, try to add some!',
            style: Theme.of(context).textTheme.bodyLarge));

    if (groceryItem.isNotEmpty) {
      mainContent = ListView.builder(
          itemCount: groceryItem.length,
          itemBuilder: (context, index) => Dismissible(
              onDismissed: (position) {
                _deleteGroceryItem(groceryItem[index]);
              },
              key: ValueKey(groceryItem[index].id),
              child: ListTile(
                title: Text(groceryItem[index].name),
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                      color: groceryItem[index].category.color,
                      shape: BoxShape.rectangle),
                ),
                trailing: Text(groceryItem[index].quantity.toString()),
              )));
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Groceries'),
          actions: [
            IconButton(onPressed: _addNewItem, icon: const Icon(Icons.add))
          ],
        ),
        body: mainContent);
  }
}
