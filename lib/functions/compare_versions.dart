import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:adguard_home_manager/models/github_release.dart';

bool compareVersions({
  required String currentVersion, 
  required String newVersion
}) {
  if (currentVersion == "") return false;
  try {
    if (currentVersion.contains('a')) {   // alpha
      return true;
    }
    else if (currentVersion.contains('b')) {    // beta
      final current = currentVersion.replaceAll('v', '');
      final newV = currentVersion.replaceAll('v', '');

      final currentSplit = current.split('-')[0].split('.').map((e) => int.parse(e)).toList();
      final newSplit = newV.split('-')[0].split('.').map((e) => int.parse(e)).toList();

      final currentBeta = int.parse(current.split('-')[1].replaceAll('b.', ''));
      final newBeta = int.parse(newV.split('-')[1].replaceAll('b.', ''));
      
      if (newSplit[0] > currentSplit[0]) {
        return true;
      }
      else if (newSplit[1] > currentSplit[1]) {
        return true;
      }
      else if (newSplit[2] > currentSplit[2]) {
        return true;
      }
      else if (newBeta > currentBeta) {
        return true;
      }
      else {
        return false;
      }
    }
    else {    // stable
      final current = currentVersion.replaceAll('v', '');
      final newV = currentVersion.replaceAll('v', '');
      
      final currentSplit = current.split('.').map((e) => int.parse(e)).toList();
      final newSplit = newV.split('.').map((e) => int.parse(e)).toList();

      if (newSplit[0] > currentSplit[0]) {
        return true;
      }
      else if (newSplit[1] > currentSplit[1]) {
        return true;
      }
      else if (newSplit[2] > currentSplit[2]) {
        return true;
      }   
      else {
        return false;
      }
    }
  } catch (e) {
    Sentry.captureException(e);
    Sentry.captureMessage("compareVersions error", params: [
      {
        "fn": "compareVersions",
        "currentVersion": currentVersion,
        "newVersion": newVersion,
      }.toString()
    ]);
    return false;
  }
}

bool serverVersionIsAhead({
  required String currentVersion, 
  required String referenceVersion, 
  String? referenceVersionBeta
}) {
  if (currentVersion == "") return false;
  try {
    final current = currentVersion.replaceAll('v', '');
    final reference = referenceVersion.replaceAll('v', '');
    final referenceBeta = referenceVersionBeta?.replaceAll('v', '');

    if (currentVersion.contains('a')) {   // alpha
      return true;
    }
    else if (current.contains('b')) {   // beta
      if (referenceBeta != null) {
        final currentSplit = current.split('-')[0].split('.').map((e) => int.parse(e)).toList();
        final newSplit = referenceBeta.split('-')[0].split('.').map((e) => int.parse(e)).toList();

        final currentBeta = int.parse(current.split('-')[1].replaceAll('b.', ''));
        final newBeta = int.parse(referenceBeta.split('-')[1].replaceAll('b.', ''));
        
        if (newSplit[0] == currentSplit[0] && newSplit[1] == currentSplit[1] && newSplit[2] == currentSplit[2] && newBeta == currentBeta) {
          return true;
        }
        else if (newSplit[0] < currentSplit[0]) {
          return true;
        }
        else if (newSplit[1] < currentSplit[1]) {
          return true;
        }
        else if (newSplit[2] < currentSplit[2]) {
          return true;
        }
        else if (newBeta < currentBeta) {
          return true;
        }
        else {
          return false;
        }
      }
      else {
        return false;
      }
    }
    else {    // stable
      final currentSplit = current.split('.').map((e) => int.parse(e)).toList();
      final newSplit = reference.split('.').map((e) => int.parse(e)).toList();

      if (newSplit[0] == currentSplit[0] && newSplit[1] == currentSplit[1] && newSplit[2] == currentSplit[2]) {
        return true;
      }
      else if (newSplit[0] < currentSplit[0]) {
        return true;
      }
      else if (newSplit[1] < currentSplit[1]) {
        return true;
      }
      else if (newSplit[2] < currentSplit[2]) {
        return true;
      }   
      else {
        return false;
      }
    }
  } catch (e) {
    Sentry.captureException(e);
    Sentry.captureMessage("serverVersionIsAhead error", params: [
      {
        "fn": "serverVersionIsAhead",
        "currentVersion": currentVersion,
        "referenceVersion": referenceVersion,
        "referenceVersionBeta": referenceVersionBeta ?? ""
      }.toString()
    ]);
    return false;
  }
}

bool gitHubUpdateExists(String appVersion, List<GitHubRelease> gitHubReleases) {
  if (appVersion.contains('beta')) {
    final gitHubVersion = gitHubReleases.firstWhere((release) => release.prerelease == true).tagName;

    final appBetaSplit = appVersion.split('-');
    final gitHubBetaSplit = gitHubVersion.split('-');

    final List<int> appVersionSplit = List<int>.from(appBetaSplit[0].split('.').map((e) => int.parse(e)));
    final int appBetaNumber = int.parse(appBetaSplit[1].split('.')[1]);

    final List<int> gitHubVersionSplit = List<int>.from(gitHubBetaSplit[0].split('.').map((e) => int.parse(e)));
    final int gitHubBetaNumber = int.parse(gitHubBetaSplit[1].split('.')[1]);

    if (gitHubVersionSplit[0] > appVersionSplit[0]) {
      return true;
    }
    else if (gitHubVersionSplit[0] == appVersionSplit[0] && gitHubVersionSplit[1] > appVersionSplit[1]) {
      return true;
    }
    else if (gitHubVersionSplit[0] == appVersionSplit[0] && gitHubVersionSplit[1] == appVersionSplit[1] && gitHubVersionSplit[2] > appVersionSplit[2]) {
      return true;
    }
    else if (gitHubVersionSplit[0] == appVersionSplit[0] && gitHubVersionSplit[1] == appVersionSplit[1] && gitHubVersionSplit[2] == appVersionSplit[2] && gitHubBetaNumber > appBetaNumber) {
      return true;
    }
    else {
      return false;
    }
  }
  else {
    final gitHubVersion = gitHubReleases.firstWhere((release) => release.prerelease == false).tagName;

    final List<int> appVersionSplit = List<int>.from(appVersion.split('.').map((e) => int.parse(e)));
    final List<int> gitHubVersionSplit = List<int>.from(gitHubVersion.split('.').map((e) => int.parse(e)));

    if (gitHubVersionSplit[0] > appVersionSplit[0]) {
      return true;
    }
    else if (gitHubVersionSplit[0] == appVersionSplit[0] && gitHubVersionSplit[1] > appVersionSplit[1]) {
      return true;
    }
    else if (gitHubVersionSplit[0] == appVersionSplit[0] && gitHubVersionSplit[1] == appVersionSplit[1] && gitHubVersionSplit[2] > appVersionSplit[2]) {
      return true;
    }
    else {
      return false;
    }
  }
}