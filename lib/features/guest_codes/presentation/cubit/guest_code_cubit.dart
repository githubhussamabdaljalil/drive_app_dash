import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/guest_code_remote_datasource.dart';
import '../../data/models/guest_code_model.dart';

part 'guest_code_state.dart';

class GuestCodeCubit extends Cubit<GuestCodeState> {
  final GuestCodeRemoteDataSource _ds = GuestCodeRemoteDataSource();

  GuestCodeCubit() : super(GuestCodeInitial());

  Future<void> load({String? status}) async {
    if (isClosed) return;
    emit(GuestCodeLoading());
    try {
      final list = await _ds.getGuestCodes(status: status);
      if (!isClosed) emit(GuestCodeLoaded(list));
    } catch (e) {
      if (!isClosed) emit(GuestCodeError(e.toString()));
    }
  }

  Future<GuestCodeModel?> create({required int vehicleId, required int expiresInMinutes}) async {
    if (isClosed) return null;
    final current = _currentList;
    emit(GuestCodeSubmitting(current));
    try {
      final created = await _ds.createGuestCode(vehicleId: vehicleId, expiresInMinutes: expiresInMinutes);
      final list = await _ds.getGuestCodes();
      if (!isClosed) emit(GuestCodeLoaded(list));
      return created;
    } catch (e) {
      if (!isClosed) emit(GuestCodeError(e.toString(), current));
      return null;
    }
  }

  Future<bool> revoke(int id) async {
    if (isClosed) return false;
    final current = _currentList;
    emit(GuestCodeSubmitting(current));
    try {
      await _ds.revokeGuestCode(id);
      final list = await _ds.getGuestCodes();
      if (!isClosed) emit(GuestCodeLoaded(list));
      return true;
    } catch (e) {
      if (!isClosed) emit(GuestCodeError(e.toString(), current));
      return false;
    }
  }

  List<GuestCodeModel> get _currentList {
    final s = state;
    if (s is GuestCodeLoaded) return s.codes;
    if (s is GuestCodeSubmitting) return s.codes;
    if (s is GuestCodeError) return s.codes ?? [];
    return [];
  }
}
