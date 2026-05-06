enum AssetMode { managed, linked }

enum MissingState { available, missing, relinkRequired }

class AssetRef {
  const AssetRef({
    required this.mode,
    required this.uri,
    required this.fingerprint,
    required this.missingState,
    this.width,
    this.height,
    this.bytes,
  });

  final AssetMode mode;
  final String uri;
  final String fingerprint;
  final MissingState missingState;
  final int? width;
  final int? height;
  final int? bytes;

  bool get isAvailable => missingState == MissingState.available;

  AssetRef copyWith({
    AssetMode? mode,
    String? uri,
    String? fingerprint,
    MissingState? missingState,
    int? width,
    int? height,
    int? bytes,
  }) {
    return AssetRef(
      mode: mode ?? this.mode,
      uri: uri ?? this.uri,
      fingerprint: fingerprint ?? this.fingerprint,
      missingState: missingState ?? this.missingState,
      width: width ?? this.width,
      height: height ?? this.height,
      bytes: bytes ?? this.bytes,
    );
  }
}
