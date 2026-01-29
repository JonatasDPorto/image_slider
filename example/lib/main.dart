import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_slider_button/image_slider.dart';

/// Main entry point of the application
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for consistent UI
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ImageSliderApp());
}

/// Root application widget
class ImageSliderApp extends StatelessWidget {
  const ImageSliderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Slider Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const ImageSliderExamplePage(),
    );
  }
}

/// Main example page demonstrating the ImageSlider widget
class ImageSliderExamplePage extends StatefulWidget {
  const ImageSliderExamplePage({super.key});

  @override
  State<ImageSliderExamplePage> createState() => _ImageSliderExamplePageState();
}

class _ImageSliderExamplePageState extends State<ImageSliderExamplePage> {
  /// Map to store position for each style
  final Map<ImageSliderStyleEnum, int> _stylePositions = {
    for (final style in ImageSliderStyleEnum.values) style: 0,
  };

  /// List of fruit image paths
  static const List<String> _fruitImagePaths = [
    'assets/images/apple.png',
    'assets/images/banana.png',
    'assets/images/grapes.png',
  ];

  /// List of emotion image paths
  static const List<String> _emotionImagePaths = [
    'assets/images/angry.png',
    'assets/images/neutral_face.png',
    'assets/images/grin.png',
  ];

  /// List of moon image paths (3 moons)
  static const List<String> _moonImagePaths = [
    'assets/images/new_moon.png',
    'assets/images/first_quarter_moon.png',
    'assets/images/full_moon.png',
  ];

  /// List of 5 moon image paths (in correct lunar cycle order)
  static const List<String> _fiveMoonImagePaths = [
    'assets/images/new_moon.png',
    'assets/images/waxing_crescent_moon.png',
    'assets/images/first_quarter_moon.png',
    'assets/images/moon.png',
    'assets/images/full_moon.png',
  ];

  /// Returns the images to use for a specific style
  List<String> _getImagesForStyle(ImageSliderStyleEnum style) {
    // DEFAULT uses fruits, LINE uses 5 moons, NODE uses 3 moons, others use emotions
    switch (style) {
      case ImageSliderStyleEnum.DEFAULT:
        return _fruitImagePaths;
      case ImageSliderStyleEnum.LINE:
        return _fiveMoonImagePaths;
      case ImageSliderStyleEnum.NODE:
      case ImageSliderStyleEnum.NODE_BORDERLESS:
        return _moonImagePaths;
      default:
        return _emotionImagePaths;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sliderWidth = _calculateSliderWidth(screenWidth);

    return Scaffold(
      appBar: AppBar(title: const Text('Image Slider Example'), elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AllStylesSection(
                sliderWidth: sliderWidth,
                stylePositions: _stylePositions,
                onStyleEnd: _handleStyleEnd,
                getImagesForStyle: _getImagesForStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Calculates the optimal slider width based on screen width
  double _calculateSliderWidth(double screenWidth) {
    const minWidth = AppDimensions.sliderMinWidth;
    const maxWidth = AppDimensions.sliderMaxWidth;
    const horizontalPadding = AppDimensions.paddingMedium * 2;

    return (screenWidth - horizontalPadding).clamp(minWidth, maxWidth);
  }

  /// Handles slider end callback
  void _handleStyleEnd(ImageSliderStyleEnum style, int position) {
    final images = _getImagesForStyle(style);
    if (!mounted || position < 0 || position >= images.length) {
      return;
    }

    setState(() {
      _stylePositions[style] = position;
    });
  }
}

/// Section showing all slider styles
class _AllStylesSection extends StatelessWidget {
  const _AllStylesSection({
    required this.sliderWidth,
    required this.stylePositions,
    required this.onStyleEnd,
    required this.getImagesForStyle,
  });

  final double sliderWidth;
  final Map<ImageSliderStyleEnum, int> stylePositions;
  final void Function(ImageSliderStyleEnum style, int position) onStyleEnd;
  final List<String> Function(ImageSliderStyleEnum style) getImagesForStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'All Styles',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppDimensions.spacingLarge),
        for (final style in ImageSliderStyleEnum.values)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spacingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _StyleNameHelper.getName(style),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: AppDimensions.spacingXSmall),
                ImageSlider(
                  images: getImagesForStyle(
                    style,
                  ).map((path) => AssetImage(path)).toList(),
                  style: ImageSliderStyleOptions(
                    style: style,
                    width: sliderWidth,
                    imageWidth: AppDimensions.defaultImageWidth,
                    color: Colors.blue[300]!,
                    borderColor: Colors.blue[900]!,
                  ),
                  startPosition: stylePositions[style] ?? 0,
                  onEnd: (position) => onStyleEnd(style, position),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Helper class for style name mapping
class _StyleNameHelper {
  static String getName(ImageSliderStyleEnum style) {
    switch (style) {
      case ImageSliderStyleEnum.DEFAULT:
        return 'Default';
      case ImageSliderStyleEnum.BORDERLESS:
        return 'Borderless';
      case ImageSliderStyleEnum.NODE:
        return 'Node';
      case ImageSliderStyleEnum.NODE_BORDERLESS:
        return 'Node Borderless';
      case ImageSliderStyleEnum.LINE:
        return 'Line';
      case ImageSliderStyleEnum.LINE_BORDERLESS:
        return 'Line Borderless';
    }
  }
}

/// Application-wide dimension constants
class AppDimensions {
  AppDimensions._(); // Private constructor to prevent instantiation

  // Padding
  static const double paddingMedium = 20.0;
  static const double paddingSmall = 16.0;
  static const double paddingXSmall = 8.0;

  // Spacing
  static const double spacingLarge = 40.0;
  static const double spacingMedium = 20.0;
  static const double spacingSmall = 10.0;
  static const double spacingXSmall = 8.0;
  static const double spacingXXSmall = 4.0;

  // Slider dimensions
  static const double sliderMinWidth = 200.0;
  static const double sliderMaxWidth = 350.0;
  static const double defaultImageWidth = 50.0;
  static const double smallImageWidth = 40.0;
  static const double exampleSliderScale = 0.85;

  // Durations
  static const int snackBarDuration = 1;
}
