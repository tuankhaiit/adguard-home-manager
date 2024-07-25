import 'package:adguard_home_manager/models/clients.dart';
import 'package:adguard_home_manager/models/logs.dart';
import 'package:flutter/foundation.dart';

import '../config/logger.dart';
import 'logs_provider.dart';

class ClientsWrapperProvider with ChangeNotifier {
  final LogsProvider _logsProvider;

  ClientsWrapperProvider(this._logsProvider);

  Future<List<Client>> sortClients(List<Client> clients) async {
    final List<Client> sortedClients = List.of(clients);
    logger.d('Clients ${clients.length}');
    final List<Log?> logs = await getLogsByClients(clients);
    logger.d('Logs ${logs.length}');
    sortedClients.sort((client1, client2) =>
        logs.indexWhere((log) => client1.ids.first == log?.client)
            .compareTo(logs.indexWhere((log) => client2.ids.first == log?.client))
    );
    logger.d('Sorted clients ${sortedClients.length}');
    return sortedClients;
  }

  Future<List<Log?>> getLogsByClients(List<Client> clients) async {
    return Future.wait(clients.map((client) => _logsProvider.fetchLatestLogByClient(client)));
  }
}
