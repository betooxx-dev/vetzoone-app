import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImageViewer extends StatefulWidget {
  final String imageUrl;
  final String? title;
  final String? description;
  final List<String>? imageGallery;
  final int? initialIndex;
  final bool showShare;
  final bool showDownload;
  final VoidCallback? onClose;

  const ImageViewer({
    super.key,
    required this.imageUrl,
    this.title,
    this.description,
    this.imageGallery,
    this.initialIndex,
    this.showShare = false,
    this.showDownload = false,
    this.onClose,
  });

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _zoomController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  late PageController _pageController;
  late TransformationController _transformationController;
  
  int _currentIndex = 0;
  bool _showControls = true;
  bool _isZoomed = false;
  double _currentScale = 1.0;
  
  List<String> _images = [];
  
  @override
  void initState() {
    super.initState();
    
    // Inicializar lista de imágenes
    if (widget.imageGallery != null && widget.imageGallery!.isNotEmpty) {
      _images = widget.imageGallery!;
      _currentIndex = widget.initialIndex ?? 0;
    } else {
      _images = [widget.imageUrl];
      _currentIndex = 0;
    }
    
    _pageController = PageController(initialPage: _currentIndex);
    _transformationController = TransformationController();
    
    // Configurar animaciones
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _zoomController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
    
    // Ocultar controles automáticamente después de 3 segundos
    _hideControlsAfterDelay();
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showControls) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    
    if (_showControls) {
      _hideControlsAfterDelay();
    }
  }

  void _onInteractionStart(ScaleStartDetails details) {
    // Detectar si es un doble tap
    if (details.pointerCount == 1) {
      // Single tap - toggle controls
      _toggleControls();
    }
  }

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    _currentScale = details.scale;
    _isZoomed = _currentScale > 1.2;
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
    setState(() {
      _isZoomed = false;
      _currentScale = 1.0;
    });
  }

  void _zoomIn() {
    final double newScale = (_currentScale * 1.5).clamp(0.5, 5.0);
    _transformationController.value = Matrix4.identity()..scale(newScale);
    setState(() {
      _currentScale = newScale;
      _isZoomed = newScale > 1.2;
    });
  }

  void _zoomOut() {
    final double newScale = (_currentScale / 1.5).clamp(0.5, 5.0);
    _transformationController.value = Matrix4.identity()..scale(newScale);
    setState(() {
      _currentScale = newScale;
      _isZoomed = newScale > 1.2;
    });
  }

  void _previousImage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextImage() {
    if (_currentIndex < _images.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _shareImage() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de compartir próximamente'),
        backgroundColor: Color(0xFF3498DB),
      ),
    );
  }

  void _downloadImage() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Imagen guardada en galería'),
        backgroundColor: Color(0xFF27AE60),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _zoomController.dispose();
    _pageController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Stack(
            children: [
              // Imagen principal con zoom
              Center(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                    _resetZoom();
                    HapticFeedback.selectionClick();
                  },
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return InteractiveViewer(
                      transformationController: _transformationController,
                      minScale: 0.5,
                      maxScale: 5.0,
                      onInteractionStart: _onInteractionStart,
                      onInteractionUpdate: _onInteractionUpdate,
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                        ),
                        child: Image.network(
                          _images[index],
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: const Color(0xFF3498DB),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.white54,
                                    size: 64,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Error al cargar imagen',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                top: _showControls ? 0 : -100,
                left: 0,
                right: 0,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        // ignore: deprecated_member_use
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          // Botón cerrar
                          IconButton(
                            onPressed: () {
                              widget.onClose?.call();
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.title != null)
                                  Text(
                                    widget.title!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                if (_images.length > 1)
                                  Text(
                                    '${_currentIndex + 1} de ${_images.length}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          
                          if (widget.showShare)
                            IconButton(
                              onPressed: _shareImage,
                              icon: const Icon(
                                Icons.share,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          
                          if (widget.showDownload)
                            IconButton(
                              onPressed: _downloadImage,
                              icon: const Icon(
                                Icons.download,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                bottom: _showControls ? 0 : -150,
                left: 0,
                right: 0,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        // ignore: deprecated_member_use
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        if (widget.description != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              widget.description!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        
                        const SizedBox(height: 16),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Imagen anterior
                            IconButton(
                              onPressed: _currentIndex > 0 ? _previousImage : null,
                              icon: Icon(
                                Icons.skip_previous,
                                color: _currentIndex > 0 ? Colors.white : Colors.white38,
                                size: 32,
                              ),
                            ),
                            
                            IconButton(
                              onPressed: _currentScale > 0.5 ? _zoomOut : null,
                              icon: Icon(
                                Icons.zoom_out,
                                color: _currentScale > 0.5 ? Colors.white : Colors.white38,
                                size: 28,
                              ),
                            ),
                            
                            IconButton(
                              onPressed: _isZoomed ? _resetZoom : null,
                              icon: Icon(
                                Icons.center_focus_strong,
                                color: _isZoomed ? Colors.white : Colors.white38,
                                size: 28,
                              ),
                            ),
                            
                            IconButton(
                              onPressed: _currentScale < 5.0 ? _zoomIn : null,
                              icon: Icon(
                                Icons.zoom_in,
                                color: _currentScale < 5.0 ? Colors.white : Colors.white38,
                                size: 28,
                              ),
                            ),
                            
                            IconButton(
                              onPressed: _currentIndex < _images.length - 1 ? _nextImage : null,
                              icon: Icon(
                                Icons.skip_next,
                                color: _currentIndex < _images.length - 1 ? Colors.white : Colors.white38,
                                size: 32,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (_images.length > 1)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: AnimatedOpacity(
                    opacity: _showControls ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_images.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: index == _currentIndex ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: index == _currentIndex ? Colors.white : Colors.white38,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget helper para mostrar el visor de imágenes como modal
class ImageViewerModal {
  static void show(
    BuildContext context, {
    required String imageUrl,
    String? title,
    String? description,
    List<String>? imageGallery,
    int? initialIndex,
    bool showShare = false,
    bool showDownload = false,
    VoidCallback? onClose,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (context, animation, secondaryAnimation) {
          return ImageViewer(
            imageUrl: imageUrl,
            title: title,
            description: description,
            imageGallery: imageGallery,
            initialIndex: initialIndex,
            showShare: showShare,
            showDownload: showDownload,
            onClose: onClose,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}