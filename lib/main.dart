import 'dart:js' as js;
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:webviewx/webviewx.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// Application itself.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praful Korat Task',
      home: const HomePage(),
    );
  }
}

/// Home Page Widget.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// State of HomePage.
class _HomePageState extends State<HomePage> {
  final TextEditingController _urlController = TextEditingController();
  bool _isMenuOpen = false;
  bool _isFullScreen = false;
  String _imageUrl = '';
  late WebViewXController _webViewController;

  @override
  void initState() {
    super.initState();
    html.window.onMessage.listen((event) {
      if (event.data is Map) {
        if (event.data['type'] == 'toggle_fullscreen') {
          _toggleFullScreen();
        }
        if (event.data['type'] == 'fullscreen_changed') {
          setState(() {
            _isFullScreen = event.data['isFullscreen'] == "true";
            _isMenuOpen = false;
          });
        }
      }
    });
  }

  /// Update the displayed image URL.
  void _updateImage() {
    setState(() {
      _imageUrl = _urlController.text.trim();
    });

    if (_webViewController != null) {
      _webViewController.loadContent(
        """
        <html>
          <body style="display:flex; justify-content:center; align-items:center; height:100vh; margin:0;">
            <img id="image" src="$_imageUrl" 
                 style="max-width: 100%; max-height: 100%;" 
                 ondblclick="window.parent.postMessage({type: 'toggle_fullscreen'}, '*')" />
          </body>
        </html>
        """,
        SourceType.html,
      );
    }
  }

  /// Toggle fullscreen mode.
  void _toggleFullScreen() {
    js.context.callMethod('toggleFullScreen');
    setState(() {
      _isMenuOpen = false;
    });
  }

  /// Toggle floating menu.
  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  /// Close the floating menu if open.
  void _closeMenu() {
    if (_isMenuOpen) {
      setState(() {
        _isMenuOpen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _closeMenu,
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
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
                    child: WebViewAware(
                      child: WebViewX(
                        key: ValueKey(_imageUrl),
                        onWebViewCreated: (controller) {
                          _webViewController = controller;
                        },
                        initialContent: """
                        <html>
                          <body style="display:flex; justify-content:center; align-items:center; height:100vh; margin:0;">
                            <img id="image" src="$_imageUrl" 
                                 style="max-width: 100%; max-height: 100%;" 
                                 ondblclick="window.parent.postMessage({type: 'toggle_fullscreen'}, '*')" />
                          </body>
                        </html>
                        """,
                        initialSourceType: SourceType.html,
                        height: double.maxFinite,
                        width: double.maxFinite,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(hintText: 'Enter Image URL'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _updateImage,
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                      child: Icon(Icons.arrow_forward),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
        floatingActionButton: Stack(
          children: [
            if (_isMenuOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _closeMenu,
                  child: Container(color: Colors.black.withOpacity(0.5)),
                ),
              ),
            Positioned(
              bottom: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_isMenuOpen) ...[
                    FloatingActionButton.extended(
                      onPressed: _isFullScreen ? null : _toggleFullScreen,
                      label: const Text("Enter Fullscreen"),
                      icon: const Icon(Icons.fullscreen),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.extended(
                      onPressed: _isFullScreen ? _toggleFullScreen : null,
                      label: const Text("Exit Fullscreen"),
                      icon: const Icon(Icons.fullscreen_exit),
                    ),
                    const SizedBox(height: 8),
                  ],
                  FloatingActionButton(
                    onPressed: _toggleMenu,
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
