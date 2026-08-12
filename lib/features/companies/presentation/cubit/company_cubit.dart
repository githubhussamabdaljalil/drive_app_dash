import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/company_remote_datasource.dart';
import '../../data/models/company_model.dart';

part 'company_state.dart';

class CompanyCubit extends Cubit<CompanyState> {
  final CompanyRemoteDataSource _ds = CompanyRemoteDataSource();

  CompanyCubit() : super(CompanyInitial());

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> load() async {
    if (isClosed) return;

    emit(CompanyLoading());

    try {
      final list = await _ds.getCompanies();

      if (!isClosed) {
        emit(CompanyLoaded(list));
      }
    } catch (e) {
      if (!isClosed) {
        emit(CompanyError(e.toString()));
      }
    }
  }

  // ============================================================
  // CREATE
  // ============================================================

  Future<bool> create(Map<String, dynamic> body) async {
    if (isClosed) return false;

    final current = _currentList;

    emit(CompanySubmitting(current));

    try {
      // إنشاء الشركة
      await _ds.createCompany(body);

      // إعادة تحميل البيانات من السيرفر
      // حتى تظهر الشركة الجديدة مباشرة بالبيانات الكاملة
      final list = await _ds.getCompanies();

      if (!isClosed) {
        emit(CompanyLoaded(list));
      }

      return true;
    } catch (e) {
      if (!isClosed) {
        emit(
          CompanyError(
            e.toString(),
            current,
          ),
        );
      }

      return false;
    }
  }

  // ============================================================
  // UPDATE
  // ============================================================

  Future<bool> update(
    int id,
    Map<String, dynamic> body,
  ) async {
    if (isClosed) return false;

    final current = _currentList;

    emit(CompanySubmitting(current));

    try {
      // تعديل الشركة
      await _ds.updateCompany(id, body);

      // إعادة تحميل البيانات من السيرفر
      final list = await _ds.getCompanies();

      if (!isClosed) {
        emit(CompanyLoaded(list));
      }

      return true;
    } catch (e) {
      if (!isClosed) {
        emit(
          CompanyError(
            e.toString(),
            current,
          ),
        );
      }

      return false;
    }
  }

  // ============================================================
  // TOGGLE STATUS
  // ============================================================

  Future<bool> toggleStatus(
    CompanyModel company,
  ) async {
    if (isClosed) return false;

    final current = _currentList;

    emit(CompanySubmitting(current));

    try {
      if (company.isActive) {
        await _ds.deactivateCompany(company.id);
      } else {
        await _ds.activateCompany(company.id);
      }

      // إعادة تحميل البيانات
      final list = await _ds.getCompanies();

      if (!isClosed) {
        emit(CompanyLoaded(list));
      }

      return true;
    } catch (e) {
      if (!isClosed) {
        emit(
          CompanyError(
            e.toString(),
            current,
          ),
        );
      }

      return false;
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<bool> delete(int id) async {
    if (isClosed) return false;

    final current = _currentList;

    emit(CompanySubmitting(current));

    try {
      await _ds.deleteCompany(id);

      // إعادة تحميل البيانات من السيرفر
      final list = await _ds.getCompanies();

      if (!isClosed) {
        emit(CompanyLoaded(list));
      }

      return true;
    } catch (e) {
      if (!isClosed) {
        emit(
          CompanyError(
            e.toString(),
            current,
          ),
        );
      }

      return false;
    }
  }

  // ============================================================
  // CURRENT LIST
  // ============================================================

  List<CompanyModel> get _currentList {
    final s = state;

    if (s is CompanyLoaded) {
      return s.companies;
    }

    if (s is CompanySubmitting) {
      return s.companies;
    }

    if (s is CompanyError) {
      return s.companies ?? [];
    }

    return [];
  }
}