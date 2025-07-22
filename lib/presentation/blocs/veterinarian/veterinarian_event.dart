import 'package:equatable/equatable.dart';

abstract class VeterinarianEvent extends Equatable {
  const VeterinarianEvent();

  @override
  List<Object?> get props => [];
}

class SearchVeterinariansEvent extends VeterinarianEvent {
  final String? search;
  final String? location;
  final String? specialty;
  final int? limit;

  const SearchVeterinariansEvent({
    this.search,
    this.location,
    this.specialty,
    this.limit,
  });

  @override
  List<Object?> get props => [search, location, specialty, limit];
}

class GetVeterinarianProfileEvent extends VeterinarianEvent {
  final String vetId;

  const GetVeterinarianProfileEvent(this.vetId);

  @override
  List<Object?> get props => [vetId];
}

class LoadFeaturedVeterinariansEvent extends VeterinarianEvent {
  const LoadFeaturedVeterinariansEvent();
}

class ClearSearchEvent extends VeterinarianEvent {
  const ClearSearchEvent();
}