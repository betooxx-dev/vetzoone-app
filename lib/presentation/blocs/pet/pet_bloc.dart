import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/pet/get_pets_usecase.dart';
import '../../../domain/usecases/pet/add_pet_usecase.dart';
import '../../../domain/usecases/pet/update_pet_usecase.dart';
import '../../../domain/usecases/pet/delete_pet_usecase.dart';
import '../../../domain/repositories/pet_repository.dart';
import 'pet_event.dart';
import 'pet_state.dart';

class PetBloc extends Bloc<PetEvent, PetState> {
  final PetRepository petRepository;

  PetBloc({required this.petRepository}) : super(PetInitial()) {
    on<LoadPetsEvent>(_onLoadPets);
    on<AddPetEvent>(_onAddPet);
    on<UpdatePetEvent>(_onUpdatePet);
    on<DeletePetEvent>(_onDeletePet);
    on<GetPetByIdEvent>(_onGetPetById);
  }

  Future<void> _onLoadPets(LoadPetsEvent event, Emitter<PetState> emit) async {
    emit(PetLoading());
    try {
      final getPetsUseCase = GetPetsUseCase(repository: petRepository);
      final pets = await getPetsUseCase.call(event.userId);
      emit(PetsLoaded(pets: pets));
    } catch (e) {
      emit(PetError(message: e.toString()));
    }
  }

  Future<void> _onAddPet(AddPetEvent event, Emitter<PetState> emit) async {
    emit(PetLoading());
    try {
      final addPetUseCase = AddPetUseCase(repository: petRepository);
      await addPetUseCase.call(event.pet, imageFile: event.imageFile);
      emit(const PetOperationSuccess(message: 'Mascota agregada exitosamente'));
    } catch (e) {
      emit(PetError(message: e.toString()));
    }
  }

  Future<void> _onUpdatePet(UpdatePetEvent event, Emitter<PetState> emit) async {
    emit(PetLoading());
    try {
      final updatePetUseCase = UpdatePetUseCase(repository: petRepository);
      await updatePetUseCase.call(event.petId, event.pet, imageFile: event.imageFile);
      emit(const PetOperationSuccess(message: 'Mascota actualizada exitosamente'));
    } catch (e) {
      emit(PetError(message: e.toString()));
    }
  }

  Future<void> _onDeletePet(DeletePetEvent event, Emitter<PetState> emit) async {
    emit(PetLoading());
    try {
      final deletePetUseCase = DeletePetUseCase(repository: petRepository);
      await deletePetUseCase.call(event.petId);
      emit(const PetOperationSuccess(message: 'Mascota eliminada exitosamente'));
    } catch (e) {
      emit(PetError(message: e.toString()));
    }
  }

  Future<void> _onGetPetById(GetPetByIdEvent event, Emitter<PetState> emit) async {
    emit(PetLoading());
    try {
      final pet = await petRepository.getPetById(event.petId);
      emit(PetLoaded(pet: pet));
    } catch (e) {
      emit(PetError(message: e.toString()));
    }
  }
}