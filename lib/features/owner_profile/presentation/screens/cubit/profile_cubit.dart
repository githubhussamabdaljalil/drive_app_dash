import 'package:driver_app_dash/features/owner_profile/presentation/screens/data/datasources/owner_profile_datasoursce.dart';
import 'package:driver_app_dash/features/owner_profile/presentation/screens/models/profile_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRemoteDataSource _ds = ProfileRemoteDataSource();

  ProfileCubit() : super(ProfileInitial());

  Future<void> loadProfile() async {
    if (isClosed) return;

    emit(ProfileLoading());

    try {
      final profile = await _ds.getProfile();

      if (!isClosed) {
        emit(ProfileLoaded(profile));
      }
    } catch (e) {
      if (!isClosed) {
        emit(ProfileError(e.toString()));
      }
    }
  }
}
