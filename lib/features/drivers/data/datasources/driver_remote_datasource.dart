import '../../../../core/services/api/api_client.dart';
import '../models/driver_model.dart';

class DriverRemoteDataSource {
  final ApiClient _api = ApiClient.instance;

  Future<List<DriverModel>> getDrivers() async {
    // TODO: uncomment when API is ready
    // final res = await _api.get('/admin/manager/drivers');
    // final list = res['data'] as List? ?? [];
    // return list.map((e) => DriverModel.fromJson(e)).toList();

    await Future.delayed(const Duration(milliseconds: 600));
    return _mockDrivers;
  }

  Future<DriverModel> createDriver(Map<String, dynamic> body) async {
    final res = await _api.post('/admin/manager/drivers', body);
    return DriverModel.fromJson(res['data'] ?? res);
  }

  Future<DriverModel> updateDriver(int id, Map<String, dynamic> body) async {
    final res = await _api.patch('/admin/manager/drivers/$id', body);
    return DriverModel.fromJson(res['data'] ?? res);
  }

  Future<void> deleteDriver(int id) => _api.delete('/admin/manager/drivers/$id');

  Future<DriverModel> activateDriver(int id) async {
    final res = await _api.patch('/admin/manager/drivers/$id/activate', {});
    return DriverModel.fromJson(res['data'] ?? res);
  }

  Future<DriverModel> deactivateDriver(int id) async {
    final res = await _api.patch('/admin/manager/drivers/$id/deactivate', {});
    return DriverModel.fromJson(res['data'] ?? res);
  }
}

const _mockDrivers = [
  DriverModel(id: 1, name: 'محمد عبدالله الغامدي', phone: '0501234567',
      email: 'mohammed@example.com', licenseNo: 'DL-10023', licenseExpiry: '2026-05-10',
      status: 'on_trip', companyName: 'شركة النقل الحديث', companyId: 1,
      assignedVehiclePlate: 'أ ب ج 1234'),
  DriverModel(id: 2, name: 'خالد سعد العمري', phone: '0559876543',
      email: 'khaled@example.com', licenseNo: 'DL-10045', licenseExpiry: '2025-11-20',
      status: 'active', companyName: 'شركة النقل الحديث', companyId: 1,
      assignedVehiclePlate: null),
  DriverModel(id: 3, name: 'فهد ناصر القحطاني', phone: '0531122334',
      email: 'fahad@example.com', licenseNo: 'DL-10067', licenseExpiry: '2027-03-15',
      status: 'active', companyName: 'شركة الخليج للنقل', companyId: 2,
      assignedVehiclePlate: 'د هـ و 5678'),
  DriverModel(id: 4, name: 'عمر يوسف الزهراني', phone: '0544556677',
      email: 'omar@example.com', licenseNo: 'DL-10089', licenseExpiry: '2024-08-30',
      status: 'inactive', companyName: 'شركة الخليج للنقل', companyId: 2,
      assignedVehiclePlate: null),
  DriverModel(id: 5, name: 'سلطان إبراهيم الدوسري', phone: '0567788990',
      email: 'sultan@example.com', licenseNo: 'DL-10101', licenseExpiry: '2026-12-01',
      status: 'on_trip', companyName: 'شركة الأمانة', companyId: 3,
      assignedVehiclePlate: 'ز ح ط 9012'),
  DriverModel(id: 6, name: 'عبدالرحمن علي الشهري', phone: '0512233445',
      email: 'abdulrahman@example.com', licenseNo: 'DL-10112', licenseExpiry: '2025-07-22',
      status: 'active', companyName: 'شركة الأمانة', companyId: 3,
      assignedVehiclePlate: null),
];
