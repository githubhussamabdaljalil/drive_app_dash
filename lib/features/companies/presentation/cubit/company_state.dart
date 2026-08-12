part of 'company_cubit.dart';

abstract class CompanyState {}

class CompanyInitial extends CompanyState {}

class CompanyLoading extends CompanyState {}

class CompanyLoaded extends CompanyState {
  final List<CompanyModel> companies;
  CompanyLoaded(this.companies);
}

class CompanySubmitting extends CompanyState {
  final List<CompanyModel> companies;
  CompanySubmitting(this.companies);
}

class CompanyError extends CompanyState {
  final String message;
  final List<CompanyModel>? companies;
  CompanyError(this.message, [this.companies]);
}
