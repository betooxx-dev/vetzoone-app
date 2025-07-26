import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/medical_records/get_medical_records_usecase.dart';
import '../../../domain/usecases/medical_records/get_vaccinations_usecase.dart';
import 'medical_records_event.dart';
import 'medical_records_state.dart';

class MedicalRecordsBloc extends Bloc<MedicalRecordsEvent, MedicalRecordsState> {
  final GetMedicalRecordsUseCase getMedicalRecordsUseCase;
  final GetVaccinationsUseCase getVaccinationsUseCase;

  MedicalRecordsBloc({
    required this.getMedicalRecordsUseCase,
    required this.getVaccinationsUseCase,
  }) : super(MedicalRecordsInitial()) {
    on<LoadMedicalRecords>(_onLoadMedicalRecords);
    on<LoadVaccinations>(_onLoadVaccinations);
    on<LoadAllMedicalData>(_onLoadAllMedicalData);
  }

  Future<void> _onLoadMedicalRecords(
    LoadMedicalRecords event,
    Emitter<MedicalRecordsState> emit,
  ) async {
    emit(MedicalRecordsLoading());
    
    try {
      final medicalRecords = await getMedicalRecordsUseCase(event.petId);
      emit(MedicalRecordsLoaded(medicalRecords));
    } catch (e) {
      emit(MedicalRecordsError(e.toString()));
    }
  }

  Future<void> _onLoadVaccinations(
    LoadVaccinations event,
    Emitter<MedicalRecordsState> emit,
  ) async {
    emit(VaccinationsLoading());
    
    try {
      final vaccinations = await getVaccinationsUseCase(event.petId);
      emit(VaccinationsLoaded(vaccinations));
    } catch (e) {
      emit(MedicalRecordsError(e.toString()));
    }
  }

  Future<void> _onLoadAllMedicalData(
    LoadAllMedicalData event,
    Emitter<MedicalRecordsState> emit,
  ) async {
    emit(MedicalRecordsLoading());
    
    try {
      final medicalRecords = await getMedicalRecordsUseCase(event.petId);
      final vaccinations = await getVaccinationsUseCase(event.petId);
      
      emit(MedicalRecordsAndVaccinationsLoaded(
        medicalRecords: medicalRecords,
        vaccinations: vaccinations,
      ));
    } catch (e) {
      emit(MedicalRecordsError(e.toString()));
    }
  }
}