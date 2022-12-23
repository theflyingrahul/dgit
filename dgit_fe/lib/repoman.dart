import 'repositoryitem.dart';
import 'package:flutter/material.dart';
import 'databaseprovider.dart';

class RepositoryManager extends StatefulWidget {
  @override
  _RepositoryManagerState createState() => _RepositoryManagerState();
}

class _RepositoryManagerState extends State<RepositoryManager> {
  final DatabaseProvider databaseProvider = new DatabaseProvider();

  late Contract contract;
  late List<Contract> contractList;
  TextEditingController input1 = TextEditingController();
  late FocusNode input1FocusNode;

  @override
  void initState() {
    input1FocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    input1FocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Repository Manager'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return DialogBox().dialog(
                  context: context,
                  onPressed: () {
                    Contract contract = new Contract(id: input1.text);
                    databaseProvider.insertContract(contract);
                    setState(() {
                      input1.text = "";
                    });
                    Navigator.of(context).pop();
                  },
                  textEditingController1: input1,
                  input1FocusNode: input1FocusNode,
                );
              });
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: FutureBuilder(
        future: databaseProvider.getContractList(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            contractList = snapshot.data!;
            return ListView.builder(
              itemCount: contractList.length,
              itemBuilder: (context, index) {
                Contract _contract = contractList[index];
                return RepositoryItem(
                  contract: _contract,
                  input1: input1,
                  onDeletePress: () {
                    databaseProvider.deleteContract(_contract);
                    setState(() {});
                  },
                );
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
