import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/veterinarian/search_veterinarians_usecase.dart';
import '../../../domain/usecases/veterinarian/get_veterinarian_profile_usecase.dart';
import 'veterinarian_event.dart';
import 'veterinarian_state.dart';

class VeterinarianBloc extends Bloc<VeterinarianEvent, VeterinarianState> {
  final SearchVeterinariansUseCase searchVeterinariansUseCase;
  final GetVeterinarianProfileUseCase getVeterinarianProfileUseCase;

  VeterinarianBloc({
    required this.searchVeterinariansUseCase,
    required this.getVeterinarianProfileUseCase,
  }) : super(VeterinarianInitial()) {
    on<SearchVeterinariansEvent>(_onSearchVeterinarians);
    on<GetVeterinarianProfileEvent>(_onGetVeterinarianProfile);
    on<LoadFeaturedVeterinariansEvent>(_onLoadFeaturedVeterinarians);
    on<ClearSearchEvent>(_onClearSearch);
  }

  Future<void> _onSearchVeterinarians(
    SearchVeterinariansEvent event,
    Emitter<VeterinarianState> emit,
  ) async {
    emit(VeterinarianLoading());
    try {
      final veterinarians = await searchVeterinariansUseCase(
        search: event.search,
        location: event.location,
        specialty: event.specialty,
        limit: event.limit,
        symptoms: event.symptoms,
      );
      emit(VeterinarianSearchSuccess(veterinarians));
    } catch (e) {
      emit(VeterinarianError(e.toString()));
    }
  }

  Future<void> _onGetVeterinarianProfile(
    GetVeterinarianProfileEvent event,
    Emitter<VeterinarianState> emit,
  ) async {
    emit(VeterinarianLoading());
    try {
      final veterinarian = await getVeterinarianProfileUseCase(event.vetId);
      emit(VeterinarianProfileLoaded(veterinarian));
    } catch (e) {
      emit(VeterinarianError(e.toString()));
    }
  }

  Future<void> _onLoadFeaturedVeterinarians(
    LoadFeaturedVeterinariansEvent event,
    Emitter<VeterinarianState> emit,
  ) async {
    emit(VeterinarianLoading());
    try {
      final veterinarians = await searchVeterinariansUseCase(limit: 100);
      emit(FeaturedVeterinariansLoaded(veterinarians));
    } catch (e) {
      emit(VeterinarianError(e.toString()));
    }
  }

  Future<void> _onClearSearch(
    ClearSearchEvent event,
    Emitter<VeterinarianState> emit,
  ) async {
    emit(VeterinarianInitial());
  }
}