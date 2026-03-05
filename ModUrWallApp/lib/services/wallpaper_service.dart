import '../models/wallpaper.dart';

/// Abstract contract — screens depend on this, never on a concrete implementation.
/// Swap MockWallpaperService for LempyraWallpaperService when the http package
/// is added and api.lempyra.com/modurwall/generate is ready.
abstract class WallpaperService {
  Future<List<WallpaperModel>> getWallpapers();
  Future<List<WallpaperModel>> getWallpapersByTier(WallpaperTier tier);

  /// Submits a generation job. Returns a jobId for polling.
  Future<String> submitGeneration(String prompt);

  /// Polls generation status. Returns the completed WallpaperModel or null
  /// if still in progress.
  Future<WallpaperModel?> checkGenerationStatus(String jobId);
}

/// v0 mock — returns hardcoded data with simulated network delays.
/// Replace with LempyraWallpaperService in v1.
class MockWallpaperService implements WallpaperService {
  @override
  Future<List<WallpaperModel>> getWallpapers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return kMockWallpapers;
  }

  @override
  Future<List<WallpaperModel>> getWallpapersByTier(WallpaperTier tier) async {
    final all = await getWallpapers();
    return all.where((w) => w.tier == tier).toList();
  }

  @override
  Future<String> submitGeneration(String prompt) async {
    await Future.delayed(const Duration(seconds: 1));
    return 'mock_job_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<WallpaperModel?> checkGenerationStatus(String jobId) async {
    await Future.delayed(const Duration(seconds: 2));
    return kMockWallpapers.first;
  }
}
