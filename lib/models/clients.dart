import 'package:adguard_home_manager/models/clients_allowed_blocked.dart';
import 'package:adguard_home_manager/models/safe_search.dart';

class Clients {
  List<Client> clients;
  final List<AutoClient> autoClients;
  final List<String> supportedTags;
  ClientsAllowedBlocked? clientsAllowedBlocked;

  Clients({
    required this.clients,
    required this.autoClients,
    required this.supportedTags,
    this.clientsAllowedBlocked
  });

  factory Clients.fromJson(Map<String, dynamic> json) => Clients(
    clients: json["clients"] != null ? List<Client>.from(json["clients"].map((x) => Client.fromJson(x))) : [],
    autoClients: json["auto_clients"] != null ? List<AutoClient>.from(json["auto_clients"].map((x) => AutoClient.fromJson(x))) : [],
    supportedTags: json["supported_tags"] != null ? List<String>.from(json["supported_tags"].map((x) => x)) : [],
  );

  Map<String, dynamic> toJson() => {
    "clients": List<dynamic>.from(clients.map((x) => x.toJson())),
    "auto_clients": List<dynamic>.from(autoClients.map((x) => x.toJson())),
    "supported_tags": List<dynamic>.from(supportedTags.map((x) => x)),
  };
}

class AutoClient {
  final WhoisInfo whoisInfo;
  final String? name;
  final String source;
  final String ip;

  AutoClient({
    required this.whoisInfo,
    this.name,
    required this.source,
    required this.ip,
  });

  factory AutoClient.fromJson(Map<String, dynamic> json) => AutoClient(
    whoisInfo: WhoisInfo.fromJson(json["whois_info"]),
    name: json["name"],
    source: json["source"],
    ip: json["ip"],
  );

  Map<String, dynamic> toJson() => {
    "whois_info": whoisInfo.toJson(),
    "name": name,
    "source": source,
    "ip": ip,
  };
}

class WhoisInfo {
  final String? country;
  final String? orgname;

  WhoisInfo({
    this.country,
    this.orgname,
  });

  factory WhoisInfo.fromJson(Map<String, dynamic> json) => WhoisInfo(
    country: json["country"],
    orgname: json["orgname"],
  );

  Map<String, dynamic> toJson() => {
    "country": country,
    "orgname": orgname,
  };
}

class Client {
  final String identity;
  final String name;
  final List<String> blockedServices;
  final List<String> ids;
  final List<String> tags;
  final List<dynamic> upstreams;
  final bool filteringEnabled;
  final bool parentalEnabled;
  final bool safebrowsingEnabled;
  final bool useGlobalBlockedServices;
  final bool useGlobalSettings;
  final SafeSearch? safeSearch;
  final bool? ignoreQuerylog;
  final bool? ignoreStatistics;
  final bool? upstreamsCacheEnabled;
  final int? upstreamsCacheSize;
  final BlockedServicesSchedule? blockedServicesSchedule;

  Client({
    required this.identity,
    required this.name,
    required this.blockedServices,
    required this.ids,
    required this.tags,
    required this.upstreams,
    required this.filteringEnabled,
    required this.parentalEnabled,
    required this.safebrowsingEnabled,
    required this.useGlobalBlockedServices,
    required this.useGlobalSettings,
    required this.safeSearch,
    required this.ignoreQuerylog,
    required this.ignoreStatistics,
    required this.upstreamsCacheEnabled,
    required this.upstreamsCacheSize,
    required this.blockedServicesSchedule,
  });

  factory Client.fromJson(Map<String, dynamic> json) => Client(
    identity: json["name"],
    name: json["name"],
    blockedServices: json["blocked_services"] != null ? List<String>.from(json["blocked_services"]) : [],
    ids: json["ids"] != null ? List<String>.from(json["ids"].map((x) => x)) : [],
    tags: json["tags"] != null ? List<String>.from(json["tags"].map((x) => x)) : [],
    upstreams: json["upstreams"] != null ? List<dynamic>.from(json["upstreams"].map((x) => x)) : [],
    filteringEnabled: json["filtering_enabled"],
    parentalEnabled: json["parental_enabled"],
    safebrowsingEnabled: json["safebrowsing_enabled"],
    useGlobalBlockedServices: json["use_global_blocked_services"],
    useGlobalSettings: json["use_global_settings"],
    safeSearch: json["safe_search"] != null
      ? SafeSearch.fromJson(json["safe_search"]) 
      : null,
    ignoreQuerylog: json["ignore_querylog"],
    ignoreStatistics: json["ignore_statistics"],
    upstreamsCacheEnabled: json["upstreams_cache_enabled"],
    upstreamsCacheSize: json["upstreams_cache_size"],
    blockedServicesSchedule: json["blocked_services_schedule"] != null
      ? BlockedServicesSchedule.fromJson(json["blocked_services_schedule"])
      : null
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "blocked_services": blockedServices,
    "ids": List<dynamic>.from(ids.map((x) => x)),
    "tags": List<dynamic>.from(tags.map((x) => x)),
    "upstreams": List<dynamic>.from(upstreams.map((x) => x)),
    "filtering_enabled": filteringEnabled,
    "parental_enabled": parentalEnabled,
    "safebrowsing_enabled": safebrowsingEnabled,
    "safe_search": safeSearch,
    "use_global_blocked_services": useGlobalBlockedServices,
    "use_global_settings": useGlobalSettings,
    "ignore_querylog": ignoreQuerylog,
    "ignore_statistics": ignoreStatistics,
    "upstreams_cache_enabled": upstreamsCacheEnabled,
    "upstreams_cache_size": upstreamsCacheSize,
    "blocked_services_schedule":blockedServicesSchedule?.toJson()
  };
}

class BlockedServicesSchedule {
  final String? timeZone;
  final BlockedServicesScheduleDay? mon;
  final BlockedServicesScheduleDay? tue;
  final BlockedServicesScheduleDay? wed;
  final BlockedServicesScheduleDay? thu;
  final BlockedServicesScheduleDay? fri;
  final BlockedServicesScheduleDay? sat;
  final BlockedServicesScheduleDay? sun;

  BlockedServicesSchedule({
    this.timeZone,
    this.mon,
    this.tue,
    this.wed,
    this.thu,
    this.fri,
    this.sat,
    this.sun
  });

  factory BlockedServicesSchedule.fromJson(Map<String, dynamic> json) => BlockedServicesSchedule(
    timeZone: json["time_zone"],
    mon: json["mon"] == null ? null : BlockedServicesScheduleDay.fromJson(json["mon"]),
    tue: json["tue"] == null ? null : BlockedServicesScheduleDay.fromJson(json["tue"]),
    wed: json["wed"] == null ? null : BlockedServicesScheduleDay.fromJson(json["wed"]),
    thu: json["thu"] == null ? null : BlockedServicesScheduleDay.fromJson(json["thu"]),
    fri: json["fri"] == null ? null : BlockedServicesScheduleDay.fromJson(json["fri"]),
    sat: json["sat"] == null ? null : BlockedServicesScheduleDay.fromJson(json["sat"]),
    sun: json["sun"] == null ? null : BlockedServicesScheduleDay.fromJson(json["sun"]),
  );

  Map<String, dynamic> toJson() => {
    "time_zone": timeZone,
    "mon": mon?.toJson(),
    "tue": tue?.toJson(),
    "wed": wed?.toJson(),
    "thu": thu?.toJson(),
    "fri": fri?.toJson(),
    "sat": sat?.toJson(),
    "sun": sun?.toJson(),
  };
}

class BlockedServicesScheduleDay {
  final int? start;
  final int? end;

  BlockedServicesScheduleDay({
    this.start,
    this.end,
  });

  factory BlockedServicesScheduleDay.fromJson(Map<String, dynamic> json) => BlockedServicesScheduleDay(
    start: json["start"],
    end: json["end"],
  );

  Map<String, dynamic> toJson() => {
    "start": start,
    "end": end,
  };
}