import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class SpotlightEffect extends StatefulWidget {
  const SpotlightEffect({super.key});

  @override
  State<SpotlightEffect> createState() => _SpotlightEffectState();
}

class _SpotlightEffectState extends State<SpotlightEffect>
    with SingleTickerProviderStateMixin {
  double _lightHeight = 0.0; // Default height of the light cone (starts at 0)
  late AnimationController _controller;
  late Animation<double> _animation;
  double _lightPosition = 0.5; // Default height of the light cone (starts at 0)
  Color _lightColor = Colors.blueAccent;

  bool isCardsVisible = false;

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3), // Duration of the animation
    );

    // Define a Tween that animates from 0.0 to 1.0 (full height of the light cone)
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {
          _lightHeight = _animation.value; // Update light height dynamically
          if (_animation.value > 0.5) {
            isCardsVisible = true;
          } else {
            isCardsVisible = false;
          }
        });
      });

    // Start the animation automatically when the widget is initialized
    _startAnimation();
  }

  void _startAnimation() {
    _controller.forward(); // Start the animation from 0 to full height
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the animation controller when done
    super.dispose();
  }

  void _updateLightHeight(double value) {
    setState(() {
      _lightHeight = value;
    });
  }

  void _updateLightPosition(double value) {
    setState(() {
      _lightPosition = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        // Use Stack to layer widgets
        children: [
          Positioned(
            bottom: 0, // Position cards at the bottom
            left: 0,
            right: 0,
            top: 0,
            child: Center(
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height),
                painter: SpotlightBeamPainter(
                    _lightHeight, _lightPosition, _lightColor),
              ),
            ),
          ),
          Positioned(
            bottom: 5, // Position cards at the bottom
            left: 0,
            right: 0,
            top: MediaQuery.of(context).size.height * 0.5,
            child: SizedBox(
                height: 350, // Fixed height for the card scroll
                child: AnimatedOpacity(
                  opacity: isCardsVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 3500),
                  child: cards(),
                )),
          ),
          Positioned(
            top: 50,
            right: 16,
            child: IconButton(
              icon: Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                _showSettingsBottomSheet(
                    context); // Show bottom sheet on button click
              },
            ),
          ),
        ],
      ),
    );
  }

  SingleChildScrollView cards() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(10, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                50.0,
              ), // Rounded corners
              child: Container(
                width: 300, // Width of each card
                height: 350, // Fixed height of each card
                decoration: BoxDecoration(
                  color:
                      Colors.white.withOpacity(0.45), // Card background color
                  border: Border.all(
                    color: Colors.white.withOpacity(0.7), // Shiny white border
                    width: 2, // Width of the border
                  ),
                  borderRadius: BorderRadius.circular(50.0), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white10,
                      blurRadius: 8.0,
                      offset: Offset(2, 2), // Shadow position
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Card ${index + 1}',
                    style: TextStyle(
                        color: Colors.grey.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 40),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // Function to show bottom sheet
  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Adjust Light Settings',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: _lightHeight,
                    min: 0.0,
                    max: 1.0,
                    divisions: 100,
                    label: 'Light Height',
                    onChanged: (value) {
                      setState(() {
                        _lightHeight = value; // Update the light height
                        _updateLightHeight(_lightHeight);
                      });
                    },
                  ),
                  Slider(
                    value: _lightPosition,
                    min: 0.0,
                    max: 1.0,
                    divisions: 100,
                    label: 'Light Position',
                    onChanged: (value) {
                      setState(() {
                        _lightPosition = value; // Update the light position
                        _updateLightPosition(_lightPosition);
                      });
                    },
                  ),
                  SizedBox(
                      height: 10), // Add space between text and color buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildColorSelector(Colors.orange),
                      _buildColorSelector(Colors.white),
                      _buildColorSelector(Colors.blue),
                      _buildColorSelector(Colors.yellow),
                      _buildColorSelector(Colors.pink),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Restart the animation when the button is pressed
                      _controller.reset();
                      _startAnimation();
                      Navigator.pop(context); // Dismiss the bottom sheet
                    },
                    child: Text('Restart Animation'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildColorSelector(Color color) {
    return GestureDetector(
      onTap: () {
        // Update the selected color here
        setState(() {
          _lightColor = color; // Update your light color variable
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        // Add space between buttons
        width: 40,
        // Width of the button
        height: 40,
        // Height of the button
        decoration: BoxDecoration(
          color: color, // Set the background color
          shape: BoxShape.circle, // Make it round
          border: Border.all(
            color: Colors.grey, // White border
            width: 2, // Border width
          ),
        ),
      ),
    );
  }
}

class SpotlightBeamPainter extends CustomPainter {
  final double lightHeight; // Height of the light cone passed from slider
  final double lightPosition; // Height of the light cone passed from slider
  final Color defaultColor;

  SpotlightBeamPainter(this.lightHeight, this.lightPosition, this.defaultColor);

  @override
  void paint(Canvas canvas, Size size) {
    // Set the background to black
    Paint backgroundPaint = Paint()..color = Colors.black;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Only draw the light if the slider value is greater than 0
    if (lightHeight > 0) {
      double lightCenterX =
          size.width * lightPosition; // Calculate horizontal position

      // Create the beam light effect using a linear gradient for the cone
      Paint beamPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(lightCenterX, size.height * 0.2),
          Offset(lightCenterX,
              size.height * lightHeight), // Height controlled by slider
          [
            defaultColor.withOpacity(
                0.9 * lightHeight), // Bright light controlled by height
            defaultColor
                .withOpacity(0.2 * lightHeight), // Dimmer as height decreases
            Colors.transparent,
          ],
          [0.0, 0.5, 1.0],
        );

      // Apply Gaussian blur to soften the edges of the cone
      MaskFilter blur = MaskFilter.blur(
          BlurStyle.normal, 10); // The blur radius can be adjusted
      beamPaint.maskFilter = blur;

      // Draw the cone-shaped beam from the top to the bottom with softer edges
      Path beamPath = Path();
      beamPath.moveTo(lightCenterX, size.height * 0.2); // Start of the cone
      beamPath.lineTo(0, size.height * lightHeight); // Left bottom corner
      beamPath.lineTo(
          size.width, size.height * lightHeight); // Right bottom corner
      beamPath.close();

      // Apply Gaussian blur for soft edges
      canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
      canvas.drawPath(beamPath, beamPaint);
      canvas.restore();

      // Create a Gaussian blur effect for the edges of the beam (using MaskFilter)
      Paint blurredBeamPaint = Paint()
        ..shader = beamPaint.shader
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20.0); // Gaussian blur

      // Reapply the path with the blurred edges
      canvas.drawPath(beamPath, blurredBeamPaint);

      // Create a brighter center for the spotlight, scaling with height for intensity
      Paint brightCenterPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            defaultColor.withOpacity(
                1.0 * lightHeight), // Brightness scales with height
            defaultColor
                .withOpacity(0.6 * lightHeight), // Softer as height decreases
            Colors.transparent,
          ],
          stops: [0.0, 0.3, 1.0],
        ).createShader(Rect.fromCircle(
          center: Offset(lightCenterX, size.height * 0.2), // Center at top
          radius: size.height *
              0.25 *
              lightHeight, // Radius also scales with height
        ));

      // Draw the brighter spot in the middle of the beam
      canvas.drawCircle(
        Offset(
            lightCenterX,
            size.height *
                0.4), // Place the center of the bright spot slightly lower
        size.height *
            0.4 *
            lightHeight, // Radius for the bright center spot scales with height
        brightCenterPaint,
      );

      // Add the top circular spotlight glow for origin
      Paint spotlightPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            defaultColor.withOpacity(
                0.8 * lightHeight), // Brightness controlled by height
            defaultColor
                .withOpacity(0.3 * lightHeight), // Softer as height decreases
            Colors.transparent,
          ],
          stops: [0.0, 0.5, 1.0],
        ).createShader(
          Rect.fromCircle(
            center: Offset(
                lightCenterX, size.height * 0.1), // Circle's center at top
            radius: size.height *
                0.2 *
                lightHeight, // Radius also scales with height
          ),
        );

      // Draw the top circular glow
      canvas.drawCircle(
        Offset(lightCenterX, size.height * 0.1), // Circle's center
        size.height * 0.2 * lightHeight, // Circle's radius scales with height
        spotlightPaint,
      );

      // Add a floor shine effect when the light reaches the bottom
      if (lightHeight >= 1) {
        Paint floorShinePaint = Paint()
          ..shader = RadialGradient(
            colors: [
              defaultColor.withOpacity(0.4), // Brightness for the shine
              defaultColor.withOpacity(0.4), // Soft outer edge
              defaultColor.withOpacity(0.35), // Fade out effect
            ],
            stops: [0.0, 0.8, 1.0],
          ).createShader(Rect.fromLTWH(0, size.height * 0.9, size.width,
              size.height * 0.05)); // Adjust position and size of the shine

        // Create a Gaussian blur effect for the edges of the beam (using MaskFilter)
        // Apply Gaussian blur to soften the edges of the cone
        MaskFilter blur = MaskFilter.blur(
            BlurStyle.normal, 20); // The blur radius can be adjusted
        floorShinePaint.maskFilter = blur;

        // Reapply the path with the blurred edges
        canvas.drawPath(beamPath, floorShinePaint);
        // Draw an oval-shaped floor shine
        canvas.drawOval(
          Rect.fromLTWH(
            0, // Adjust left position
            size.height * 0.9, // Adjust top position to be near the bottom
            size.width, // Make the oval cover the entire width
            size.height * 0.1, // Adjust the height for a thinner shine
          ),
          floorShinePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
