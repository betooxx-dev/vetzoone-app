/// Utilidades para manejo de imágenes en la aplicación
class ImageUtils {
  /// Verifica si una URL de imagen es válida y segura para usar
  static bool isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return false;
    }
    
    try {
      final uri = Uri.parse(url);
      
      // Verificar que tiene esquema HTTP/HTTPS
      if (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
        return false;
      }
      
      // Verificar que tiene un host válido
      if (uri.host.isEmpty) {
        return false;
      }
      
      // Excluir URLs de ejemplo/placeholder conocidas
      final lowerUrl = url.toLowerCase();
      if (lowerUrl.contains('example.com') ||
          lowerUrl.contains('placeholder') ||
          lowerUrl.contains('dummy') ||
          lowerUrl.contains('lorem') ||
          lowerUrl.contains('test.com') ||
          lowerUrl.contains('sample.') ||
          lowerUrl.contains('demo.')) {
        return false;
      }
      
      return true;
    } catch (e) {
      // Si hay cualquier error al parsear la URL, considerarla inválida
      return false;
    }
  }
  
  /// Normaliza una URL de imagen para uso consistente
  static String? normalizeImageUrl(String? url) {
    if (!isValidImageUrl(url)) {
      return null;
    }
    
    return url!.trim();
  }
  
  /// Verifica si una URL corresponde a una imagen válida basándose en su extensión
  static bool hasValidImageExtension(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.jpg') ||
           lowerUrl.endsWith('.jpeg') ||
           lowerUrl.endsWith('.png') ||
           lowerUrl.endsWith('.gif') ||
           lowerUrl.endsWith('.webp') ||
           lowerUrl.endsWith('.bmp') ||
           lowerUrl.endsWith('.svg');
  }
  
  /// Obtiene el nombre de archivo de una URL de imagen
  static String? getImageFileName(String? url) {
    if (!isValidImageUrl(url)) return null;
    
    try {
      final uri = Uri.parse(url!);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        return pathSegments.last;
      }
    } catch (e) {
      // Error al parsear, retornar null
    }
    
    return null;
  }
}
