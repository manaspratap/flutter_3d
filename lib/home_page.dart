import 'dart:math';

import 'package:flutter/material.dart';
import 'package:some3d/utils/image_sequence.dart';

class HomePage extends StatefulWidget {
  HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  double screenHeight, screenWidth;
  double bikeSpecsWidth;
  double addedScreenHeight;
  double onDragPositionStart;
  bool isBikeSpecsVisible = false;
  AnimationController animationController;

  List<String> bikeSpecsImages = [
    'assets/images/bike_specs_disp.png',
    'assets/images/bike_specs_type.png',
    'assets/images/bike_specs_break.png',
    'assets/images/bike_specs_cylinder.png',
    'assets/images/bike_specs_fuel.png',
    'assets/images/bike_specs_height.png',
  ];

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    addedScreenHeight = 0.2 * screenHeight;
    bikeSpecsWidth = 0.35 * screenWidth;

    super.didChangeDependencies();
  }

  void onDragStartFunction(DragStartDetails dragStartDetails) {
    // to mark starting position
    onDragPositionStart = dragStartDetails.globalPosition.dx;
  }

  void onDragUpdateFunction(DragUpdateDetails dragStartDetails) {
    var dragDistance = dragStartDetails.globalPosition.dx - onDragPositionStart;
    var dragDistanceFactor;

    if (dragDistance > 0) {
      dragDistanceFactor = dragDistance / screenWidth;
      // do nothing if the drag continues in the direction of
      // making specs visible, even though they are already visible
      if (isBikeSpecsVisible && dragDistanceFactor <= 1.0) return;
      // goto "for drag" of onDragEndFunction
      animationController.value = dragDistanceFactor;
    } else {
      dragDistanceFactor = 1 + (dragDistance / screenWidth);
      if (!isBikeSpecsVisible && dragDistanceFactor >= 0.0) return;
      animationController.value = dragDistanceFactor;
    }
  }

  void onDragEndFunction(DragEndDetails dragStartDetails) {
    // for swipe
    if (dragStartDetails.velocity.pixelsPerSecond.dx.abs() > 500) {
      if (dragStartDetails.velocity.pixelsPerSecond.dx > 0) {
        animationController.forward(from: animationController.value);
        isBikeSpecsVisible = true;
      } else {
        animationController.reverse(from: animationController.value);
        isBikeSpecsVisible = false;
      }
      return;
    }
    // for drag
    if (animationController.value > 0.5) {
      animationController.forward(from: animationController.value);
      isBikeSpecsVisible = true;
    } else {
      animationController.reverse(from: animationController.value);
      isBikeSpecsVisible = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Container(
          child: GestureDetector(
            onHorizontalDragStart: onDragStartFunction,
            onHorizontalDragUpdate: onDragUpdateFunction,
            onHorizontalDragEnd: onDragEndFunction,
            child: Stack(
              children: <Widget>[
                // page background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Colors.white, Colors.white, Colors.blue],
                    ),
                  ),
                ),
                bikeBackgroundWidget(),
                bikeWidget(),
                bikeForegroundWidget(),
                bikeSpecsWidget(),
                bikeSpecsFooterWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget bikeBackgroundWidget() {
    return Positioned.fill(
      top: -addedScreenHeight,
      bottom: -addedScreenHeight,
      child: AnimatedBuilder(
        animation: animationController,
        // single-operation constructor
        //
        // to move its child by "bikeSpecsWidth" in x-axis
        builder: (context, widget) => Transform.translate(
          offset: Offset(bikeSpecsWidth * animationController.value, 0),
          // defalut constructor
          child: Transform(
            transform: Matrix4.identity()
              // to add perspective
              //
              // reduces lengths when the object goes farther away
              // and increases them when they come nearer
              ..setEntry(3, 2, 0.001) // this sets value at 4 column and 3 row
              // to rotate its child by 90 + 0.1 degrees
              ..rotateY((pi / 2 + 0.1) * -animationController.value),
            alignment: Alignment.centerLeft,
            child: widget,
          ),
        ),
        // background
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.white,
                Colors.white,
                Colors.blue,
                Colors.white,
                Colors.white
              ],
            ),
          ),
          // shadow of background
          //
          // good to add either shadow or opacity
          // to enhance perspective
          child: Stack(
            children: <Widget>[
              AnimatedBuilder(
                animation: animationController,
                builder: (_, __) => Container(
                  color: Colors.black.withAlpha(
                    (150 * animationController.value).floor(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bikeWidget() {
    return Positioned.fill(
      left: bikeSpecsWidth - screenWidth * 0.3,
      right: screenWidth * 0.4 - bikeSpecsWidth,
      child: Container(
        child: AnimatedBuilder(
          animation: animationController,
          builder: (_, __) => ImageSequence(
            imageRelativePath: "assets/bikeImageSequence/",
            imageNameIncrement: 1,
            imageNameLength: 4,
            imageFileFormat: ".png",
            totalImages: 120,
            currentImage: (animationController.value * 120).ceil(),
          ),
        ),
      ),
    );
  }

  Widget bikeForegroundWidget() {
    return Positioned.fill(
      bottom: 50,
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, widget) => Opacity(
          opacity: 1 - animationController.value,
          child: Transform.translate(
            // +50 on x-axis to see the different layers while rotating
            offset:
                Offset((bikeSpecsWidth + 50) * animationController.value, 0),
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY((pi / 2 + 0.1) * -animationController.value),
              alignment: Alignment.centerLeft,
              child: widget,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Image.asset('assets/images/royal_enfield_symbol.png'),
                ),
                Container(
                  height: 40,
                  padding: EdgeInsets.only(right: 20),
                  child: Image.asset('assets/images/royal_enfield.png'),
                ),
              ],
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Image.asset('assets/images/bike_model_name.png'),
            ),
          ],
        ),
      ),
    );
  }

  Widget bikeSpecsWidget() {
    return Positioned.fill(
      top: -addedScreenHeight,
      bottom: -addedScreenHeight,
      right: screenWidth - bikeSpecsWidth,
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, widget) {
          return Transform.translate(
            offset: Offset(bikeSpecsWidth * (animationController.value - 1), 0),
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(pi * (1 - animationController.value) / 2),
              alignment: Alignment.centerRight,
              child: widget,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.blue, Colors.white, Colors.white],
            ),
          ),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                top: addedScreenHeight,
                bottom: addedScreenHeight,
                child: Container(
                  width: bikeSpecsWidth,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: Image.asset('assets/images/bike_logo.png'),
                        ),
                        for (var specsIndex = 0;
                            specsIndex <= bikeSpecsImages.length - 1;
                            specsIndex++)
                          Expanded(
                            child: Image.asset(bikeSpecsImages[specsIndex]),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              // shadow of page
              AnimatedBuilder(
                animation: animationController,
                builder: (_, __) => Container(
                  width: bikeSpecsWidth,
                  color: Colors.black.withAlpha(
                    (150 * (1 - animationController.value)).floor(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bikeSpecsFooterWidget() {
    return SafeArea(
      child: AnimatedBuilder(
        animation: animationController,
        builder: (_, __) {
          return Transform.translate(
            offset: Offset(screenWidth * (1 - animationController.value), 0),
            child: Opacity(
              opacity: animationController.value,
              child: Align(
                alignment: Alignment.bottomRight,
                child: SizedBox(
                  height: 250,
                  width: 250,
                  child: Image.asset('assets/images/bike_info.png'),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
