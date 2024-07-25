import 'dart:io';

import 'package:adguard_home_manager/providers/clients_wrapper_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:store_checker/store_checker.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:adguard_home_manager/widgets/layout.dart';
import 'package:adguard_home_manager/widgets/menu_bar.dart';

import 'package:adguard_home_manager/providers/logs_provider.dart';
import 'package:adguard_home_manager/providers/app_config_provider.dart';
import 'package:adguard_home_manager/providers/clients_provider.dart';
import 'package:adguard_home_manager/providers/dns_provider.dart';
import 'package:adguard_home_manager/providers/filtering_provider.dart';
import 'package:adguard_home_manager/providers/rewrite_rules_provider.dart';
import 'package:adguard_home_manager/providers/dhcp_provider.dart';
import 'package:adguard_home_manager/providers/status_provider.dart';
import 'package:adguard_home_manager/providers/servers_provider.dart';
import 'package:adguard_home_manager/constants/colors.dart';
import 'package:adguard_home_manager/config/globals.dart';
import 'package:adguard_home_manager/config/theme.dart';
import 'package:adguard_home_manager/services/db/database.dart';
import 'package:adguard_home_manager/classes/http_override.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    WindowManager.instance.setMinimumSize(const Size(500, 700));
  }

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await dotenv.load(fileName: '.env');

  final sharedPreferences = await SharedPreferences.getInstance();
  
  final AppConfigProvider appConfigProvider = AppConfigProvider(
    sharedPreferencesInstance: sharedPreferences
  );
  final ServersProvider serversProvider = ServersProvider();
  final StatusProvider statusProvider = StatusProvider();
  final ClientsProvider clientsProvider = ClientsProvider();
  final LogsProvider logsProvider = LogsProvider();
  final ClientsWrapperProvider clientsWrapperProvider = ClientsWrapperProvider(logsProvider);
  final FilteringProvider filtersProvider = FilteringProvider();
  final DhcpProvider dhcpProvider = DhcpProvider();
  final RewriteRulesProvider rewriteRulesProvider = RewriteRulesProvider();
  final DnsProvider dnsProvider = DnsProvider();

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    appConfigProvider.setAndroidInfo(androidInfo);
  }
  if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    appConfigProvider.setIosInfo(iosInfo);
  }

  if (sharedPreferences.getBool('overrideSslCheck') == true) {
    HttpOverrides.global = MyHttpOverrides();
  }

  if (Platform.isAndroid || Platform.isIOS) {
    Source installationSource = await StoreChecker.getSource;
    appConfigProvider.setInstallationSource(installationSource);
  }

  final dbData = await loadDb();
  serversProvider.setDbInstance(dbData['dbInstance']);
  serversProvider.saveFromDb(dbData['servers']);

  appConfigProvider.saveFromSharedPreferences();

  PackageInfo appInfo = await PackageInfo.fromPlatform();
  appConfigProvider.setAppInfo(appInfo);

  void startApp() => runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: ((context) => serversProvider)
        ),
        ChangeNotifierProvider(
          create: ((context) => appConfigProvider)
        ),
        ChangeNotifierProvider(
          create: ((context) => statusProvider)
        ),
        ChangeNotifierProvider(
          create: ((context) => clientsProvider)
        ),
        ChangeNotifierProvider(
            create: ((context) => clientsWrapperProvider)
        ),
        ChangeNotifierProvider(
          create: ((context) => logsProvider)
        ),
        ChangeNotifierProvider(
          create: ((context) => filtersProvider)
        ),
        ChangeNotifierProvider(
          create: ((context) => dhcpProvider)
        ),
        ChangeNotifierProvider(
          create: ((context) => rewriteRulesProvider)
        ),
        ChangeNotifierProvider(
          create: ((context) => dnsProvider)
        ),
        ChangeNotifierProxyProvider2<ServersProvider, StatusProvider, ClientsProvider>(
          create: (context) => clientsProvider, 
          update: (context, servers, status, clients) => clients!..update(servers, status),
        ),
        ChangeNotifierProxyProvider2<ServersProvider, StatusProvider, FilteringProvider>(
          create: (context) => filtersProvider, 
          update: (context, servers, status, filtering) => filtering!..update(servers, status),
        ),
        ChangeNotifierProxyProvider<ServersProvider, StatusProvider>(
          create: (context) => statusProvider, 
          update: (context, servers, status) => status!..update(servers),
        ),
        ChangeNotifierProxyProvider<ServersProvider, LogsProvider>(
          create: (context) => logsProvider, 
          update: (context, servers, logs) => logs!..update(servers),
        ),
        ChangeNotifierProxyProvider<ServersProvider, DhcpProvider>(
          create: (context) => dhcpProvider, 
          update: (context, servers, dhcp) => dhcp!..update(servers),
        ),
        ChangeNotifierProxyProvider<ServersProvider, RewriteRulesProvider>(
          create: (context) => rewriteRulesProvider, 
          update: (context, servers, rewrite) => rewrite!..update(servers),
        ),
        ChangeNotifierProxyProvider<ServersProvider, DnsProvider>(
          create: (context) => dnsProvider, 
          update: (context, servers, dns) => dns!..update(servers),
        ),
      ],
      child: const Main(),
    )
  );

  if (
    (
      kReleaseMode &&
      (dotenv.env['SENTRY_DSN'] != null && dotenv.env['SENTRY_DSN'] != "")
    ) || (
      dotenv.env['ENABLE_SENTRY'] == "true" &&
      (dotenv.env['SENTRY_DSN'] != null && dotenv.env['SENTRY_DSN'] != "")
    )
  ) {
    SentryFlutter.init(
      (options) {
        options.dsn = dotenv.env['SENTRY_DSN'];
        options.sendDefaultPii = false;
      },
      appRunner: () => startApp()
    );
  }
  else {
    startApp();
  }
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  List<DisplayMode> modes = <DisplayMode>[];
  DisplayMode? active;
  DisplayMode? preferred;

  Future<void> displayMode() async {
    try {
      modes = await FlutterDisplayMode.supported;
      preferred = await FlutterDisplayMode.preferred;
      active = await FlutterDisplayMode.active;
      await FlutterDisplayMode.setHighRefreshRate();
      setState(() {});
    } catch (_) {
      // ---- //
    }
  }

  @override
  void initState() {
    displayMode();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        appConfigProvider.setSupportsDynamicTheme(lightDynamic != null && darkDynamic != null);
        return MaterialApp(
          title: 'AdGuard Home Manager',
          theme: lightDynamic != null
            ? appConfigProvider.useDynamicColor == true
              ? lightTheme(lightDynamic)
              : lightThemeOldVersions(colors[appConfigProvider.staticColor])
            : lightThemeOldVersions(colors[appConfigProvider.staticColor]),
          darkTheme: darkDynamic != null
            ? appConfigProvider.useDynamicColor == true
              ? darkTheme(darkDynamic)
              : darkThemeOldVersions(colors[appConfigProvider.staticColor])
            : darkThemeOldVersions(colors[appConfigProvider.staticColor]),
          themeMode: appConfigProvider.selectedTheme,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            AppLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('es', ''),
            Locale('zh', ''),
            Locale('zh', 'CN'),
            Locale('pl', ''),
            Locale('tr', ''),
            Locale('ru', '')
          ],
          scaffoldMessengerKey: scaffoldMessengerKey,
          navigatorKey: globalNavigatorKey,
          builder: (context, child) => CustomMenuBar(
            child: child!,
          ),
          home: const Layout(),
        );
      }
    );
  }
}