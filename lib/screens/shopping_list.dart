import 'package:flutter/material.dart';
import 'package:flutter_shopping_list/screens/new_list.dart';
import '../models/grocery_item.dart';

class ShoppingList extends StatefulWidget {
  const ShoppingList({super.key});

  @override
  State<ShoppingList> createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  final List<GroceryItem> groceryItem = [];

  void _addNewItem() async {
    final newItemData = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (ctx) => const NewList()
        )
    );

    if (newItemData == null) {
      return;
    }

    setState(() {
      groceryItem.add(newItemData);
    });
  }

  void _deleteGroceryItem(GroceryItem item) {
    final indexItem = groceryItem.indexOf(item);
    setState(() {
      groceryItem.remove(item);
    });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Remove ${item.name} from the list'),
            action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  setState(() {
                    groceryItem.insert(indexItem, item);
                  });
                }
            ),
          )
      );

  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent = Center(
      child: Text('You dont have any items yet, try to add some!', style: Theme
          .of(context)
          .textTheme
          .bodyLarge
      )
    );

    if(groceryItem.isNotEmpty) {
      mainContent = ListView.builder(
          itemCount: groceryItem.length,
          itemBuilder: (context, index) => Dismissible(
            onDismissed: (position) {
              _deleteGroceryItem(groceryItem[index]);
            },
              key: ValueKey(groceryItem[index]),
              child:  ListTile(
                title: Text(groceryItem[index].name),
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                      color: groceryItem[index].category.color,
                      shape: BoxShape.rectangle
                  ),
                ),
                trailing: Text(groceryItem[index].quantity.toString()),
              )
          )
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
              onPressed: _addNewItem,
              icon: const Icon(Icons.add)
          )
        ],
      ),
      body:  mainContent
    );
  }
}