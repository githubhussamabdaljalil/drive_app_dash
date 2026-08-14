import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/qr_code_remote_datasource.dart';
import '../../data/models/qr_code_model.dart';

part 'qr_code_state.dart';

class QrCodeCubit extends Cubit<QrCodeState> {
  final QrCodeRemoteDataSource _ds = QrCodeRemoteDataSource();

  QrCodeCubit() : super(QrCodeInitial());

  Future<void> load(int vehicleId) async {
    if (isClosed) return;
    emit(QrCodeLoading());
    try {
      final code = await _ds.getQrCode(vehicleId);
      if (!isClosed) emit(QrCodeLoaded(code));
    } catch (e) {
      if (!isClosed) emit(QrCodeError(e.toString()));
    }
  }

  Future<bool> generate(int vehicleId) async {
    if (isClosed) return false;
    final current = _currentCode;
    emit(QrCodeSubmitting(current));
    try {
      final code = await _ds.generateQrCode(vehicleId);
      if (!isClosed) emit(QrCodeLoaded(code));
      return true;
    } catch (e) {
      if (!isClosed) emit(QrCodeError(e.toString(), current));
      return false;
    }
  }

  Future<bool> revoke(int vehicleId) async {
    if (isClosed) return false;
    final current = _currentCode;
    emit(QrCodeSubmitting(current));
    try {
      await _ds.revokeQrCode(vehicleId);
      if (!isClosed) emit(QrCodeLoaded(null));
      return true;
    } catch (e) {
      if (!isClosed) emit(QrCodeError(e.toString(), current));
      return false;
    }
  }

  void reset() => emit(QrCodeInitial());

  QrCodeModel? get _currentCode {
    final s = state;
    if (s is QrCodeLoaded) return s.code;
    if (s is QrCodeSubmitting) return s.code;
    if (s is QrCodeError) return s.code;
    return null;
  }
}
