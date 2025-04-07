import 'package:flutter/material.dart';
import 'package:subtil_app/models/api_data_model.dart';

class ApiProvider with ChangeNotifier {
  ApiResponse? _apiResponse;

  ApiResponse? get apiResponse => _apiResponse;

  Future<void> fetchApiData() async {
    print("###### hfzuoefzhiuzg ########");
    final apiService = ApiService();
    final apiResponse = await apiService.fetchData();
    _apiResponse = apiResponse;
    notifyListeners();
  }
}