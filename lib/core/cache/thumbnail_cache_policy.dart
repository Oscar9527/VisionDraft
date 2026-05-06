class ThumbnailCachePolicy {
  const ThumbnailCachePolicy({
    this.memoryMaxEntries = 200,
    this.memoryMaxBytes = 64 * 1024 * 1024,
    this.targetLongSide = 640,
  });

  final int memoryMaxEntries;
  final int memoryMaxBytes;
  final int targetLongSide;
}
