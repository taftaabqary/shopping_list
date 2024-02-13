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
  late Future<List<GroceryItem>> _futureNewData;

  @override
  void initState() {
    super.initState();
    _futureNewData = _loadNewListItem();
  }

  Future<List<GroceryItem>> _loadNewListItem() async {
    final url = Uri.https(
        'flutterprep-36c21-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping_list.json');
    final List<GroceryItem> newListItem = [];
    final response = await http.get(url);

    if (response.statusCode >= 400) {
      throw Exception('Failed to try fetching data, try again later');
    }

    if(response.body == 'null') {
      return [];
    } else {
      final Map<String, dynamic> listData = json.decode(response.body);

      for (final data in listData.entries) {
        final category = categories.entries
            .firstWhere((value) => value.value.title == data.value['category'])
            .value;
        newListItem.add(GroceryItem(
            id: data.key,
            name: data.value['name'],
            quantity: data.value['quantity'],
            category: category));
      }
    }

    return newListItem;
  }

  void _addNewItem() async {
    final newData = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (ctx) => const NewList()));

    if (newData == null) {
      return;
    }

    setState(() {
      groceryItem.add(newData);
    });
  }

  void _deleteGroceryItem(GroceryItem item) async {
    final indexItem = groceryItem.indexOf(item);
    setState(() {
      groceryItem.remove(item);
    });
    final url = Uri.https(
        'flutterprep-36c21-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping_list/${item.id}.json');
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

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      setState(() {
        groceryItem.insert(indexItem, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(onPressed: _addNewItem, icon: const Icon(Icons.add))
        ],
      ),
      body: FutureBuilder(
        future: _futureNewData,
        builder: (context, snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshots.hasError) {
            return Center(
              child: Text(
                'Error, ${snapshots.error.toString()}',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            );
          }

          if (snapshots.data!.isEmpty) {
            return Center(
                child: Text('You dont have any items yet, try to add some!',
                    style: Theme.of(context).textTheme.bodyLarge));
          }

          return ListView.builder(
              itemCount: snapshots.data!.length,
              itemBuilder: (context, index) => Dismissible(
                  onDismissed: (position) {
                    _deleteGroceryItem(snapshots.data![index]);
                  },
                  key: ValueKey(snapshots.data![index].id),
                  child: ListTile(
                    title: Text(snapshots.data![index].name),
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                          color: snapshots.data![index].category.color,
                          shape: BoxShape.rectangle),
                    ),
                    trailing: Text(snapshots.data![index].quantity.toString()),
                  )));
        },
      ),
    );
  }
}
