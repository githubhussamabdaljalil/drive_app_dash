import '../../../../core/services/api/api_client.dart';
import '../models/vehicle_model.dart';

class VehicleRemoteDataSource {
  final ApiClient _api = ApiClient.instance;

  Future<List<VehicleModel>> getVehicles() async {
    // TODO: uncomment when API is ready
    // final res = await _api.get('/admin/manager/vehicles');
    // final list = res['data'] as List? ?? [];
    // return list.map((e) => VehicleModel.fromJson(e)).toList();

    await Future.delayed(const Duration(milliseconds: 600));
    return _mockVehicles;
  }

  Future<VehicleModel> createVehicle(Map<String, dynamic> body) async {
    final res = await _api.post('/admin/manager/vehicles', body);
    return VehicleModel.fromJson(res['data'] ?? res);
  }

  Future<VehicleModel> updateVehicle(int id, Map<String, dynamic> body) async {
    final res = await _api.patch('/admin/manager/vehicles/$id', body);
    return VehicleModel.fromJson(res['data'] ?? res);
  }

  Future<void> deleteVehicle(int id) => _api.delete('/admin/manager/vehicles/$id');

  Future<VehicleModel> activateVehicle(int id) async {
    final res = await _api.patch('/admin/manager/vehicles/$id/activate', {});
    return VehicleModel.fromJson(res['data'] ?? res);
  }

  Future<VehicleModel> deactivateVehicle(int id) async {
    final res = await _api.patch('/admin/manager/vehicles/$id/deactivate', {});
    return VehicleModel.fromJson(res['data'] ?? res);
  }
}

const _mockVehicles = [
  VehicleModel(id: 1, plateNo: 'أ ب ج 1234', type: 'bus', brand: 'Toyota',
      model: 'Coaster', year: 2021, status: 'on_trip',
      companyName: 'شركة النقل الحديث', companyId: 1,
      assignedDriverName: 'محمد عبدالله الغامدي'),
  VehicleModel(id: 2, plateNo: 'د هـ و 5678', type: 'van', brand: 'Ford',
      model: 'Transit', year: 2022, status: 'active',
      companyName: 'شركة النقل الحديث', companyId: 1,
      assignedDriverName: null),
  VehicleModel(id: 3, plateNo: 'ز ح ط 9012', type: 'bus', brand: 'Hyundai',
      model: 'County', year: 2020, status: 'on_trip',
      companyName: 'شركة الخليج للنقل', companyId: 2,
      assignedDriverName: 'فهد ناصر القحطاني'),
  VehicleModel(id: 4, plateNo: 'ي ك ل 3456', type: 'truck', brand: 'Mercedes',
      model: 'Sprinter', year: 2019, status: 'maintenance',
      companyName: 'شركة الخليج للنقل', companyId: 2,
      assignedDriverName: null),
  VehicleModel(id: 5, plateNo: 'م ن س 7890', type: 'car', brand: 'Nissan',
      model: 'Patrol', year: 2023, status: 'active',
      companyName: 'شركة الأمانة', companyId: 3,
      assignedDriverName: null),
  VehicleModel(id: 6, plateNo: 'ع ف ص 2345', type: 'van', brand: 'Toyota',
      model: 'Hiace', year: 2021, status: 'inactive',
      companyName: 'شركة الأمانة', companyId: 3,
      assignedDriverName: null),
];
