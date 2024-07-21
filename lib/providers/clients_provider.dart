import 'package:flutter/material.dart';

import 'package:adguard_home_manager/services/api_client.dart';
import 'package:adguard_home_manager/models/clients.dart';
import 'package:adguard_home_manager/functions/maps_fns.dart';
import 'package:adguard_home_manager/providers/status_provider.dart';
import 'package:adguard_home_manager/providers/servers_provider.dart';
import 'package:adguard_home_manager/models/clients_allowed_blocked.dart';
import 'package:adguard_home_manager/constants/enums.dart';

enum AccessSettingsList { allowed, disallowed, domains }

class ClientsProvider with ChangeNotifier {
  ServersProvider? _serversProvider;

  update(ServersProvider? servers, StatusProvider? status) {
    _serversProvider = servers;
  }

  LoadStatus _loadStatus = LoadStatus.loading;
  Clients? _clients;
  String? _searchTermClients;
  List<AutoClient> _filteredActiveClients = [];
  List<Client> _filteredAddedClients = [];

  LoadStatus get loadStatus {
    return _loadStatus;
  }

  Clients? get clients {
    return _clients;
  }

  String? get searchTermClients {
    return _searchTermClients;
  }

  List<AutoClient> get filteredActiveClients {
    return _filteredActiveClients;
  }

  List<Client> get filteredAddedClients {
    return _filteredAddedClients;
  }

  void setClientsLoadStatus(LoadStatus status, bool notify) {
    _loadStatus = status;
    if (notify == true) {
      notifyListeners();
    }
  }

  void setClientsData(Clients data, bool notify) {
    _clients = data;
    if (_searchTermClients != null && _searchTermClients != '') {
      _filteredActiveClients = _clients!.autoClients.where(
        (client) => client.ip.contains(_searchTermClients!.toLowerCase()) || (client.name != null ? client.name!.contains(_searchTermClients!.toLowerCase()) : false)
      ).toList();
      _filteredAddedClients = _clients!.clients.where(
        (client) {
          isContained(String value) => value.contains(value.toLowerCase());
          return client.ids.any(isContained);
        }
      ).toList();
    }
    else {
      _filteredActiveClients = data.autoClients;
      _filteredAddedClients = data.clients;
    }
    if (notify == true) notifyListeners();
  }

  void setSearchTermClients(String? value) {
    _searchTermClients = value;
    if (value != null && value != '') {
      if (_clients != null) {
        _filteredActiveClients = _clients!.autoClients.where(
          (client) => client.ip.contains(value.toLowerCase()) || (client.name != null ? client.name!.contains(value.toLowerCase()) : false)
        ).toList();
        _filteredAddedClients = _clients!.clients.where(
          (client) {
            isContained(String value) => value.contains(value.toLowerCase());
            return client.ids.any(isContained);
          }
        ).toList();
      }
    }
    else {
      if (_clients != null) _filteredActiveClients = _clients!.autoClients;
      if (_clients != null) _filteredAddedClients = _clients!.clients;
    }
    notifyListeners();
  }

  void setAllowedDisallowedClientsBlockedDomains(ClientsAllowedBlocked data) {
    _clients?.clientsAllowedBlocked = data;
    notifyListeners();
  }

  Future<bool> fetchClients({
    bool? updateLoading
  }) async {
    if (updateLoading == true) {
      _loadStatus = LoadStatus.loading;
    }
    final result = await _serversProvider!.apiClient2!.getClients();
    if (result.successful == true) {
      setClientsData(result.content as Clients, false);
      _loadStatus = LoadStatus.loaded;
      notifyListeners();
      return true;
    }
    else {
      if (updateLoading == true) {
        _loadStatus = LoadStatus.error;
        notifyListeners();
      }
      return false;
    }
  }

  Future<bool> deleteClient(Client client) async {
    final result = await _serversProvider!.apiClient2!.postDeleteClient(name: client.name);

    if (result.successful == true) {
      Clients clientsData = clients!;
      clientsData.clients = clientsData.clients.where((c) => c.name != client.name).toList();
      setClientsData(clientsData, false);

      notifyListeners();
      return true;
    }
    else {
      return false;
    }
  }

  Future<bool> editClient(Client client) async {      
    final result = await _serversProvider!.apiClient2!.postUpdateClient(
      data: {
        'name': client.identity,
        'data': removePropFromMap(client.toJson(), 'safe_search')
      }
    );

    if (result.successful == true) {
      Clients clientsData = clients!;
      clientsData.clients = clientsData.clients.map((e) {
        if (e.name == client.name) {
          return client;
        }
        else {
          return e;
        }
      }).toList();
      setClientsData(clientsData, false);

      notifyListeners();
      return true;
    }
    else {
      notifyListeners();
      return false;
    }
  }

  Future<bool> addClient(Client client) async {
    final result = await _serversProvider!.apiClient2!.postAddClient(
      data: removePropFromMap(client.toJson(), 'safe_search')
    );

    if (result.successful == true) {
      Clients clientsData = clients!;
      clientsData.clients.add(client);
      setClientsData(clientsData, false);

      notifyListeners();
      return true;
    }
    else {
      notifyListeners();
      return false;
    }
  }

  Future<ApiResponse> addClientList(String item, AccessSettingsList type) async {
    Map<String, List<String>> body = {
      "allowed_clients": clients!.clientsAllowedBlocked?.allowedClients ?? [],
      "disallowed_clients": clients!.clientsAllowedBlocked?.disallowedClients ?? [],
      "blocked_hosts": clients!.clientsAllowedBlocked?.blockedHosts ?? [],
    };

    if (body['allowed_clients']!.contains(item)) {
      body['allowed_clients'] = body['allowed_clients']!.where((e) => e != item).toList();
    }
    else if (body['disallowed_clients']!.contains(item)) {
      body['disallowed_clients'] = body['disallowed_clients']!.where((e) => e != item).toList();
    }
    else if (body['blocked_hosts']!.contains(item)) {
      body['blocked_hosts'] = body['blocked_hosts']!.where((e) => e != item).toList();
    }

    if (type == AccessSettingsList.allowed) {
      body['allowed_clients']!.add(item);
    }
    else if (type == AccessSettingsList.disallowed) {
      body['disallowed_clients']!.add(item);
    }
    else if (type == AccessSettingsList.domains) {
      body['blocked_hosts']!.add(item);
    }

    final result = await _serversProvider!.apiClient2!.requestAllowedBlockedClientsHosts(
      body: body
    );

    if (result.successful == true) {
      _clients?.clientsAllowedBlocked = ClientsAllowedBlocked(
        allowedClients: body['allowed_clients'] ?? [], 
        disallowedClients: body['disallowed_clients'] ?? [], 
        blockedHosts: body['blocked_hosts'] ?? [], 
      );
      notifyListeners();
      return result;
    }
    else if (result.successful == false && result.content == 'client_another_list') {
      notifyListeners();
      return result;
    }
    else {
      notifyListeners();
      return result;
    }
  }

  AccessSettingsList? checkClientList(String client) {
    if (_clients!.clientsAllowedBlocked!.allowedClients.contains(client)) {
      return AccessSettingsList.allowed;
    }
    else if (_clients!.clientsAllowedBlocked!.disallowedClients.contains(client)) {
      return AccessSettingsList.disallowed;
    }
    else {
      return null;
    }
  }

  Future<ApiResponse> removeClientList(String client, AccessSettingsList type) async {
    Map<String, List<String>> body = {
      "allowed_clients": clients!.clientsAllowedBlocked?.allowedClients ?? [],
      "disallowed_clients": clients!.clientsAllowedBlocked?.disallowedClients ?? [],
      "blocked_hosts": clients!.clientsAllowedBlocked?.blockedHosts ?? [],
    };

    if (type == AccessSettingsList.allowed) {
      body['allowed_clients'] = body['allowed_clients']!.where((c) => c != client).toList();
    }
    else if (type == AccessSettingsList.disallowed) {
      body['disallowed_clients'] = body['disallowed_clients']!.where((c) => c != client).toList();
    }
    else if (type == AccessSettingsList.domains) {
      body['blocked_hosts'] = body['blocked_hosts']!.where((c) => c != client).toList();
    }

    final result = await _serversProvider!.apiClient2!.requestAllowedBlockedClientsHosts(
      body: body
    );

    if (result.successful == true) {
      _clients?.clientsAllowedBlocked = ClientsAllowedBlocked(
        allowedClients: body['allowed_clients'] ?? [], 
        disallowedClients: body['disallowed_clients'] ?? [], 
        blockedHosts: body['blocked_hosts'] ?? [], 
      );
      notifyListeners();
      return result;
    }
    else if (result.successful == false && result.content == 'client_another_list') {
      notifyListeners();
      return result;
    }
    else {
      notifyListeners();
      return result;
    }
  }
}