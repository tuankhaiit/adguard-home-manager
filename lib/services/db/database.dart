import 'package:sqflite/sqflite.dart';

import '../../functions/base64.dart';
import '../../widgets/add_server/add_server_modal.dart';

Future<Map<String, dynamic>> loadDb() async {
  List<Map<String, Object?>>? servers;

  Database db = await openDatabase(
    'adguard_home_manager.db',
    version: 11,
    onCreate: (Database db, int version) async {
      await db.execute(
        """
          CREATE TABLE 
            servers (
              id TEXT PRIMARY KEY, 
              name TEXT, 
              connectionMethod TEXT, 
              domain TEXT, 
              path TEXT, 
              port INTEGER, 
              user TEXT, 
              password TEXT, 
              defaultServer INTEGER, 
              authToken TEXT, 
              runningOnHa INTEGER
            )
        """
      );
      await db.transaction((txn) async {
        await txn.insert(
            'servers',
            {
              'id' : '0',
              'name' : 'Home',
              'connectionMethod' : ConnectionType.http.name,
              'domain' : 'home.net',
              'path' : null,
              'port' : 85,
              'user' : 'admin',
              'password' : 'Tuankhai@0811',
              'defaultServer' : 1,
              'authToken' : encodeBase64UserPass('admin', 'Tuankhai@0811'),
              'runningOnHa' : 0
            }
        );
        return null;
      });
    },
    onOpen: (Database db) async {
      await db.transaction((txn) async{
        servers = await txn.rawQuery(
          'SELECT * FROM servers',
        );
      });
    }
  );

  return {
    "servers": servers,
    "dbInstance": db,
  };
}