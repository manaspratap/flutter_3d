import 'package:flutter/material.dart';

class ImageSequence extends StatefulWidget {
  // folder of the image sequence
  final String folderName;

  // suffix for the first image in your image sequence
  final int suffixStart;

  // suffix length for each image in your image sequence
  final int suffixCount;

  // file format of each image in the image sequence, like ".png", ".jpg", etc.
  final String fileFormat;

  final double frameCount;
  final int frame;

  const ImageSequence({
    this.folderName,
    this.suffixStart,
    this.suffixCount,
    this.fileFormat,
    this.frameCount,
    this.frame,
    Key key,
  }) : super(key: key);

  @override
  _ImageSequenceState createState() => _ImageSequenceState();
}

class _ImageSequenceState extends State<ImageSequence> {
  int previousFrame = 0;
  Image currentFrame;

  String getSuffix(String value) {
    while (value.length < widget.suffixCount) value = "0" + value;
    return value;
  }

  String getDirectory() {
    return widget.folderName +
        getSuffix((widget.suffixStart + previousFrame).toString()) +
        widget.fileFormat;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.frame != null) {
      if (currentFrame == null || widget.frame != previousFrame) {
        previousFrame = widget.frame;
        if (previousFrame < widget.frameCount)
          currentFrame = Image.asset(
            getDirectory(),
            gaplessPlayback: true,
          );
      }
    }
    return currentFrame;
  }
}
