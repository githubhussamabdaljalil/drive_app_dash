import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/manager_notification_remote_datasource.dart';
import '../../data/models/manager_notification_model.dart';

part 'manager_notification_state.dart';

class ManagerNotificationCubit extends Cubit<ManagerNotificationState> {
  final ManagerNotificationRemoteDataSource _ds = ManagerNotificationRemoteDataSource();

  ManagerNotificationCubit() : super(ManagerNotificationInitial());

  Future<void> load() async {
    if (isClosed) return;
    emit(ManagerNotificationLoading());
    try {
      final list = await _ds.getNotifications();
      if (!isClosed) emit(ManagerNotificationLoaded(list));
    } catch (e) {
      if (!isClosed) emit(ManagerNotificationError(e.toString()));
    }
  }

  // Optimistic — the list re-orders/refreshes fine either way on next load().
  Future<void> markRead(int id) async {
    if (isClosed) return;
    final current = _currentList;
    try {
      await _ds.markRead(id);
      final now = DateTime.now().toIso8601String();
      final updated = current
          .map((n) => n.id == id
              ? ManagerNotificationModel(id: n.id, type: n.type, event: n.event, payload: n.payload, readAt: now, createdAt: n.createdAt)
              : n)
          .toList();
      if (!isClosed) emit(ManagerNotificationLoaded(updated));
    } catch (e) {
      if (!isClosed) emit(ManagerNotificationError(e.toString(), current));
    }
  }

  List<ManagerNotificationModel> get _currentList {
    final s = state;
    if (s is ManagerNotificationLoaded) return s.notifications;
    if (s is ManagerNotificationError) return s.notifications ?? [];
    return [];
  }
}
