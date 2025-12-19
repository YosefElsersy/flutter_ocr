// EnhanceScreen.dart (Fixed Version)
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:provider/provider.dart';
import '../../core/providers/theme_provider.dart';

class EnhanceScreen extends StatefulWidget {
  final File image;
  const EnhanceScreen(this.image, {super.key});

  @override
  State<EnhanceScreen> createState() => _EnhanceScreenState();
}

class _EnhanceScreenState extends State<EnhanceScreen> {
  late img.Image inputImage;
  double contrast = 150;
  double brightness = 1;
  String _currentFilter = 'None';

  final List<String> _filters = [
    'None',
    'Grayscale',
    'Sepia',
    'Invert',
    'Blur',
    'Emboss',
    'Sketch',
    'Pixelate'
  ];

  @override
  void initState() {
    super.initState();
    inputImage = img.decodeImage(widget.image.readAsBytesSync())!;
    enhanceImage();
  }

  void enhanceImage() {
    img.Image temp = img.decodeImage(widget.image.readAsBytesSync())!;

    // Apply Filter
    switch (_currentFilter) {
      case 'Grayscale':
        temp = img.grayscale(temp);
        break;
      case 'Sepia':
        temp = img.sepia(temp);
        break;
      case 'Invert':
        temp = img.invert(temp);
        break;
      case 'Blur':
        temp = img.gaussianBlur(temp, radius: 4);
        break;
      case 'Emboss':
        temp = img.emboss(temp);
        break;
      case 'Sketch':
        temp = img.sobel(temp);
        break;
      case 'Pixelate':
        temp = img.pixelate(temp, size: 10);
        break;
      case 'None':
      default:
        // Do nothing
        break;
    }

    inputImage = img.adjustColor(temp, brightness: brightness);
    inputImage = img.contrast(inputImage, contrast: contrast);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : theme.primaryColor,
        centerTitle: true,
        title: const Text(
          'Enhance Image',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_vintage),
            tooltip: 'Apply Filters',
            onPressed: _showFilterOptions,
          ),
          IconButton(
            icon: const Icon(Icons.save_alt),
            tooltip: 'Save Image',
            onPressed: () async {
              try {
                final result = await ImageGallerySaverPlus.saveImage(
                    Uint8List.fromList(img.encodePng(inputImage)));
                print(result);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Image saved to gallery!'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error saving image: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Image Preview Card
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(
                    Uint8List.fromList(img.encodeBmp(inputImage)),
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Controls Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor.withValues(alpha: 0.1),
                      theme.primaryColor.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.tune, color: theme.primaryColor),
                    const SizedBox(width: 12),
                    Text(
                      'Image Adjustments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Contrast Control
              _buildControlCard(
                isDark: isDark,
                theme: theme,
                icon: Icons.contrast,
                label: 'Contrast',
                value: contrast,
                min: 80,
                max: 200,
                divisions: 12,
                onChanged: (v) {
                  setState(() {
                    contrast = v;
                    enhanceImage();
                  });
                },
              ),
              const SizedBox(height: 16),

              // Brightness Control
              _buildControlCard(
                isDark: isDark,
                theme: theme,
                icon: Icons.brightness_6,
                label: 'Brightness',
                value: brightness,
                min: 1,
                max: 10,
                divisions: 10,
                onChanged: (v) {
                  setState(() {
                    brightness = v;
                    enhanceImage();
                  });
                },
              ),
              const SizedBox(height: 24),

              // Reset Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      contrast = 150;
                      brightness = 1;
                      _currentFilter = 'None';
                      enhanceImage();
                    });
                  },
                  icon: const Icon(Icons.refresh, size: 22),
                  label: const Text(
                    'Reset to Default',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    foregroundColor: isDark ? Colors.white : Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlCard({
    required bool isDark,
    required ThemeData theme,
    required IconData icon,
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.primaryColor,
                          theme.primaryColor.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 24, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  value.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: theme.primaryColor,
              inactiveTrackColor:
                  isDark ? Colors.grey.shade800 : Colors.grey.shade300,
              thumbColor: theme.primaryColor,
              overlayColor: theme.primaryColor.withValues(alpha: 0.2),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            ),
            child: Slider(
              value: value,
              onChanged: onChanged,
              min: min,
              max: max,
              divisions: divisions,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                min.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                max.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Filter',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filters.length,
                  itemBuilder: (ctx, index) {
                    final filter = _filters[index];
                    final isSelected = _currentFilter == filter;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentFilter = filter;
                          enhanceImage();
                        });
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(12),
                        width: 80,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected
                              ? Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 2)
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Icon(
                                filter == 'None'
                                    ? Icons.block
                                    : filter == 'Grayscale'
                                        ? Icons.filter_b_and_w
                                        : filter == 'Sepia'
                                            ? Icons.nature_people
                                            : filter == 'Invert'
                                                ? Icons.invert_colors
                                                : filter == 'Blur'
                                                    ? Icons.blur_on
                                                    : filter == 'Emboss'
                                                        ? Icons.terrain
                                                        : filter == 'Sketch'
                                                            ? Icons.brush
                                                            : Icons.grid_on,
                                color: isSelected
                                  ? Colors.white
                                  : (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey
                                      : Colors.grey.shade700),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              filter,
                              style: TextStyle(
                                fontSize: 10,
                                color: isSelected
                                    ? Colors.white
                                    : (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey
                                        : Colors.grey.shade700),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}