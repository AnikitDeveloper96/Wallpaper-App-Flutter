import 'package:http/http.dart' as http;
import 'package:wallpaperapp/models/wallpaper_response_model_videos.dart';
import '../models/wallpaper_response_model.dart';


class ApiService {
  static const _apiKey =
      '563492ad6f91700001000001147ed2f27e284cdbb6b598d56b99068f';

  static Future<List<Photo>> fetchWallpapers() async {
    final url = Uri.parse('https://api.pexels.com/v1/curated?per_page=100');
    final response = await http.get(url, headers: {'Authorization': _apiKey});

    if (response.statusCode == 200) {
      final wallpaperResponse = wallpaperAppResponseModelFromJson(
        response.body,
      );
      return wallpaperResponse.photos;
    } else {
      throw Exception('Failed to load wallpapers: ${response.statusCode}');
    }
  }

  static Future<List<Video>> fetchPopularVideos({
    int page = 1,
    int perPage = 150,
  }) async {
    final uri = Uri.parse('https://api.pexels.com/videos/popular?per_page=100');

    try {
      final response = await http.get(uri, headers: {'Authorization': _apiKey});

      if (response.statusCode == 200) {
        final wallpaperVideoResponse = wallpaperAppVideosResponseModelFromJson(
          response.body,
        );
        return wallpaperVideoResponse.videos;
      } else {
        throw Exception(
          'Failed to load videos: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch videos: $e');
    }
  }

  static Future<WallpaperAppResponseModel> searchWallpaper(
    String query, {
    int page = 1,
    int perPage = 150,
  }) async {
    final uri = Uri.parse(
      'https://api.pexels.com/v1/search?query=$query&per_page=$perPage',
    );

    try {
      final response = await http.get(uri, headers: {'Authorization': _apiKey});

      if (response.statusCode == 200) {
        return wallpaperAppResponseModelFromJson(response.body);
      } else {
        throw Exception(
          'Failed to search videos: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Failed to search videos: $e');
    }
  }


  static Future<WallpaperAppVideosResponseModel> searchVideos(
    String query, {
    int page = 1,
    int perPage = 15,
  }) async {
    final uri = Uri.parse(
      'https://api.pexels.com/videos/search?query=$query&page=$page&per_page=$perPage',
    );

    try {
      final response = await http.get(uri, headers: {'Authorization': _apiKey});

      if (response.statusCode == 200) {
        return wallpaperAppVideosResponseModelFromJson(response.body);
      } else {
        throw Exception(
          'Failed to search videos: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Failed to search videos: $e');
    }
  }
}
