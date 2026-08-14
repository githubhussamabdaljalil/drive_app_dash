part of 'manager_notification_cubit.dart';

abstract class ManagerNotificationState {}

class ManagerNotificationInitial extends ManagerNotificationState {}

class ManagerNotificationLoading extends ManagerNotificationState {}

class ManagerNotificationLoaded extends ManagerNotificationState {
  final List<ManagerNotificationModel> notifications;
  ManagerNotificationLoaded(this.notifications);
}

class ManagerNotificationError extends ManagerNotificationState {
  final String message;
  final List<ManagerNotificationModel>? notifications;
  ManagerNotificationError(this.message, [this.notifications]);
}
