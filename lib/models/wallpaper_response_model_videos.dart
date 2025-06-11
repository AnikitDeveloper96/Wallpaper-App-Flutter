import 'dart:convert';

WallpaperAppVideosResponseModel wallpaperAppVideosResponseModelFromJson(String str) => WallpaperAppVideosResponseModel.fromJson(json.decode(str));

String wallpaperAppVideosResponseModelToJson(WallpaperAppVideosResponseModel data) => json.encode(data.toJson());

class WallpaperAppVideosResponseModel {
    final int page;
    final int perPage;
    final List<Video> videos;
    final int totalResults;
    final String nextPage;
    final String url;

    WallpaperAppVideosResponseModel({
        required this.page,
        required this.perPage,
        required this.videos,
        required this.totalResults,
        required this.nextPage,
        required this.url,
    });

    factory WallpaperAppVideosResponseModel.fromJson(Map<String, dynamic> json) => WallpaperAppVideosResponseModel(
        page: json["page"],
        perPage: json["per_page"],
        videos: List<Video>.from(json["videos"].map((x) => Video.fromJson(x))),
        totalResults: json["total_results"],
        nextPage: json["next_page"],
        url: json["url"],
    );

    Map<String, dynamic> toJson() => {
        "page": page,
        "per_page": perPage,
        "videos": List<dynamic>.from(videos.map((x) => x.toJson())),
        "total_results": totalResults,
        "next_page": nextPage,
        "url": url,
    };
}

class Video {
    final int id;
    final int width;
    final int height;
    final int duration;
    final dynamic fullRes;
    final List<dynamic> tags;
    final String url;
    final String image;
    final dynamic avgColor;
    final User user;
    final List<VideoFile> videoFiles;
    final List<VideoPicture> videoPictures;

    Video({
        required this.id,
        required this.width,
        required this.height,
        required this.duration,
        required this.fullRes,
        required this.tags,
        required this.url,
        required this.image,
        required this.avgColor,
        required this.user,
        required this.videoFiles,
        required this.videoPictures,
    });

    factory Video.fromJson(Map<String, dynamic> json) => Video(
        id: json["id"],
        width: json["width"],
        height: json["height"],
        duration: json["duration"],
        fullRes: json["full_res"],
        tags: List<dynamic>.from(json["tags"].map((x) => x)),
        url: json["url"],
        image: json["image"],
        avgColor: json["avg_color"],
        user: User.fromJson(json["user"]),
        videoFiles: List<VideoFile>.from(json["video_files"].map((x) => VideoFile.fromJson(x))),
        videoPictures: List<VideoPicture>.from(json["video_pictures"].map((x) => VideoPicture.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "width": width,
        "height": height,
        "duration": duration,
        "full_res": fullRes,
        "tags": List<dynamic>.from(tags.map((x) => x)),
        "url": url,
        "image": image,
        "avg_color": avgColor,
        "user": user.toJson(),
        "video_files": List<dynamic>.from(videoFiles.map((x) => x.toJson())),
        "video_pictures": List<dynamic>.from(videoPictures.map((x) => x.toJson())),
    };
}

class User {
    final int id;
    final String name;
    final String url;

    User({
        required this.id,
        required this.name,
        required this.url,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        url: json["url"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "url": url,
    };
}

class VideoFile {
    final int id;
    final String quality; // Changed from Quality enum to String
    final String fileType; // Changed from FileType enum to String
    final int width;
    final int height;
    final double fps;
    final String link;
    final int size;

    VideoFile({
        required this.id,
        required this.quality,
        required this.fileType,
        required this.width,
        required this.height,
        required this.fps,
        required this.link,
        required this.size,
    });

    factory VideoFile.fromJson(Map<String, dynamic> json) => VideoFile(
        id: json["id"],
        quality: json["quality"], // Directly assign string
        fileType: json["file_type"], // Directly assign string
        width: json["width"],
        height: json["height"],
        fps: json["fps"]?.toDouble(),
        link: json["link"],
        size: json["size"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "quality": quality, // Directly use string
        "file_type": fileType, // Directly use string
        "width": width,
        "height": height,
        "fps": fps,
        "link": link,
        "size": size,
    };
}

class VideoPicture {
    final int id;
    final int nr;
    final String picture;

    VideoPicture({
        required this.id,
        required this.nr,
        required this.picture,
    });

    factory VideoPicture.fromJson(Map<String, dynamic> json) => VideoPicture(
        id: json["id"],
        nr: json["nr"],
        picture: json["picture"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "nr": nr,
        "picture": picture,
    };
}