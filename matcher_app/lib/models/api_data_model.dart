import 'package:subtil_app/services/api_service.dart';


class ApiResponse {
  final Map<int, String> genders;
  final Map<int, String> relationShip;
  final Map<String, dynamic> hobbies;


  ApiResponse({required this.genders, required this.relationShip, required this.hobbies});

  factory ApiResponse.fromJson(Map<int, String> genders, Map<int, String> relationShip, Map<String, dynamic> hobbies) {
    return ApiResponse(genders: genders, relationShip: relationShip, hobbies: hobbies);
  }
}

class ApiService {
  Future<ApiResponse?> fetchData() async {
    final hobbiesData = await fetchHobbiesAPI();
    final gendersData = await fetchGendersAPI();
    final relationShipData = await fetchRelationsAPI();

    print(hobbiesData);
    print(gendersData);
    print(relationShipData);

    if (hobbiesData.isNotEmpty && gendersData.isNotEmpty && relationShipData.isNotEmpty) {
      return ApiResponse.fromJson(gendersData, relationShipData, hobbiesData);
    }
    return null;
  }
}