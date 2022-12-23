import 'dart:async';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/sqlite_api.dart';

class DatabaseProvider {
  late Database _database;
  Future openDatabase() async {
    sqfliteFfiInit();
    _database = await databaseFactoryFfi.openDatabase("/data2/web3/contracts_database.db");

    // Uncomment this line when new DB/Table creation is required! Need to happen dynamically but doesn't work as of now!
      // await _database.execute("CREATE TABLE contracts(id TEXT PRIMARY KEY)");
    return _database;
  }

  Future insertContract(Contract contract) async {
    await openDatabase();
    return await _database.insert('contracts', contract.toJson());
  }

  Future<List<Contract>> getContractList() async {
    await openDatabase();
    final List<Map<String, dynamic>> maps = await _database.query('contracts');


    // implement pull dGit DS from Solidity


    return List.generate(maps.length, (i) {
      return Contract(id: maps[i]['id']);
    });
  }

  // Disabling function: Smart Contract address can't be simply edited! Need to delete and add a new contract only!
  // Future<int> updateContract(Contract contract) async {
  //   await openDatabase();
  //   print(contract.toJson());
  //   return await _database.update('contracts', contract.toJson(),
  //       where: "id = ?", whereArgs: [contract.id]);
  // }

  Future<void> deleteContract(Contract contract) async {
    await openDatabase();
    await _database
        .delete('contracts', where: "id = ?", whereArgs: [contract.id]);
  }
}

class Contract {
  String id;
  Contract({required this.id});

  Contract fromJson(json) {
    return Contract(id: json['id']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id};
  }

  // implement dGit DS
}
