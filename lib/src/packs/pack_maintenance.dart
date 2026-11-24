// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 5-C. What the Model packs screen needs beyond list, import and delete: checking installed
// packs, free storage, and (play flavour only) packs the store delivers. Dart stays flavour-agnostic: the
// screen asks [PackMaintenance] and shows what it gets back.
//
// The real implementation needs Pigeon methods that do not exist yet (see docs/packs/README.md, "Bridge
// additions"). Until the orchestrator adds them, [UnavailablePackMaintenance] is wired in, and the screen
// says those features are not in this build. Nothing here touches the network.

/// The website where packs are published. One constant, so the release docs can fill it in.
/// PLACEHOLDER until the project's public URL exists (Wave 5-B docs). The app cannot open links itself
/// (no INTERNET permission); it shows this text and lets the user copy it.
const String kPackReleasePageUrl = 'https://example.invalid/incogboard/releases';

/// How packs reach this build: files the user imports, or packs the store delivers too (play flavour).
enum PackDelivery { importOnly, storeDelivery }

/// Where a store-delivered pack is in its download. Play reports these; the keyboard only shows them.
enum PackOfferStatus { notRequested, waitingForNetwork, downloading, installing, failed, ready }

/// A pack the store can deliver to this phone (only in builds with [PackDelivery.storeDelivery]).
class PackOffer {
  const PackOffer({required this.id, required this.name, required this.sizeBytes, required this.status});

  final String id;
  final String name;
  final int sizeBytes;
  final PackOfferStatus status;
}

/// Free space on the storage that holds packs.
class PackStorage {
  const PackStorage({required this.freeBytes});

  final int freeBytes;
}

/// Result of re-checking one installed pack against its signed manifest. Counts only, never paths.
class PackCheck {
  const PackCheck({required this.id, required this.manifestOk, required this.missingFiles, required this.damagedFiles});

  final String id;
  final bool manifestOk;
  final int missingFiles;
  final int damagedFiles;

  bool get ok => manifestOk && missingFiles == 0 && damagedFiles == 0;
}

/// Thrown when this build cannot do a maintenance action (the bridge call is not wired yet).
class PackMaintenanceUnavailable implements Exception {
  const PackMaintenanceUnavailable();

  @override
  String toString() => 'PackMaintenanceUnavailable';
}

abstract interface class PackMaintenance {
  /// Import-only builds (foss) return [PackDelivery.importOnly]; the play flavour may return
  /// [PackDelivery.storeDelivery].
  PackDelivery get delivery;

  /// Packs the store can deliver, with their state. Empty when [delivery] is importOnly.
  Future<List<PackOffer>> offers();

  /// Asks the store to deliver pack [id]. Only valid with [PackDelivery.storeDelivery].
  Future<void> request(String id);

  /// Free storage for packs, or null when this build cannot tell.
  Future<PackStorage?> storage();

  /// Re-checks every installed pack. Throws [PackMaintenanceUnavailable] when this build cannot.
  Future<List<PackCheck>> verifyInstalled();
}

/// The default until the bridge supports maintenance: import-only, nothing to check, storage unknown.
class UnavailablePackMaintenance implements PackMaintenance {
  const UnavailablePackMaintenance();

  @override
  PackDelivery get delivery => PackDelivery.importOnly;

  @override
  Future<List<PackOffer>> offers() async => const [];

  @override
  Future<void> request(String id) async => throw const PackMaintenanceUnavailable();

  @override
  Future<PackStorage?> storage() async => null;

  @override
  Future<List<PackCheck>> verifyInstalled() async => throw const PackMaintenanceUnavailable();
}
