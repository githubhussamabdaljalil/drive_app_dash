import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/sos_remote_datasource.dart';
import '../../data/models/sos_event_model.dart';

part 'sos_state.dart';

class SosCubit extends Cubit<SosState> {
  final SosRemoteDataSource _ds = SosRemoteDataSource();

  SosCubit() : super(SosInitial());

  Future<void> load({String? status}) async {
    if (isClosed) return;
    emit(SosLoading());
    try {
      final list = await _ds.getSosEvents(status: status);
      if (!isClosed) emit(SosLoaded(list));
    } catch (e) {
      if (!isClosed) emit(SosError(e.toString()));
    }
  }

  Future<bool> acknowledge(int id) async {
    if (isClosed) return false;
    final current = _currentList;
    emit(SosSubmitting(current));
    try {
      final updated = await _ds.acknowledge(id);
      if (!isClosed) emit(SosLoaded(current.map((e) => e.id == id ? updated : e).toList()));
      return true;
    } catch (e) {
      if (!isClosed) emit(SosError(e.toString(), current));
      return false;
    }
  }

  Future<bool> resolve(int id) async {
    if (isClosed) return false;
    final current = _currentList;
    emit(SosSubmitting(current));
    try {
      final updated = await _ds.resolve(id);
      if (!isClosed) emit(SosLoaded(current.map((e) => e.id == id ? updated : e).toList()));
      return true;
    } catch (e) {
      if (!isClosed) emit(SosError(e.toString(), current));
      return false;
    }
  }

  List<SosEventModel> get _currentList {
    final s = state;
    if (s is SosLoaded) return s.events;
    if (s is SosSubmitting) return s.events;
    if (s is SosError) return s.events ?? [];
    return [];
  }
}
