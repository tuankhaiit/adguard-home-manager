import 'dart:collection';

import 'package:adguard_home_manager/models/clients.dart';
import 'package:adguard_home_manager/models/logs.dart';
import 'package:flutter/foundation.dart';

import 'logs_provider.dart';

class ClientsWrapperProvider with ChangeNotifier {
  final LogsProvider _logsProvider;

  ClientsWrapperProvider(this._logsProvider);

  Future<List<Client>> sortClients(List<Client> clients) async {
    final List<Client> sortedClients = List.of(clients);
    final List<Log?> logs = await getLogsByClients(clients);
    final HashMap<String, DateTime> clientAccessTimeMap = HashMap();
    logs.where((log) => log != null).forEach((log) => clientAccessTimeMap.putIfAbsent(log!.client, () => log.time));
    // Append latest access time
    for (var client in sortedClients) {
      client.latestAccessTime = clientAccessTimeMap[client.ids.first];
    }
    // Sort by access time
    sortedClients.sort((client1, client2) {
      if (client1.latestAccessTime == null) {
        return 1;
      } else if (client2.latestAccessTime == null) {
        return -1;
      } else {
        return client2.latestAccessTime!.compareTo(client1.latestAccessTime!);
      }
    });
    return sortedClients;
  }

  Future<List<Log?>> getLogsByClients(List<Client> clients) async {
    return Future.wait(clients.map((client) => _logsProvider.fetchLatestLogByClient(client)));
  }
}
