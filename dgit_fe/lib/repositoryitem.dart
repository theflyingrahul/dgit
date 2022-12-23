import 'package:flutter/material.dart';
import 'databaseprovider.dart';

class RepositoryItem extends StatefulWidget {
  Contract contract;
  TextEditingController input1;
  VoidCallback onDeletePress;

  RepositoryItem(
      {required this.contract,
      required this.input1,
      required this.onDeletePress});

  @override
  _RepositoryItemState createState() => _RepositoryItemState();
}

class _RepositoryItemState extends State<RepositoryItem> {
  final DatabaseProvider databaseProvider = new DatabaseProvider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.contract.id,
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
              CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  onPressed: widget.onDeletePress,
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DialogBox {
  Widget dialog(
      {required BuildContext context,
      required VoidCallback onPressed,
      required TextEditingController textEditingController1,
      required FocusNode input1FocusNode}) {
    return AlertDialog(
      title: Text("Enter Data"),
      content: Container(
        height: 100,
        child: TextFormField(
          controller: textEditingController1,
          keyboardType: TextInputType.text,
          focusNode: input1FocusNode,
          decoration: InputDecoration(hintText: "Contract ID"),
          autofocus: true,
          onFieldSubmitted: (value) {
            input1FocusNode.unfocus();
          },
        ),
      ),
      actions: [
        MaterialButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: Colors.blueGrey,
          child: Text(
            "Cancel",
          ),
        ),
        MaterialButton(
          onPressed: onPressed,
          child: Text("Submit"),
          color: Colors.blue,
        )
      ],
    );
  }
}
