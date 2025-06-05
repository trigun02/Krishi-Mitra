// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import '../constants.dart';

// class PredictionResult {
//   final double minPrice;
//   final double maxPrice;
//   final double modalPrice;
  
//   PredictionResult({
//     required this.minPrice, 
//     required this.maxPrice, 
//     required this.modalPrice
//   });
  
//   factory PredictionResult.fromJson(Map<String, dynamic> json) {
//     return PredictionResult(
//       minPrice: json['min_price'].toDouble(),
//       maxPrice: json['max_price'].toDouble(),
//       modalPrice: json['modal_price'].toDouble(),
//     );
//   }
// }

// class PredictionProvider with ChangeNotifier {
//   PredictionResult? _predictionResult;
//   bool _isLoading = false;
//   String? _error;
  
//   PredictionResult? get predictionResult => _predictionResult;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
  
//   // Get predictions from API
//   Future<void> getPredictions(Map<String, dynamic> formData) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();
    
//     try {
//       final response = await http.post(
//         Uri.parse('${Constants.apiBaseUrl}/predict'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode(formData)
//       );
      
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         _predictionResult = PredictionResult.fromJson(data);
//         _error = null;
//       } else {
//         _error = 'Failed to get predictions. Server returned ${response.statusCode}';
//         _predictionResult = null;
//       }
//     } catch (e) {
//       print('Error getting predictions: $e');
//       _error = 'Failed to connect to server. Please check your internet connection.';
//       _predictionResult = null;
      
//       // For demo purposes when no backend is available
//       if (kDebugMode) {
//         _error = null;
//         _predictionResult = PredictionResult(
//           minPrice: 1200 + (formData['Month'] as int) * 10.5,
//           maxPrice: 1800 + (formData['Month'] as int) * 15.2,
//           modalPrice: 1500 + (formData['Month'] as int) * 12.8,
//         );
//       }
//     }
    
//     _isLoading = false;
//     notifyListeners();
//   }
  
//   void clearPredictions() {
//     _predictionResult = null;
//     _error = null;
//     notifyListeners();
//   }
// }
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../constants.dart';

class PredictionResult {
  final double minPrice;
  final double maxPrice;
  final double modalPrice;
  
  PredictionResult({
    required this.minPrice, 
    required this.maxPrice, 
    required this.modalPrice
  });
  
  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      minPrice: json['min_price'].toDouble(),
      maxPrice: json['max_price'].toDouble(),
      modalPrice: json['modal_price'].toDouble(),
    );
  }
}

class PredictionProvider with ChangeNotifier {
  PredictionResult? _predictionResult;
  bool _isLoading = false;
  String? _error;
  
  PredictionResult? get predictionResult => _predictionResult;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Get predictions from API
  Future<void> getPredictions(Map<String, dynamic> formData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      print('Sending prediction request to: ${Constants.apiBaseUrl}/predict');
      print('Request body: ${json.encode(formData)}');
      
      final response = await http.post(
        Uri.parse('${Constants.apiBaseUrl}/predict'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(formData)
      ).timeout(Duration(seconds: 30)); // Add timeout to avoid hanging
      
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _predictionResult = PredictionResult.fromJson(data);
        _error = null;
      } else {
        _error = 'Failed to get predictions. Server returned ${response.statusCode}. ${response.body}';
        _predictionResult = null;
      }
    } catch (e) {
      print('Error getting predictions: $e');
      _error = 'Failed to connect to server: $e. Please check your internet connection.';
      _predictionResult = null;
      
      // For demo purposes when no backend is available
      if (kDebugMode) {
        _error = null;
        _predictionResult = PredictionResult(
          minPrice: 1200 + (formData['Month'] as int) * 10.5,
          maxPrice: 1800 + (formData['Month'] as int) * 15.2,
          modalPrice: 1500 + (formData['Month'] as int) * 12.8,
        );
      }
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  void clearPredictions() {
    _predictionResult = null;
    _error = null;
    notifyListeners();
  }
}