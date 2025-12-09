/// Utility functions for generating random avatars
class AvatarUtil {
  /// Generates a random avatar URL using DiceBear API
  /// 
  /// Uses a seed to ensure consistent avatar generation for the same user.
  /// The seed can be a user ID, name, email, or any unique identifier.
  /// 
  /// [seed] - A unique identifier (e.g., user ID, name, email) to generate a consistent avatar
  /// Returns a URL string pointing to a DiceBear avatar image
  static String getRandomAvatarUrl(String seed) {
    // Use DiceBear API with avataaars style and seed for consistency
    // The seed ensures the same user always gets the same avatar
    final encodedSeed = Uri.encodeComponent(seed);
    return 'https://api.dicebear.com/7.x/avataaars/svg?seed=$encodedSeed';
  }
}

