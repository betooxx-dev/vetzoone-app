import '../entities/veterinarian.dart';
import '../../presentation/blocs/veterinarian/veterinarian_state.dart';

class SearchResult {
  final List<Veterinarian> veterinarians;
  final AIPrediction? aiPrediction;

  const SearchResult({
    required this.veterinarians,
    this.aiPrediction,
  });
}
