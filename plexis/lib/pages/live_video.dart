import "package:flutter/material.dart";
import "package:flutter_mjpeg/flutter_mjpeg.dart";

class LiveVideoPage extends StatelessWidget {
  const LiveVideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Video"),
      ),
      body: Center(
        child: Container(
          width: 400,
          height: 500,
          child: VideoStream(),
        ),
      ),
    );
  }
}

class VideoStream extends StatelessWidget {
  const VideoStream({super.key});

  @override
  Widget build(BuildContext context) {
    return Mjpeg(
      stream: 'http://10.224.6.194:5000/video_feed',
      isLive: true,
      timeout: const Duration(seconds: 30),
      error: (context, error, stack) {
        return Text('Something went wrong while fetching the live stream: $error');
      },
    );
  }
}
