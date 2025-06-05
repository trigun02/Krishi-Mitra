import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../constants.dart';

class DataProvider with ChangeNotifier {
  // Lists for dropdown options
  List<String> _states = [];
  List<String> _districts = [];
  List<String> _markets = [];
  List<String> _commodities = [];
  List<String> _varieties = [];
  List<String> _grades = [];
  
  // Selected values
  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedMarket;
  String? _selectedCommodity;
  String? _selectedVariety;
  String? _selectedGrade;
  DateTime _selectedDate = DateTime.now();
  
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  List<String> get states => _states;
  List<String> get districts => _districts;
  List<String> get markets => _markets;
  List<String> get commodities => _commodities;
  List<String> get varieties => _varieties;
  List<String> get grades => _grades;
  
  String? get selectedState => _selectedState;
  String? get selectedDistrict => _selectedDistrict;
  String? get selectedMarket => _selectedMarket;
  String? get selectedCommodity => _selectedCommodity;
  String? get selectedVariety => _selectedVariety;
  String? get selectedGrade => _selectedGrade;
  DateTime get selectedDate => _selectedDate;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Initialize data
  Future<void> initData() async {
    _setLoading(true);
    try {
      debugPrint('Initializing data provider with API base URL: ${Constants.apiBaseUrl}');
      
      // First check if the API is reachable with a health check
      try {
        final healthResponse = await http.get(
          Uri.parse('${Constants.apiBaseUrl}/health'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 10));
        
        if (healthResponse.statusCode == 200) {
          debugPrint('API health check successful');
          final healthData = json.decode(healthResponse.body);
          debugPrint('API health data: $healthData');
        } else {
          debugPrint('API health check failed with status: ${healthResponse.statusCode}');
        }
      } catch (e) {
        debugPrint('API health check exception: $e');
      }
      
      await Future.wait([
        fetchStates(),
        fetchCommodities(),
      ]);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to initialize data: $e';
      debugPrint(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }
  
  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // Fetch states from API or local data
  Future<void> fetchStates() async {
    try {
      debugPrint('Fetching states from: ${Constants.apiBaseUrl}/get_states');
      final response = await http.get(
        Uri.parse('${Constants.apiBaseUrl}/get_states'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15)); // Increased timeout
      
      debugPrint('States API response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        debugPrint('States API response body: ${response.body}');
        final data = json.decode(response.body);
        
        if (data.containsKey('states') && data['states'] is List && data['states'].isNotEmpty) {
          _states = List<String>.from(data['states']);
          debugPrint('Successfully loaded ${_states.length} states from API');
          notifyListeners();
          return; // Success, return early
        } else {
          debugPrint('API returned empty or invalid states data');
        }
      } else {
        debugPrint('Error fetching states: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
      
      // If we reach here, there was an issue with the API
      await _loadStatesFromAssets();
    } catch (e) {
      debugPrint('Exception fetching states: $e');
      // Use local data for testing
      await _loadStatesFromAssets();
    }
  }
  
  Future<void> _loadStatesFromAssets() async {
    debugPrint('Attempting to load states from assets');
    try {
      final jsonString = await rootBundle.loadString('assets/data/states.json');
      final List<dynamic> data = json.decode(jsonString);
      _states = List<String>.from(data);
      debugPrint('Successfully loaded ${_states.length} states from assets');
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load states from assets: $e');
      _loadDemoStates();
    }
  }
  
  void _loadDemoStates() {
    debugPrint('Loading demo states data');
    _states = ['Maharashtra', 'Karnataka', 'Tamil Nadu', 'Gujarat'];
    notifyListeners();
  }
  
  // Set selected state and fetch districts
  Future<void> setSelectedState(String state) async {
    debugPrint('Setting selected state to: $state');
    _selectedState = state;
    _selectedDistrict = null;
    _selectedMarket = null;
    _districts = [];
    _markets = [];
    notifyListeners();
    
    await fetchDistricts();
  }
  
  // Fetch districts for selected state
  Future<void> fetchDistricts() async {
    if (_selectedState == null) return;
    
    _setLoading(true);
    try {
      final apiUrl = '${Constants.apiBaseUrl}/get_districts?state=${Uri.encodeComponent(_selectedState!)}';
      debugPrint('Fetching districts from: $apiUrl');
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15)); // Increased timeout
      
      debugPrint('Districts API response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        debugPrint('Districts API response body: ${response.body}');
        final data = json.decode(response.body);
        
        if (data.containsKey('districts') && data['districts'] is List) {
          _districts = List<String>.from(data['districts']);
          debugPrint('Successfully loaded ${_districts.length} districts from API');
          notifyListeners();
          return; // Success, return early
        } else {
          debugPrint('API returned empty or invalid districts data');
        }
      } else {
        debugPrint('Error fetching districts: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
      
      // If we reach here, there was an issue with the API
      await _loadDistrictsFromAssets();
    } catch (e) {
      debugPrint('Exception fetching districts: $e');
      // Use local data
      await _loadDistrictsFromAssets();
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> _loadDistrictsFromAssets() async {
    if (_selectedState == null) return;
    
    debugPrint('Attempting to load districts from assets for state: $_selectedState');
    try {
      final jsonString = await rootBundle.loadString('assets/data/districts.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      
      if (data.containsKey(_selectedState)) {
        _districts = List<String>.from(data[_selectedState!]);
        debugPrint('Successfully loaded ${_districts.length} districts from assets');
      } else {
        debugPrint('Selected state not found in assets districts data');
        _districts = [];
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load districts from assets: $e');
      _loadDemoDistricts();
    }
  }
  
  void _loadDemoDistricts() {
    debugPrint('Loading demo districts data for state: $_selectedState');
    if (_selectedState == 'Maharashtra') {
      _districts = ['Pune', 'Mumbai', 'Nagpur'];
    } else if (_selectedState == 'Karnataka') {
      _districts = ['Bangalore', 'Mysore', 'Hubli'];
    } else {
      _districts = ['District 1', 'District 2', 'District 3'];
    }
    notifyListeners();
  }
  
  // Set selected district and fetch markets
  Future<void> setSelectedDistrict(String district) async {
    debugPrint('Setting selected district to: $district');
    _selectedDistrict = district;
    _selectedMarket = null;
    _markets = [];
    notifyListeners();
    
    await fetchMarkets();
  }
  
  // Fetch markets for selected district
  Future<void> fetchMarkets() async {
    if (_selectedState == null || _selectedDistrict == null) return;
    
    _setLoading(true);
    try {
      final apiUrl = '${Constants.apiBaseUrl}/get_markets?district=${Uri.encodeComponent(_selectedDistrict!)}';
      debugPrint('Fetching markets from: $apiUrl');
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15)); // Increased timeout
      
      debugPrint('Markets API response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        debugPrint('Markets API response body: ${response.body}');
        final data = json.decode(response.body);
        
        if (data.containsKey('markets') && data['markets'] is List) {
          _markets = List<String>.from(data['markets']);
          debugPrint('Successfully loaded ${_markets.length} markets from API');
          notifyListeners();
          return; // Success, return early
        } else {
          debugPrint('API returned empty or invalid markets data');
        }
      } else {
        debugPrint('Error fetching markets: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
      
      // If we reach here, there was an issue with the API
      await _loadMarketsFromAssets();
    } catch (e) {
      debugPrint('Exception fetching markets: $e');
      // Use local data
      await _loadMarketsFromAssets();
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> _loadMarketsFromAssets() async {
    if (_selectedDistrict == null) return;
    
    debugPrint('Attempting to load markets from assets for district: $_selectedDistrict');
    try {
      final jsonString = await rootBundle.loadString('assets/data/markets.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      
      if (data.containsKey(_selectedDistrict)) {
        _markets = List<String>.from(data[_selectedDistrict!]);
        debugPrint('Successfully loaded ${_markets.length} markets from assets');
      } else {
        debugPrint('Selected district not found in assets markets data');
        _markets = [];
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load markets from assets: $e');
      _loadDemoMarkets();
    }
  }
  
  void _loadDemoMarkets() {
    debugPrint('Loading demo markets data');
    _markets = ['Market 1', 'Market 2', 'Market 3'];
    notifyListeners();
  }
  
  // Set selected market
  void setSelectedMarket(String market) {
    debugPrint('Setting selected market to: $market');
    _selectedMarket = market;
    notifyListeners();
  }
  
  // Fetch commodities
  Future<void> fetchCommodities() async {
    try {
      debugPrint('Fetching commodities from: ${Constants.apiBaseUrl}/get_commodities');
      final response = await http.get(
        Uri.parse('${Constants.apiBaseUrl}/get_commodities'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15)); // Increased timeout
      
      debugPrint('Commodities API response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        debugPrint('Commodities API response body length: ${response.body.length}');
        // Only print first 200 chars to avoid log overflow
        debugPrint('Commodities API response body preview: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
        
        final data = json.decode(response.body);
        
        if (data.containsKey('commodities') && data['commodities'] is List && data['commodities'].isNotEmpty) {
          _commodities = List<String>.from(data['commodities']);
          debugPrint('Successfully loaded ${_commodities.length} commodities from API');
          notifyListeners();
          return; // Success, return early
        } else {
          debugPrint('API returned empty or invalid commodities data');
        }
      } else {
        debugPrint('Error fetching commodities: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
      
      // If we reach here, there was an issue with the API
      await _loadCommoditiesFromAssets();
    } catch (e) {
      debugPrint('Exception fetching commodities: $e');
      // Use local data
      await _loadCommoditiesFromAssets();
    }
  }
  
  Future<void> _loadCommoditiesFromAssets() async {
    debugPrint('Attempting to load commodities from assets');
    try {
      final jsonString = await rootBundle.loadString('assets/data/commodities.json');
      final List<dynamic> data = json.decode(jsonString);
      _commodities = List<String>.from(data);
      debugPrint('Successfully loaded ${_commodities.length} commodities from assets');
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load commodities from assets: $e');
      _loadDemoCommodities();
    }
  }
  
  void _loadDemoCommodities() {
    debugPrint('Loading demo commodities data');
    _commodities = ['Rice', 'Wheat', 'Tomato', 'Potato', 'Onion'];
    notifyListeners();
  }
  
  // Set selected commodity and fetch varieties
  Future<void> setSelectedCommodity(String commodity) async {
    debugPrint('Setting selected commodity to: $commodity');
    _selectedCommodity = commodity;
    _selectedVariety = null;
    _selectedGrade = null;
    _varieties = [];
    _grades = [];
    notifyListeners();
    
    await fetchVarieties();
  }
  
  // Fetch varieties for selected commodity
  Future<void> fetchVarieties() async {
    if (_selectedCommodity == null) return;
    
    _setLoading(true);
    try {
      final apiUrl = '${Constants.apiBaseUrl}/get_varieties?commodity=${Uri.encodeComponent(_selectedCommodity!)}';
      debugPrint('Fetching varieties from: $apiUrl');
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15)); // Increased timeout
      
      debugPrint('Varieties API response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        debugPrint('Varieties API response body: ${response.body}');
        final data = json.decode(response.body);
        
        if (data.containsKey('varieties') && data['varieties'] is List) {
          _varieties = List<String>.from(data['varieties']);
          debugPrint('Successfully loaded ${_varieties.length} varieties from API');
          notifyListeners();
          return; // Success, return early
        } else {
          debugPrint('API returned empty or invalid varieties data');
        }
      } else {
        debugPrint('Error fetching varieties: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
      
      // If we reach here, there was an issue with the API
      await _loadVarietiesFromAssets();
    } catch (e) {
      debugPrint('Exception fetching varieties: $e');
      // Use local data
      await _loadVarietiesFromAssets();
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> _loadVarietiesFromAssets() async {
    if (_selectedCommodity == null) return;
    
    debugPrint('Attempting to load varieties from assets for commodity: $_selectedCommodity');
    try {
      final jsonString = await rootBundle.loadString('assets/data/varieties.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      
      if (data.containsKey(_selectedCommodity)) {
        _varieties = List<String>.from(data[_selectedCommodity!]);
        debugPrint('Successfully loaded ${_varieties.length} varieties from assets');
      } else {
        debugPrint('Selected commodity not found in assets varieties data');
        _varieties = [];
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load varieties from assets: $e');
      _loadDemoVarieties();
    }
  }
  
  void _loadDemoVarieties() {
    debugPrint('Loading demo varieties data');
    _varieties = ['Local', 'Hybrid', 'Imported'];
    notifyListeners();
  }
  
  // Set selected variety and fetch grades
  Future<void> setSelectedVariety(String variety) async {
    debugPrint('Setting selected variety to: $variety');
    _selectedVariety = variety;
    _selectedGrade = null;
    _grades = [];
    notifyListeners();
    
    await fetchGrades();
  }
  
  // Fetch grades for selected variety
  Future<void> fetchGrades() async {
    if (_selectedCommodity == null || _selectedVariety == null) return;
    
    _setLoading(true);
    try {
      final apiUrl = '${Constants.apiBaseUrl}/get_grades?variety=${Uri.encodeComponent(_selectedVariety!)}';
      debugPrint('Fetching grades from: $apiUrl');
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15)); // Increased timeout
      
      debugPrint('Grades API response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        debugPrint('Grades API response body: ${response.body}');
        final data = json.decode(response.body);
        
        if (data.containsKey('grades') && data['grades'] is List) {
          _grades = List<String>.from(data['grades']);
          debugPrint('Successfully loaded ${_grades.length} grades from API');
          notifyListeners();
          return; // Success, return early
        } else {
          debugPrint('API returned empty or invalid grades data');
        }
      } else {
        debugPrint('Error fetching grades: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
      
      // If we reach here, there was an issue with the API
      await _loadGradesFromAssets();
    } catch (e) {
      debugPrint('Exception fetching grades: $e');
      // Use local data
      await _loadGradesFromAssets();
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> _loadGradesFromAssets() async {
    if (_selectedVariety == null) return;
    
    debugPrint('Attempting to load grades from assets for variety: $_selectedVariety');
    try {
      final jsonString = await rootBundle.loadString('assets/data/grades.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      
      if (data.containsKey(_selectedVariety)) {
        _grades = List<String>.from(data[_selectedVariety!]);
        debugPrint('Successfully loaded ${_grades.length} grades from assets');
      } else {
        debugPrint('Selected variety not found in assets grades data');
        _grades = [];
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load grades from assets: $e');
      _loadDemoGrades();
    }
  }
  
  void _loadDemoGrades() {
    debugPrint('Loading demo grades data');
    _grades = ['A', 'B', 'C'];
    notifyListeners();
  }
  
  // Set selected grade
  void setSelectedGrade(String grade) {
    debugPrint('Setting selected grade to: $grade');
    _selectedGrade = grade;
    notifyListeners();
  }
  
  // Set selected date
  void setSelectedDate(DateTime date) {
    debugPrint('Setting selected date to: $date');
    _selectedDate = date;
    notifyListeners();
  }
  
  // Check if all fields are selected
  bool get isFormComplete {
    return _selectedState != null && 
           _selectedDistrict != null && 
           _selectedMarket != null && 
           _selectedCommodity != null && 
           _selectedVariety != null && 
           _selectedGrade != null;
  }
  
  // Get form data as Map
  Map<String, dynamic> getFormData() {
    final formData = {
      'State': _selectedState,
      'District': _selectedDistrict,
      'Market': _selectedMarket,
      'Commodity': _selectedCommodity,
      'Variety': _selectedVariety,
      'Grade': _selectedGrade,
      'Year': _selectedDate.year,
      'Month': _selectedDate.month,
      'Day': _selectedDate.day
    };
    debugPrint('Form data: $formData');
    return formData;
  }
  
  // Reset form
  void resetForm() {
    debugPrint('Resetting form');
    _selectedState = null;
    _selectedDistrict = null;
    _selectedMarket = null;
    _selectedCommodity = null;
    _selectedVariety = null;
    _selectedGrade = null;
    _selectedDate = DateTime.now();
    _districts = [];
    _markets = [];
    _varieties = [];
    _grades = [];
    notifyListeners();
  }
}


















// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter/services.dart' show rootBundle;

// import '../constants.dart';

// class DataProvider with ChangeNotifier {
//   // Lists for dropdown options
//   List<String> _states = [];
//   List<String> _districts = [];
//   List<String> _markets = [];
//   List<String> _commodities = [];
//   List<String> _varieties = [];
//   List<String> _grades = [];
  
//   // Selected values
//   String? _selectedState;
//   String? _selectedDistrict;
//   String? _selectedMarket;
//   String? _selectedCommodity;
//   String? _selectedVariety;
//   String? _selectedGrade;
//   DateTime _selectedDate = DateTime.now();
  
//   bool _isLoading = false;
//   String? _errorMessage;
  
//   // Getters
//   List<String> get states => _states;
//   List<String> get districts => _districts;
//   List<String> get markets => _markets;
//   List<String> get commodities => _commodities;
//   List<String> get varieties => _varieties;
//   List<String> get grades => _grades;
  
//   String? get selectedState => _selectedState;
//   String? get selectedDistrict => _selectedDistrict;
//   String? get selectedMarket => _selectedMarket;
//   String? get selectedCommodity => _selectedCommodity;
//   String? get selectedVariety => _selectedVariety;
//   String? get selectedGrade => _selectedGrade;
//   DateTime get selectedDate => _selectedDate;
  
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;
  
//   // Initialize data
//   Future<void> initData() async {
//     _setLoading(true);
//     try {
//       await Future.wait([
//         fetchStates(),
//         fetchCommodities(),
//       ]);
//       _errorMessage = null;
//     } catch (e) {
//       _errorMessage = 'Failed to initialize data: $e';
//       debugPrint(_errorMessage);
//     } finally {
//       _setLoading(false);
//     }
//   }
  
//   // Helper method to set loading state
//   void _setLoading(bool loading) {
//     _isLoading = loading;
//     notifyListeners();
//   }
  
//   // Fetch states from API or local data
//   Future<void> fetchStates() async {
//     try {
//       final response = await http.get(
//         Uri.parse('${Constants.apiBaseUrl}/get_states'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       ).timeout(const Duration(seconds: 10));
      
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         _states = List<String>.from(data['states']);
//         notifyListeners();
//       } else {
//         debugPrint('Error fetching states: ${response.statusCode}');
//         debugPrint('Response body: ${response.body}');
//         // Use local data if API fails
//         await _loadStatesFromAssets();
//       }
//     } catch (e) {
//       debugPrint('Exception fetching states: $e');
//       // Use local data for testing
//       await _loadStatesFromAssets();
//     }
//   }
  
//   Future<void> _loadStatesFromAssets() async {
//     try {
//       final jsonString = await rootBundle.loadString('assets/data/states.json');
//       final List<dynamic> data = json.decode(jsonString);
//       _states = List<String>.from(data);
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Failed to load states from assets: $e');
//       _loadDemoStates();
//     }
//   }
  
//   void _loadDemoStates() {
//     _states = ['Maharashtra', 'Karnataka', 'Tamil Nadu', 'Gujarat'];
//     notifyListeners();
//   }
  
//   // Set selected state and fetch districts
//   Future<void> setSelectedState(String state) async {
//     _selectedState = state;
//     _selectedDistrict = null;
//     _selectedMarket = null;
//     _districts = [];
//     _markets = [];
//     notifyListeners();
    
//     await fetchDistricts();
//   }
  
//   // Fetch districts for selected state
//   Future<void> fetchDistricts() async {
//     if (_selectedState == null) return;
    
//     _setLoading(true);
//     try {
//       final response = await http.get(
//         Uri.parse('${Constants.apiBaseUrl}/get_districts?state=${Uri.encodeComponent(_selectedState!)}'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       ).timeout(const Duration(seconds: 10));
      
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         _districts = List<String>.from(data['districts']);
//         notifyListeners();
//       } else {
//         debugPrint('Error fetching districts: ${response.statusCode}');
//         debugPrint('Response body: ${response.body}');
//         // Use local data if API fails
//         await _loadDistrictsFromAssets();
//       }
//     } catch (e) {
//       debugPrint('Exception fetching districts: $e');
//       // Use local data
//       await _loadDistrictsFromAssets();
//     } finally {
//       _setLoading(false);
//     }
//   }
  
//   Future<void> _loadDistrictsFromAssets() async {
//     if (_selectedState == null) return;
    
//     try {
//       final jsonString = await rootBundle.loadString('assets/data/districts.json');
//       final Map<String, dynamic> data = json.decode(jsonString);
      
//       if (data.containsKey(_selectedState)) {
//         _districts = List<String>.from(data[_selectedState!]);
//       } else {
//         _districts = [];
//       }
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Failed to load districts from assets: $e');
//       _loadDemoDistricts();
//     }
//   }
  
//   void _loadDemoDistricts() {
//     if (_selectedState == 'Maharashtra') {
//       _districts = ['Pune', 'Mumbai', 'Nagpur'];
//     } else if (_selectedState == 'Karnataka') {
//       _districts = ['Bangalore', 'Mysore', 'Hubli'];
//     } else {
//       _districts = ['District 1', 'District 2', 'District 3'];
//     }
//     notifyListeners();
//   }
  
//   // Set selected district and fetch markets
//   Future<void> setSelectedDistrict(String district) async {
//     _selectedDistrict = district;
//     _selectedMarket = null;
//     _markets = [];
//     notifyListeners();
    
//     await fetchMarkets();
//   }
  
//   // Fetch markets for selected district
//   Future<void> fetchMarkets() async {
//     if (_selectedState == null || _selectedDistrict == null) return;
    
//     _setLoading(true);
//     try {
//       final response = await http.get(
//         Uri.parse('${Constants.apiBaseUrl}/get_markets?district=${Uri.encodeComponent(_selectedDistrict!)}'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       ).timeout(const Duration(seconds: 10));
      
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         _markets = List<String>.from(data['markets']);
//         notifyListeners();
//       } else {
//         debugPrint('Error fetching markets: ${response.statusCode}');
//         debugPrint('Response body: ${response.body}');
//         // Use local data if API fails
//         await _loadMarketsFromAssets();
//       }
//     } catch (e) {
//       debugPrint('Exception fetching markets: $e');
//       // Use local data
//       await _loadMarketsFromAssets();
//     } finally {
//       _setLoading(false);
//     }
//   }
  
//   Future<void> _loadMarketsFromAssets() async {
//     if (_selectedDistrict == null) return;
    
//     try {
//       final jsonString = await rootBundle.loadString('assets/data/markets.json');
//       final Map<String, dynamic> data = json.decode(jsonString);
      
//       if (data.containsKey(_selectedDistrict)) {
//         _markets = List<String>.from(data[_selectedDistrict!]);
//       } else {
//         _markets = [];
//       }
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Failed to load markets from assets: $e');
//       _loadDemoMarkets();
//     }
//   }
  
//   void _loadDemoMarkets() {
//     _markets = ['Market 1', 'Market 2', 'Market 3'];
//     notifyListeners();
//   }
  
//   // Set selected market
//   void setSelectedMarket(String market) {
//     _selectedMarket = market;
//     notifyListeners();
//   }
  
//   // Fetch commodities
//   Future<void> fetchCommodities() async {
//     try {
//       final response = await http.get(
//         Uri.parse('${Constants.apiBaseUrl}/get_commodities'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       ).timeout(const Duration(seconds: 10));
      
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         _commodities = List<String>.from(data['commodities']);
//         notifyListeners();
//       } else {
//         debugPrint('Error fetching commodities: ${response.statusCode}');
//         debugPrint('Response body: ${response.body}');
//         // Use local data if API fails
//         await _loadCommoditiesFromAssets();
//       }
//     } catch (e) {
//       debugPrint('Exception fetching commodities: $e');
//       // Use local data
//       await _loadCommoditiesFromAssets();
//     }
//   }
  
//   Future<void> _loadCommoditiesFromAssets() async {
//     try {
//       final jsonString = await rootBundle.loadString('assets/data/commodities.json');
//       final List<dynamic> data = json.decode(jsonString);
//       _commodities = List<String>.from(data);
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Failed to load commodities from assets: $e');
//       _loadDemoCommodities();
//     }
//   }
  
//   void _loadDemoCommodities() {
//     _commodities = ['Rice', 'Wheat', 'Tomato', 'Potato', 'Onion'];
//     notifyListeners();
//   }
  
//   // Set selected commodity and fetch varieties
//   Future<void> setSelectedCommodity(String commodity) async {
//     _selectedCommodity = commodity;
//     _selectedVariety = null;
//     _selectedGrade = null;
//     _varieties = [];
//     _grades = [];
//     notifyListeners();
    
//     await fetchVarieties();
//   }
  
//   // Fetch varieties for selected commodity
//   Future<void> fetchVarieties() async {
//     if (_selectedCommodity == null) return;
    
//     _setLoading(true);
//     try {
//       final response = await http.get(
//         Uri.parse('${Constants.apiBaseUrl}/get_varieties?commodity=${Uri.encodeComponent(_selectedCommodity!)}'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       ).timeout(const Duration(seconds: 10));
      
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         _varieties = List<String>.from(data['varieties']);
//         notifyListeners();
//       } else {
//         debugPrint('Error fetching varieties: ${response.statusCode}');
//         debugPrint('Response body: ${response.body}');
//         // Use local data if API fails
//         await _loadVarietiesFromAssets();
//       }
//     } catch (e) {
//       debugPrint('Exception fetching varieties: $e');
//       // Use local data
//       await _loadVarietiesFromAssets();
//     } finally {
//       _setLoading(false);
//     }
//   }
  
//   Future<void> _loadVarietiesFromAssets() async {
//     if (_selectedCommodity == null) return;
    
//     try {
//       final jsonString = await rootBundle.loadString('assets/data/varieties.json');
//       final Map<String, dynamic> data = json.decode(jsonString);
      
//       if (data.containsKey(_selectedCommodity)) {
//         _varieties = List<String>.from(data[_selectedCommodity!]);
//       } else {
//         _varieties = [];
//       }
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Failed to load varieties from assets: $e');
//       _loadDemoVarieties();
//     }
//   }
  
//   void _loadDemoVarieties() {
//     _varieties = ['Local', 'Hybrid', 'Imported'];
//     notifyListeners();
//   }
  
//   // Set selected variety and fetch grades
//   Future<void> setSelectedVariety(String variety) async {
//     _selectedVariety = variety;
//     _selectedGrade = null;
//     _grades = [];
//     notifyListeners();
    
//     await fetchGrades();
//   }
  
//   // Fetch grades for selected variety
//   Future<void> fetchGrades() async {
//     if (_selectedCommodity == null || _selectedVariety == null) return;
    
//     _setLoading(true);
//     try {
//       final response = await http.get(
//         Uri.parse('${Constants.apiBaseUrl}/get_grades?variety=${Uri.encodeComponent(_selectedVariety!)}'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       ).timeout(const Duration(seconds: 10));
      
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         _grades = List<String>.from(data['grades']);
//         notifyListeners();
//       } else {
//         debugPrint('Error fetching grades: ${response.statusCode}');
//         debugPrint('Response body: ${response.body}');
//         // Use local data if API fails
//         await _loadGradesFromAssets();
//       }
//     } catch (e) {
//       debugPrint('Exception fetching grades: $e');
//       // Use local data
//       await _loadGradesFromAssets();
//     } finally {
//       _setLoading(false);
//     }
//   }
  
//   Future<void> _loadGradesFromAssets() async {
//     if (_selectedVariety == null) return;
    
//     try {
//       final jsonString = await rootBundle.loadString('assets/data/grades.json');
//       final Map<String, dynamic> data = json.decode(jsonString);
      
//       if (data.containsKey(_selectedVariety)) {
//         _grades = List<String>.from(data[_selectedVariety!]);
//       } else {
//         _grades = [];
//       }
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Failed to load grades from assets: $e');
//       _loadDemoGrades();
//     }
//   }
  
//   void _loadDemoGrades() {
//     _grades = ['A', 'B', 'C'];
//     notifyListeners();
//   }
  
//   // Set selected grade
//   void setSelectedGrade(String grade) {
//     _selectedGrade = grade;
//     notifyListeners();
//   }
  
//   // Set selected date
//   void setSelectedDate(DateTime date) {
//     _selectedDate = date;
//     notifyListeners();
//   }
  
//   // Check if all fields are selected
//   bool get isFormComplete {
//     return _selectedState != null && 
//            _selectedDistrict != null && 
//            _selectedMarket != null && 
//            _selectedCommodity != null && 
//            _selectedVariety != null && 
//            _selectedGrade != null;
//   }
  
//   // Get form data as Map
//   Map<String, dynamic> getFormData() {
//     return {
//       'State': _selectedState,
//       'District': _selectedDistrict,
//       'Market': _selectedMarket,
//       'Commodity': _selectedCommodity,
//       'Variety': _selectedVariety,
//       'Grade': _selectedGrade,
//       'Year': _selectedDate.year,
//       'Month': _selectedDate.month,
//       'Day': _selectedDate.day
//     };
//   }
  
//   // Reset form
//   void resetForm() {
//     _selectedState = null;
//     _selectedDistrict = null;
//     _selectedMarket = null;
//     _selectedCommodity = null;
//     _selectedVariety = null;
//     _selectedGrade = null;
//     _selectedDate = DateTime.now();
//     _districts = [];
//     _markets = [];
//     _varieties = [];
//     _grades = [];
//     notifyListeners();
//   }
// }










// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import '../constants.dart';

// class DataProvider with ChangeNotifier {
//   // Lists for dropdown options
//   List<String> _states = [];
//   List<String> _districts = [];
//   List<String> _markets = [];
//   List<String> _commodities = [];
//   List<String> _varieties = [];
//   List<String> _grades = [];
  
//   // Selected values
//   String? _selectedState;
//   String? _selectedDistrict;
//   String? _selectedMarket;
//   String? _selectedCommodity;
//   String? _selectedVariety;
//   String? _selectedGrade;
//   DateTime _selectedDate = DateTime.now();
  
//   // Getters
//   List<String> get states => _states;
//   List<String> get districts => _districts;
//   List<String> get markets => _markets;
//   List<String> get commodities => _commodities;
//   List<String> get varieties => _varieties;
//   List<String> get grades => _grades;
  
//   String? get selectedState => _selectedState;
//   String? get selectedDistrict => _selectedDistrict;
//   String? get selectedMarket => _selectedMarket;
//   String? get selectedCommodity => _selectedCommodity;
//   String? get selectedVariety => _selectedVariety;
//   String? get selectedGrade => _selectedGrade;
//   DateTime get selectedDate => _selectedDate;
  
//   // Initialize data
//   Future<void> initData() async {
//     await fetchStates();
//     await fetchCommodities();
//   }
  
//   // Fetch states from API
//   Future<void> fetchStates() async {
//     try {
//       final response = await http.get(
//         Uri.parse('${Constants.apiBaseUrl}/get_states'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       );
      
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         _states = List<String>.from(data['states']);
//         notifyListeners();
//       } else {
//         print('Error fetching states: ${response.statusCode}');
//         print('Response body: ${response.body}');
//         // Use demo data for testing if API fails
//         _loadDemoStates();
//       }
//     } catch (e) {
//       print('Exception fetching states: $e');
//       // Use demo data for testing
//       _loadDemoStates();
//     }
//   }
  
//   void _loadDemoStates() {
//     _states = ['Maharashtra', 'Karnataka', 'Tamil Nadu', 'Gujarat'];
//     notifyListeners();
//   }
  
//   // Set selected state and fetch districts
//   Future<void> setSelectedState(String state) async {
//     _selectedState = state;
//     _selectedDistrict = null;
//     _selectedMarket = null;
//     _districts = [];
//     _markets = [];
//     notifyListeners();
    
//     await fetchDistricts();
//   }
  
//   // Fetch districts for selected state
//   Future<void> fetchDistricts() async {
//     if (_selectedState == null) return;
    
//     try {
//       final response = await http.get(
//         Uri.parse('${Constants.apiBaseUrl}/get_districts?state=${Uri.encodeComponent(_selectedState!)}'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       );
      
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         _districts = List<String>.from(data['districts']);
//         notifyListeners();
//       } else {
//         print('Error fetching districts: ${response.statusCode}');
//         print('Response body: ${response.body}');
//         // Use demo data for testing if API fails
//         _loadDemoDistricts();
//       }
//     } catch (e) {
//       print('Exception fetching districts: $e');
//       // Use demo data for testing
//       _loadDemoDistricts();
//     }
//   }
  
//   void _loadDemoDistricts() {
//     if (_selectedState == 'Maharashtra') {
//       _districts = ['Pune', 'Mumbai', 'Nagpur'];
//     } else if (_selectedState == 'Karnataka') {
//       _districts = ['Bangalore', 'Mysore', 'Hubli'];
//     } else {
//       _districts = ['District 1', 'District 2', 'District 3'];
//     }
//     notifyListeners();
//   }
  
//   // Set selected district and fetch markets
//   Future<void> setSelectedDistrict(String district) async {
//     _selectedDistrict = district;
//     _selectedMarket = null;
//     _markets = [];
//     notifyListeners();
    
//     await fetchMarkets();
//   }
  
//   // Fetch markets for selected district
//   Future<void> fetchMarkets() async {
//     if (_selectedState == null || _selectedDistrict == null) return;
    
//     try {
//       final response = await http.get(
//         Uri.parse('${Constants.apiBaseUrl}/get_markets?district=${Uri.encodeComponent(_selectedDistrict!)}'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       );
      
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         _markets = List<String>.from(data['markets']);
//         notifyListeners();
//       } else {
//         print('Error fetching markets: ${response.statusCode}');
//         print('Response body: ${response.body}');
//         // Use demo data for testing if API fails
//         _loadDemoMarkets();
//       }
//     } catch (e) {
//       print('Exception fetching markets: $e');
//       // Use demo data for testing
//       _loadDemoMarkets();
//     }
//   }
  
//   void _loadDemoMarkets() {
//     _markets = ['Market 1', 'Market 2', 'Market 3'];
//     notifyListeners();
//   }
  
//   // Set selected market
//   void setSelectedMarket(String market) {
//     _selectedMarket = market;
//     notifyListeners();
//   }
  
//   // Fetch commodities
//   Future<void> fetchCommodities() async {
//     try {
//       final response = await http.get(
//         Uri.parse('${Constants.apiBaseUrl}/get_commodities'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       );
      
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         _commodities = List<String>.from(data['commodities']);
//         notifyListeners();
//       } else {
//         print('Error fetching commodities: ${response.statusCode}');
//         print('Response body: ${response.body}');
//         // Use demo data for testing if API fails
//         _loadDemoCommodities();
//       }
//     } catch (e) {
//       print('Exception fetching commodities: $e');
//       // Use demo data for testing
//       _loadDemoCommodities();
//     }
//   }
  
//   void _loadDemoCommodities() {
//     _commodities = ['Rice', 'Wheat', 'Tomato', 'Potato', 'Onion'];
//     notifyListeners();
//   }
  
//   // Set selected commodity and fetch varieties
//   Future<void> setSelectedCommodity(String commodity) async {
//     _selectedCommodity = commodity;
//     _selectedVariety = null;
//     _selectedGrade = null;
//     _varieties = [];
//     _grades = [];
//     notifyListeners();
    
//     await fetchVarieties();
//   }
  
//   // Fetch varieties for selected commodity
//   Future<void> fetchVarieties() async {
//     if (_selectedCommodity == null) return;
    
//     try {
//       final response = await http.get(
//         Uri.parse('${Constants.apiBaseUrl}/get_varieties?commodity=${Uri.encodeComponent(_selectedCommodity!)}'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       );
      
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         _varieties = List<String>.from(data['varieties']);
//         notifyListeners();
//       } else {
//         print('Error fetching varieties: ${response.statusCode}');
//         print('Response body: ${response.body}');
//         // Use demo data for testing if API fails
//         _loadDemoVarieties();
//       }
//     } catch (e) {
//       print('Exception fetching varieties: $e');
//       // Use demo data for testing
//       _loadDemoVarieties();
//     }
//   }
  
//   void _loadDemoVarieties() {
//     _varieties = ['Local', 'Hybrid', 'Imported'];
//     notifyListeners();
//   }
  
//   // Set selected variety and fetch grades
//   Future<void> setSelectedVariety(String variety) async {
//     _selectedVariety = variety;
//     _selectedGrade = null;
//     _grades = [];
//     notifyListeners();
    
//     await fetchGrades();
//   }
  
//   // Fetch grades for selected variety
//   Future<void> fetchGrades() async {
//     if (_selectedCommodity == null || _selectedVariety == null) return;
    
//     try {
//       final response = await http.get(
//         Uri.parse('${Constants.apiBaseUrl}/get_grades?variety=${Uri.encodeComponent(_selectedVariety!)}'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       );
      
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         _grades = List<String>.from(data['grades']);
//         notifyListeners();
//       } else {
//         print('Error fetching grades: ${response.statusCode}');
//         print('Response body: ${response.body}');
//         // Use demo data for testing if API fails
//         _loadDemoGrades();
//       }
//     } catch (e) {
//       print('Exception fetching grades: $e');
//       // Use demo data for testing
//       _loadDemoGrades();
//     }
//   }
  
//   void _loadDemoGrades() {
//     _grades = ['A', 'B', 'C'];
//     notifyListeners();
//   }
  
//   // Set selected grade
//   void setSelectedGrade(String grade) {
//     _selectedGrade = grade;
//     notifyListeners();
//   }
  
//   // Set selected date
//   void setSelectedDate(DateTime date) {
//     _selectedDate = date;
//     notifyListeners();
//   }
  
//   // Check if all fields are selected
//   bool get isFormComplete {
//     return _selectedState != null && 
//            _selectedDistrict != null && 
//            _selectedMarket != null && 
//            _selectedCommodity != null && 
//            _selectedVariety != null && 
//            _selectedGrade != null;
//   }
  
//   // Get form data as Map
//   Map<String, dynamic> getFormData() {
//     return {
//       'State': _selectedState,
//       'District': _selectedDistrict,
//       'Market': _selectedMarket,
//       'Commodity': _selectedCommodity,
//       'Variety': _selectedVariety,
//       'Grade': _selectedGrade,
//       'Year': _selectedDate.year,
//       'Month': _selectedDate.month,
//       'Day': _selectedDate.day
//     };
//   }
  
//   // Reset form
//   void resetForm() {
//     _selectedState = null;
//     _selectedDistrict = null;
//     _selectedMarket = null;
//     _selectedCommodity = null;
//     _selectedVariety = null;
//     _selectedGrade = null;
//     _selectedDate = DateTime.now();
//     _districts = [];
//     _markets = [];
//     _varieties = [];
//     _grades = [];
//     notifyListeners();
//   }
// }
































// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import '../constants.dart';

// class DataProvider with ChangeNotifier {
//   // Lists for dropdown options
//   List<String> _states = [];
//   List<String> _districts = [];
//   List<String> _markets = [];
//   List<String> _commodities = [];
//   List<String> _varieties = [];
//   List<String> _grades = [];
  
//   // Selected values
//   String? _selectedState;
//   String? _selectedDistrict;
//   String? _selectedMarket;
//   String? _selectedCommodity;
//   String? _selectedVariety;
//   String? _selectedGrade;
//   DateTime _selectedDate = DateTime.now();
  
//   // Getters
//   List<String> get states => _states;
//   List<String> get districts => _districts;
//   List<String> get markets => _markets;
//   List<String> get commodities => _commodities;
//   List<String> get varieties => _varieties;
//   List<String> get grades => _grades;
  
//   String? get selectedState => _selectedState;
//   String? get selectedDistrict => _selectedDistrict;
//   String? get selectedMarket => _selectedMarket;
//   String? get selectedCommodity => _selectedCommodity;
//   String? get selectedVariety => _selectedVariety;
//   String? get selectedGrade => _selectedGrade;
//   DateTime get selectedDate => _selectedDate;
  
//   // Initialize data
//   Future<void> initData() async {
//     await fetchStates();
//     await fetchCommodities();
//   }
  
//   // Fetch states from API
//   Future<void> fetchStates() async {
//     try {
//       final response = await http.get(Uri.parse('${Constants.apiBaseUrl}/get_states'));
      
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         _states = List<String>.from(data['states']);
//         notifyListeners();
//       } else {
//         print('Failed to fetch states. Status code: ${response.statusCode}');
//         // Use demo data for testing
//         _states = ['Maharashtra', 'Karnataka', 'Tamil Nadu', 'Gujarat'];
//         notifyListeners();
//       }
//     } catch (e) {
//       print('Error fetching states: $e');
//       // Use demo data for testing
//       _states = ['Maharashtra', 'Karnataka', 'Tamil Nadu', 'Gujarat'];
//       notifyListeners();
//     }
//   }
//   // Fetch states from API
//   // Future<void> fetchStates() async {
//   //   try {
//   //     final response = await http.get(Uri.parse('${Constants.apiBaseUrl}/get_states'));
      
//   //     if (response.statusCode == 200) {
//   //       final data = json.decode(response.body);
//   //       _states = List<String>.from(data['states']);
//   //       notifyListeners();
//   //     }
//   //   } catch (e) {
//   //     print('Error fetching states: $e');
//   //     // Use demo data for testing
//   //     _states = ['Maharashtra', 'Karnataka', 'Tamil Nadu', 'Gujarat'];
//   //     notifyListeners();
//   //   }
//   // }
  
//   // Set selected state and fetch districts
//   Future<void> setSelectedState(String state) async {
//     _selectedState = state;
//     _selectedDistrict = null;
//     _selectedMarket = null;
//     _districts = [];
//     _markets = [];
//     notifyListeners();
    
//     await fetchDistricts();
//   }
  
//   // Fetch districts for selected state
//   Future<void> fetchDistricts() async {
//     if (_selectedState == null) return;
    
//     try {
//       final response = await http.get(
//         Uri.parse('${Constants.apiBaseUrl}/get_districts?state=$_selectedState')
//       );
      
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         _districts = List<String>.from(data['districts']);
//         notifyListeners();
//       }
//     } catch (e) {
//       print('Error fetching districts: $e');
//       // Use demo data for testing
//       if (_selectedState == 'Maharashtra') {
//         _districts = ['Pune', 'Mumbai', 'Nagpur'];
//       } else if (_selectedState == 'Karnataka') {
//         _districts = ['Bangalore', 'Mysore', 'Hubli'];
//       } else {
//         _districts = ['District 1', 'District 2', 'District 3'];
//       }
//       notifyListeners();
//     }
//   }
  
//   // Set selected district and fetch markets
//   Future<void> setSelectedDistrict(String district) async {
//     _selectedDistrict = district;
//     _selectedMarket = null;
//     _markets = [];
//     notifyListeners();
    
//     await fetchMarkets();
//   }
  
//   // Fetch markets for selected district
//   Future<void> fetchMarkets() async {
//     if (_selectedState == null || _selectedDistrict == null) return;
    
//     try {
//       final response = await http.get(
//         Uri.parse('${Constants.apiBaseUrl}/get_markets?state=$_selectedState&district=$_selectedDistrict')
//       );
      
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         _markets = List<String>.from(data['markets']);
//         notifyListeners();
//       }
//     } catch (e) {
//       print('Error fetching markets: $e');
//       // Use demo data for testing
//       _markets = ['Market 1', 'Market 2', 'Market 3'];
//       notifyListeners();
//     }
//   }
  
//   // Set selected market
//   void setSelectedMarket(String market) {
//     _selectedMarket = market;
//     notifyListeners();
//   }
  
//   // Fetch commodities
//   Future<void> fetchCommodities() async {
//     try {
//       final response = await http.get(Uri.parse('${Constants.apiBaseUrl}/get_commodities'));
      
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         _commodities = List<String>.from(data['commodities']);
//         notifyListeners();
//       }
//     } catch (e) {
//       print('Error fetching commodities: $e');
//       // Use demo data for testing
//       _commodities = ['Rice', 'Wheat', 'Tomato', 'Potato', 'Onion'];
//       notifyListeners();
//     }
//   }
  
//   // Set selected commodity and fetch varieties
//   Future<void> setSelectedCommodity(String commodity) async {
//     _selectedCommodity = commodity;
//     _selectedVariety = null;
//     _selectedGrade = null;
//     _varieties = [];
//     _grades = [];
//     notifyListeners();
    
//     await fetchVarieties();
//   }
  
//   // Fetch varieties for selected commodity
//   Future<void> fetchVarieties() async {
//     if (_selectedCommodity == null) return;
    
//     try {
//       final response = await http.get(
//         Uri.parse('${Constants.apiBaseUrl}/get_varieties?commodity=$_selectedCommodity')
//       );
      
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         _varieties = List<String>.from(data['varieties']);
//         notifyListeners();
//       }
//     } catch (e) {
//       print('Error fetching varieties: $e');
//       // Use demo data for testing
//       _varieties = ['Local', 'Hybrid', 'Imported'];
//       notifyListeners();
//     }
//   }
  
//   // Set selected variety and fetch grades
//   Future<void> setSelectedVariety(String variety) async {
//     _selectedVariety = variety;
//     _selectedGrade = null;
//     _grades = [];
//     notifyListeners();
    
//     await fetchGrades();
//   }
  
//   // Fetch grades for selected variety
//   Future<void> fetchGrades() async {
//     if (_selectedCommodity == null || _selectedVariety == null) return;
    
//     try {
//       final response = await http.get(
//         Uri.parse('${Constants.apiBaseUrl}/get_grades?commodity=$_selectedCommodity&variety=$_selectedVariety')
//       );
      
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         _grades = List<String>.from(data['grades']);
//         notifyListeners();
//       }
//     } catch (e) {
//       print('Error fetching grades: $e');
//       // Use demo data for testing
//       _grades = ['A', 'B', 'C'];
//       notifyListeners();
//     }
//   }
  
//   // Set selected grade
//   void setSelectedGrade(String grade) {
//     _selectedGrade = grade;
//     notifyListeners();
//   }
  
//   // Set selected date
//   void setSelectedDate(DateTime date) {
//     _selectedDate = date;
//     notifyListeners();
//   }
  
//   // Check if all fields are selected
//   bool get isFormComplete {
//     return _selectedState != null && 
//            _selectedDistrict != null && 
//            _selectedMarket != null && 
//            _selectedCommodity != null && 
//            _selectedVariety != null && 
//            _selectedGrade != null;
//   }
  
//   // Get form data as Map
//   Map<String, dynamic> getFormData() {
//     return {
//       'State': _selectedState,
//       'District': _selectedDistrict,
//       'Market': _selectedMarket,
//       'Commodity': _selectedCommodity,
//       'Variety': _selectedVariety,
//       'Grade': _selectedGrade,
//       'Year': _selectedDate.year,
//       'Month': _selectedDate.month,
//       'Day': _selectedDate.day
//     };
//   }
  
//   // Reset form
//   void resetForm() {
//     _selectedState = null;
//     _selectedDistrict = null;
//     _selectedMarket = null;
//     _selectedCommodity = null;
//     _selectedVariety = null;
//     _selectedGrade = null;
//     _selectedDate = DateTime.now();
//     _districts = [];
//     _markets = [];
//     _varieties = [];
//     _grades = [];
//     notifyListeners();
//   }
// }
