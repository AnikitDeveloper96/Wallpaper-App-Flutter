import 'package:flutter/material.dart';
import 'package:wallpaperapp/api/api.dart'; // Assuming ApiService is defined here
import 'package:wallpaperapp/models/wallpaper_response_model.dart'; // Assuming Photo model is defined here
import 'package:wallpaperapp/models/wallpaper_response_model_videos.dart'; // Assuming Video and VideoFile models are defined here
import 'package:video_player/video_player.dart';
import 'dart:io'; // For File and Directory
import 'package:path_provider/path_provider.dart'; // For getExternalStorageDirectory
import 'package:http/http.dart' as http; // For making HTTP requests
import 'package:url_launcher/url_launcher.dart'; // For launching URLs
import 'package:share_plus/share_plus.dart'; // For sharing content

/// The main screen of the application, displaying tabs for photos and videos.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // State variables for managing fetched data and UI
  List<Photo> wallpapers = []; // Stores fetched photo data
  List<Video> videos = []; // Stores fetched video data
  bool isLoading = true; // Indicates if data is currently being loaded

  // TabController to manage the Photo and Video tabs
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize TabController with 2 tabs and link it to this State
    _tabController = TabController(length: 2, vsync: this);
    // Add a listener to react to tab changes
    _tabController.addListener(_onTabChanged);

    // Initial data fetch based on the starting tab (Photos by default)
    _fetchWallpapers();
  }

  // --- Data Fetching Methods ---

  /// Fetches popular wallpapers (photos) from the API.
  Future<void> _fetchWallpapers() async {
    // Ensure the widget is still mounted before updating state
    if (!mounted) return;
    setState(() => isLoading = true); // Set loading state to true
    try {
      // Call the API service to fetch wallpapers
      final wallpaperData = await ApiService.fetchWallpapers();
      if (!mounted) return; // Re-check mounted after async operation
      setState(() {
        wallpapers = wallpaperData; // Update wallpapers list
        isLoading = false; // Set loading state to false
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false); // Ensure loading is false on error
      debugPrint('Wallpaper fetch error: $e'); // Print error to console
      _showSnackBar(
        'Failed to load photos. Please check your connection.',
      ); // Show user a message
    }
  }

  /// Fetches popular videos from the API.
  Future<void> _fetchVideos() async {
    // Ensure the widget is still mounted before updating state
    if (!mounted) return;
    setState(() => isLoading = true); // Set loading state to true
    try {
      // Call the API service to fetch popular videos
      final videoData = await ApiService.fetchPopularVideos();
      if (!mounted) return; // Re-check mounted after async operation
      setState(() {
        videos = videoData; // Update videos list
        isLoading = false; // Set loading state to false
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false); // Ensure loading is false on error
      debugPrint('Video fetch error: $e'); // Print error to console
      _showSnackBar(
        'Failed to load videos. Please check your connection.',
      ); // Show user a message
    }
  }

  // --- Utility Methods ---

  /// Handles tab changes, automatically refetching content for the new tab.
  void _onTabChanged() {
    // Prevent fetching if tab change is still in progress (e.g., during animation)
    if (_tabController.indexIsChanging) return;
    // Based on the current tab index, fetch either photos or videos
    if (_tabController.index == 0) {
      _fetchWallpapers();
    } else {
      _fetchVideos();
    }
  }

  /// Displays a SnackBar with the given message at the bottom of the screen.
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  /// Shows a dialog prompting the user to rate or share the app before exiting.
  Future<bool> _onWillPop() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text('Enjoying Capture Canvas?'),
            content: const Text(
              'We hope you like the app! Please consider rating us on the Play Store or sharing with your friends.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Stay in app
                },
                child: const Text('Later'),
              ),
              TextButton(
                onPressed: () {
                  _launchStoreUrl(); // Launch Play Store
                  Navigator.of(context).pop(true); // Allow exit
                },
                child: const Text('Rate App'),
              ),
              TextButton(
                onPressed: () {
                  _shareApp(); // Share app link
                  Navigator.of(context).pop(true); // Allow exit
                },
                child: const Text('Share App'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Allow exit directly
                },
                child: const Text('Exit'),
              ),
            ],
          ),
    );
    return shouldPop ?? false; // If dialog is dismissed, don't pop
  }

  /// Launches the app's store URL (Play Store for Android, App Store for iOS).
  Future<void> _launchStoreUrl() async {
    // Replace with your actual app store URLs
    const androidAppId =
        'com.example.wallpaperapp'; // Replace with your Android package name
    const iosAppId = '1234567890'; // Replace with your iOS App ID
    final Uri url;

    if (Platform.isAndroid) {
      url = Uri.parse('market://details?id=$androidAppId');
    } else if (Platform.isIOS) {
      url = Uri.parse('https://apps.apple.com/app/id$iosAppId');
    } else {
      _showSnackBar('App store not available on this platform.');
      return;
    }

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showSnackBar('Could not launch app store.');
    }
  }

  /// Shares the app using the system share sheet.
  Future<void> _shareApp() async {
    // Customize the share message and URL
    const String text = 'Check out this awesome wallpaper app!';
    const String url =
        'https://play.google.com/store/apps/details?id=com.example.wallpaperapp'; // Replace with your app's Play Store link

    await Share.share('$text\n$url');
  }

  // --- Build Methods ---

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Intercepts the back button press
      canPop: false, // Prevents immediate popping
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final bool shouldPop = await _onWillPop();
        if (shouldPop) {
          if (mounted) {
            Navigator.of(context).pop(); // Allows the app to exit
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Canvas', // App title
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  fontSize: 24,
                  color: Colors.white, // White text for better contrast
                ),
              ),
              // Use ShaderMask to apply the gradient to your name
              Container(
                margin: EdgeInsets.all(8.0),
                child: const Text(
                  ' Made By Anikit Grover', // Your name
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color:
                        Colors.white, // Base color, will be masked by gradient
                  ),
                ),
              ),
            ],
          ),
          centerTitle: true, // Center the title in the AppBar
          // Enhanced AppBar background with a gradient
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF6A1B9A), // Deep Purple
                  Color(0xFF880E4F), // Dark Pink
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          backgroundColor:
              Colors
                  .transparent, // Make AppBar background transparent to show flexibleSpace
          elevation: 8, // Add subtle shadow
          shadowColor: Colors.black.withOpacity(0.5), // Darker shadow
          bottom: TabBar(
            // Tabs for Photos and Videos
            controller: _tabController,
            indicatorSize:
                TabBarIndicatorSize.tab, // Indicator stretches across the tab
            indicatorColor: Colors.white, // White indicator for contrast
            labelColor: Colors.white, // White label for selected tab
            unselectedLabelColor: Colors.white.withOpacity(
              0.7,
            ), // Faded white for unselected
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ), // Style for selected tab label
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ), // Style for unselected tab label
            tabs: const [
              Tab(
                text: 'Photos',
                icon: Icon(Icons.photo_library_outlined),
              ), // Photos tab
              Tab(
                text: 'Videos',
                icon: Icon(Icons.videocam_outlined),
              ), // Videos tab
            ],
          ),
        ),
        body: Container(
          // Optional: Add a subtle background to the body
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey.shade100, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              // Display a CircularProgressIndicator when loading, otherwise show the TabBarView
              Expanded(
                child:
                    isLoading
                        ? const Center(
                          child: CircularProgressIndicator(),
                        ) // Loading indicator
                        : TabBarView(
                          controller:
                              _tabController, // Link TabBarView to TabController
                          children: [
                            // Content for the Photos tab
                            _buildGridView(wallpapers, 'photos'),
                            // Content for the Videos tab
                            _buildGridView(videos, 'videos'),
                          ],
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a GridView for displaying either photos or videos.
  /// It dynamically shows a message if the list is empty.
  Widget _buildGridView(List items, String contentType) {
    // Message to display when no content is available
    String emptyMessage =
        'No $contentType to display. Check your internet connection.';

    // If the list is empty and not loading, show the empty message
    if (items.isEmpty && !isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sentiment_dissatisfied,
              size: 60,
              color: Colors.grey,
            ), // Sad face icon
            const SizedBox(height: 10),
            Text(
              emptyMessage,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    // Otherwise, build the GridView
    return GridView.builder(
      itemCount: items.length, // Number of items in the grid
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 columns
        crossAxisSpacing: 10, // Horizontal spacing between items
        mainAxisSpacing: 10, // Vertical spacing between items
        childAspectRatio: 0.65, // Aspect ratio of each grid item
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ), // Padding around the grid
      itemBuilder: (context, index) {
        // Render either a WallpaperTile or a VideoTile based on item type
        if (items[index] is Photo) {
          return WallpaperTile(photo: items[index] as Photo);
        } else if (items[index] is Video) {
          return VideoTile(video: items[index] as Video);
        }
        return const SizedBox.shrink(); // Fallback for unexpected item types
      },
    );
  }

  @override
  void dispose() {
    // Important: Remove the listener and dispose of the TabController
    // to prevent memory leaks.
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }
}

// ---

/// A widget for displaying a section title (can be used for other screens).
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColorDark,
        ),
      ),
    );
  }
}

// ---

/// A tile widget for displaying a single wallpaper photo.
class WallpaperTile extends StatelessWidget {
  final Photo photo;
  const WallpaperTile({super.key, required this.photo});

  /// Downloads the wallpaper image to the device's external storage.
  Future<void> _downloadImage(BuildContext context) async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Downloading image...')));
    try {
      final response = await http.get(Uri.parse(photo.src.original));
      if (response.statusCode != 200) {
        throw Exception('Failed to download image: ${response.statusCode}');
      }
      final bytes = response.bodyBytes;
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('Could not get external storage directory.');
      }
      // Create a specific folder for wallpapers
      final wallpaperDir = Directory('${directory.path}/Wallpapers');
      if (!await wallpaperDir.exists()) {
        await wallpaperDir.create(recursive: true);
      }
      final file = File(
        '${wallpaperDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image downloaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Download failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hero widget enables smooth transition animations between screens
    return Hero(
      tag: photo.id, // Unique tag for the Hero animation
      child: Card(
        elevation: 5, // Shadow beneath the card
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ), // Rounded corners
        clipBehavior: Clip.antiAlias, // Clip content to card's shape
        child: Stack(
          fit: StackFit.expand, // Make stack children fill the card
          children: [
            // Display the wallpaper image
            Image.network(
              photo.src.portrait, // Use portrait size for list view
              fit: BoxFit.cover, // Cover the entire area of the tile
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null)
                  return child; // If image is loaded, show it
                // Show a CircularProgressIndicator while image is loading
                return Center(
                  child: CircularProgressIndicator(
                    value:
                        loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                // Show a broken image icon if image fails to load
                return const Center(
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                );
              },
            ),
            // Photographer Overlay at the bottom of the image
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                // Gradient for a subtle overlay effect
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    photo.photographer, // Display photographer's name
                    maxLines: 3, // Limit text to 3 lines
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow:
                        TextOverflow
                            .ellipsis, // Show ellipsis if text overflows
                  ),
                ),
              ),
            ),
            // Download Icon positioned at the bottom right
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(
                    0.6,
                  ), // Semi-transparent background
                  shape: BoxShape.circle, // Circular shape
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.download, // Download icon
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed:
                      () => _downloadImage(
                        context,
                      ), // Call download function on press
                  tooltip: 'Download Wallpaper', // Tooltip for accessibility
                  splashRadius: 24, // Splash effect radius
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---

/// A tile widget for displaying a single video.
class VideoTile extends StatefulWidget {
  final Video video;
  const VideoTile({super.key, required this.video});

  @override
  State<VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<VideoTile> {
  late VideoPlayerController _controller;
  bool _isPlayerReady =
      false; // Indicates if the video player is initialized and ready

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer(); // Initialize video player when widget mounts
  }

  /// Initializes the video player with the video URL.
  Future<void> _initializeVideoPlayer() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(
          widget.video.videoFiles.first.link,
        ), // Use the first video link
      );
      await _controller.initialize(); // Initialize the controller
      _controller.setLooping(true); // Loop the video
      _controller.setVolume(1.0); // Set volume to 100%
      _controller.play(); // Automatically play the video
      if (mounted) {
        setState(() {
          _isPlayerReady = true; // Set player ready state to true
        });
      }
    } catch (e) {
      debugPrint('Error initializing video player: $e'); // Log error
      if (mounted) {
        setState(() {
          _isPlayerReady = false; // Set player ready state to false on error
        });
        _showSnackBar('Failed to load video.'); // Show user an error message
      }
    }
  }

  /// Downloads the video to the device's external storage.
  Future<void> _downloadVideo(BuildContext context) async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Downloading video...')));
    try {
      VideoFile? videoFileToDownload;
      // Logic to prefer MP4 files and higher quality (HD > SD)
      if (widget.video.videoFiles.any(
        (file) => file.quality == 'hd' && file.fileType == 'video/mp4',
      )) {
        videoFileToDownload = widget.video.videoFiles.firstWhere(
          (file) => file.quality == 'hd' && file.fileType == 'video/mp4',
        );
      } else if (widget.video.videoFiles.any(
        (file) => file.quality == 'sd' && file.fileType == 'video/mp4',
      )) {
        videoFileToDownload = widget.video.videoFiles.firstWhere(
          (file) => file.quality == 'sd' && file.fileType == 'video/mp4',
        );
      } else if (widget.video.videoFiles.isNotEmpty &&
          widget.video.videoFiles.first.fileType == 'video/mp4') {
        videoFileToDownload = widget.video.videoFiles.firstWhere(
          (file) => file.fileType == 'video/mp4',
        );
      }

      if (videoFileToDownload == null) {
        throw Exception('No suitable MP4 video file found for download.');
      }

      final response = await http.get(Uri.parse(videoFileToDownload.link));
      if (response.statusCode != 200) {
        throw Exception('Failed to download video: ${response.statusCode}');
      }
      final bytes = response.bodyBytes;
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('Could not get external storage directory.');
      }

      // Create a specific folder for videos
      final videoDir = Directory('${directory.path}/Videos');
      if (!await videoDir.exists()) {
        await videoDir.create(recursive: true);
      }

      final file = File(
        '${videoDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4',
      );

      await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video downloaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Video download failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Video download failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Displays a SnackBar with the given message.
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  void dispose() {
    _controller
        .dispose(); // Dispose of the video controller to release resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child:
          _isPlayerReady // Show video player if ready, otherwise show loading indicator
              ? Stack(
                children: [
                  Positioned.fill(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller), // Actual video player
                    ),
                  ),
                  // User Name Overlay at the very bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Text(
                        widget.video.user.name, // Display user name
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  // Controls Row (Play/Pause, Mute/Unmute, Download) above the user name
                  Positioned(
                    bottom: 30, // Position above the user name overlay
                    left: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceAround, // Distribute buttons evenly
                        children: [
                          // Play/Pause button
                          IconButton(
                            icon: Icon(
                              _controller.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _controller.value.isPlaying
                                    ? _controller.pause()
                                    : _controller.play();
                              });
                            },
                            tooltip:
                                _controller.value.isPlaying
                                    ? 'Pause Video'
                                    : 'Play Video',
                          ),
                          // Mute/Unmute button
                          IconButton(
                            icon: Icon(
                              _controller.value.volume == 0
                                  ? Icons.volume_off
                                  : Icons.volume_up,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _controller.value.volume == 1.0
                                    ? _controller.setVolume(0.0)
                                    : _controller.setVolume(1.0);
                              });
                            },
                            tooltip:
                                _controller.value.volume == 0
                                    ? 'Unmute Video'
                                    : 'Mute Video',
                          ),
                          // Download Video Button
                          IconButton(
                            icon: const Icon(
                              Icons.download,
                              color: Colors.white,
                            ),
                            onPressed:
                                () => _downloadVideo(
                                  context,
                                ), // Call download function
                            tooltip: 'Download Video',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
              : const SizedBox(
                height: 200, // Placeholder height while loading
                child: Center(
                  child: CircularProgressIndicator(),
                ), // Loading indicator for video
              ),
    );
  }
}
