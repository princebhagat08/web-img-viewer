import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui;


/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// Application itself.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Flutter Demo', home: const HomePage());
  }
}

/// [Widget] displaying the home page consisting of an image and the buttons.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// State of a [HomePage].
class _HomePageState extends State<HomePage> {
  /// The URL of the currently displayed image.
  String imageUrl = '';

  /// Temporary holder for the new image URL entered by the user.
  String tempImageUrl = '';

  /// Controls the visibility of the menu overlay.
  bool isMenuVisible = false;

  /// Indicates whether the application is in fullscreen mode.
  bool isFullScreen = false;


  @override
  void initState() {
    super.initState();
    // Registering a view type for HTML image element
    _registerImageView('html-img');
  }

  /// Enters fullscreen mode using JavaScript interop.
  void enterFullScreen() {
    html.window.document.documentElement?.requestFullscreen();
    setState(() {
      isFullScreen = true;
    });
  }

  /// Exits fullscreen mode using JavaScript interop.
  void exitFullScreen() {
    html.document.exitFullscreen();
    setState(() {
      isFullScreen = false;
    });
  }

  /// Registers a new HTML image view with a unique [viewType].
  void _registerImageView(String viewType) {
    ui.platformViewRegistry.registerViewFactory(
      viewType,
          (int viewId) {
        final imgElement = html.ImageElement()
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.borderRadius = '12px'
          ..src = imageUrl
          ..onDoubleClick.listen((event) {
            isFullScreen ? exitFullScreen() : enterFullScreen();
          });
        return imgElement;
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: imageUrl.isEmpty
                          ? const Center(child: Text('No Image'))
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: HtmlElementView(
                          viewType: 'html-img',
                          key: ValueKey(imageUrl),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration:
                        const InputDecoration(hintText: 'Image URL'),
                        onChanged: (value) {
                            tempImageUrl = value;
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          imageUrl = tempImageUrl;
                          // Re-register the view to update the image source
                          _registerImageView('html-img');
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                        child: Icon(Icons.arrow_forward),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),
          if (isMenuVisible)
            GestureDetector(
              onTap: () {
                setState(() {
                  isMenuVisible = false;
                });
              },
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 15,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          enterFullScreen();
                          setState(() {
                            isMenuVisible = false;
                          });
                        },
                        child: const Text('Enter Fullscreen'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          exitFullScreen();
                          setState(() {
                            isMenuVisible = false;
                          });
                        },
                        child: const Text('Exit Fullscreen'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            isMenuVisible = !isMenuVisible;
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
