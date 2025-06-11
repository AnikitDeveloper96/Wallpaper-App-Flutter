import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wallpaperapp/api/api.dart'; // Ensure this path is correct
import 'package:wallpaperapp/models/wallpaper_response_model_videos.dart'; // Ensure this path is correct
import '../models/wallpaper_response_model.dart'; // Ensure this path is correct

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Photo>> _photoFuture;
  late Future<List<Video>> _videoFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _photoFuture = ApiService.fetchWallpapers();
    _videoFuture = ApiService.fetchPopularVideos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- App Bar Enhancements ---
      appBar: AppBar(
        title: const Text(
          "Wallify",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28, // Larger title
          ),
        ),
        centerTitle: true, // Center the title
        backgroundColor: Colors.deepPurple, // Solid color for a sleek look
        elevation: 4.0, // Add a subtle shadow
        // FlexibleSpace for a gradient if desired, replaces backgroundColor
        // flexibleSpace: Container(
        //   decoration: const BoxDecoration(
        //     gradient: LinearGradient(
        //       colors: [Colors.deepPurple, Colors.purpleAccent],
        //       begin: Alignment.topLeft,
        //       end: Alignment.bottomRight,
        //     ),
        //   ),
        // ),
        bottom: TabBar(
          controller: _tabController,
          // --- TabBar Enhancements ---
          indicatorColor: Colors.white, // White underline for selected tab
          indicatorWeight: 4.0, // Thicker indicator
          labelColor: Colors.white, // Color for selected tab's text
          unselectedLabelColor: Colors.white70, // Slightly faded for unselected
          labelStyle: const TextStyle(
            fontSize: 18, // Larger tab labels
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          tabs: const [Tab(text: "Photos"), Tab(text: "Videos")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          /// PHOTOS TAB CONTENT
          FutureBuilder<List<Photo>>(
            future: _photoFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.deepPurple),
                ); // Styled loader
              }
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 50,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Oops! Failed to load photos.\n${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        // Retry button
                        onPressed: () {
                          setState(() {
                            _photoFuture = ApiService.fetchWallpapers();
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text("Retry"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final wallpapers = snapshot.data ?? [];
              if (wallpapers.isEmpty) {
                return const Center(
                  child: Text(
                    "No photos found. Try again later!",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: wallpapers.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  final photo = wallpapers[index];
                  return WallpaperTile(imageUrl: photo.src.portrait);
                },
              );
            },
          ),

          /// VIDEOS TAB CONTENT
          FutureBuilder<List<Video>>(
            future: _videoFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.purpleAccent),
                ); // Styled loader
              }
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.videocam_off,
                        color: Colors.red,
                        size: 50,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Failed to load videos.\n${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        // Retry button
                        onPressed: () {
                          setState(() {
                            _videoFuture = ApiService.fetchPopularVideos();
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text("Retry"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purpleAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final videos = snapshot.data ?? [];
              if (videos.isEmpty) {
                return const Center(
                  child: Text(
                    "No videos found. Try again later!",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: videos.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  final video = videos[index];
                  return VideoTile(
                    thumbnailUrl: video.image,
                    videoUrl:
                        video.videoFiles.isNotEmpty
                            ? video.videoFiles.first.link
                            : '',
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// WallpaperTile and VideoTile (can be in the same file or separate widgets folder)

class WallpaperTile extends StatelessWidget {
  final String imageUrl;
  const WallpaperTile({required this.imageUrl, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      // Use Card for a subtle elevated effect
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // More rounded corners
      ),
      clipBehavior: Clip.antiAlias, // Ensures content respects border radius
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder:
            (context, url) => Container(
              color: Colors.grey[200], // Placeholder background
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.deepPurple,
                ), // Styled loader
              ),
            ),
        errorWidget:
            (context, url, error) => Container(
              color: Colors.grey[300],
              child: const Center(
                child: Icon(
                  Icons.broken_image,
                  color: Colors.red,
                  size: 40,
                ), // More descriptive error icon
              ),
            ),
      ),
    );
  }
}

class VideoTile extends StatelessWidget {
  final String thumbnailUrl;
  final String videoUrl;
  const VideoTile({
    required this.thumbnailUrl,
    required this.videoUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // Use Card for a subtle elevated effect
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // More rounded corners
      ),
      clipBehavior: Clip.antiAlias, // Ensures content respects border radius
      child: GestureDetector(
        onTap: () {
          print('Tapped on video: $videoUrl');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Playing video from: $videoUrl'),
              duration: const Duration(seconds: 2),
            ),
          );
          // TODO: Implement video playback (e.g., using video_player package)
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: thumbnailUrl,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Container(
                    color: Colors.grey[200], // Placeholder background
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.purpleAccent,
                      ), // Styled loader
                    ),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.videocam_off,
                        color: Colors.red,
                        size: 40,
                      ), // More descriptive error icon
                    ),
                  ),
            ),
            // Play icon with a slight shadow for better visibility
            Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(
                    0.4,
                  ), // Semi-transparent background
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow, // Changed to a simpler play icon
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            // Optional: Video duration overlay
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  'Video', // You could display actual duration if available in model
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
