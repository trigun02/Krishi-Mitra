import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/dataprovider.dart';
import '../providers/predictionprovider.dart';
import 'predictionresult.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      // Initialize data on first load
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      dataProvider.initData();
      _isInit = true;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final predictionProvider = Provider.of<PredictionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('KrishiMitra'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderCard(),
            SizedBox(height: 20),
            _buildDropdownSection(
              title: 'Location Details',
              children: [
                _buildDropdown(
                  label: 'State',
                  hint: 'Select State',
                  value: dataProvider.selectedState,
                  items: dataProvider.states,
                  onChanged: (value) {
                    if (value != null) {
                      dataProvider.setSelectedState(value);
                    }
                  },
                ),
                SizedBox(height: 12),
                _buildDropdown(
                  label: 'District',
                  hint: 'Select District',
                  value: dataProvider.selectedDistrict,
                  items: dataProvider.districts,
                  onChanged: dataProvider.selectedState == null
                      ? null
                      : (value) {
                          if (value != null) {
                            dataProvider.setSelectedDistrict(value);
                          }
                        },
                ),
                SizedBox(height: 12),
                _buildDropdown(
                  label: 'Market',
                  hint: 'Select Market',
                  value: dataProvider.selectedMarket,
                  items: dataProvider.markets,
                  onChanged: dataProvider.selectedDistrict == null
                      ? null
                      : (value) {
                          if (value != null) {
                            dataProvider.setSelectedMarket(value);
                          }
                        },
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildDropdownSection(
              title: 'Commodity Details',
              children: [
                _buildDropdown(
                  label: 'Commodity',
                  hint: 'Select Commodity',
                  value: dataProvider.selectedCommodity,
                  items: dataProvider.commodities,
                  onChanged: (value) {
                    if (value != null) {
                      dataProvider.setSelectedCommodity(value);
                    }
                  },
                ),
                SizedBox(height: 12),
                _buildDropdown(
                  label: 'Variety',
                  hint: 'Select Variety',
                  value: dataProvider.selectedVariety,
                  items: dataProvider.varieties,
                  onChanged: dataProvider.selectedCommodity == null
                      ? null
                      : (value) {
                          if (value != null) {
                            dataProvider.setSelectedVariety(value);
                          }
                        },
                ),
                SizedBox(height: 12),
                _buildDropdown(
                  label: 'Grade',
                  hint: 'Select Grade',
                  value: dataProvider.selectedGrade,
                  items: dataProvider.grades,
                  onChanged: dataProvider.selectedVariety == null
                      ? null
                      : (value) {
                          if (value != null) {
                            dataProvider.setSelectedGrade(value);
                          }
                        },
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildDateSection(context, dataProvider),
            SizedBox(height: 30),
            _buildPredictButton(context, dataProvider, predictionProvider),
            SizedBox(height: 16),
            if (predictionProvider.isLoading)
              Center(child: CircularProgressIndicator()),
            if (predictionProvider.error != null)
              _buildErrorMessage(predictionProvider.error!),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              Icons.agriculture,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: 12),
            Text(
              'KrishiMitra',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Predict minimum, maximum, and modal prices for agricultural commodities using our advanced machine learning model.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownSection({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(hint),
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down),
              onChanged: onChanged,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSection(BuildContext context, DataProvider dataProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () => _selectDate(context, dataProvider),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('dd MMMM, yyyy').format(dataProvider.selectedDate),
                      style: TextStyle(fontSize: 16),
                    ),
                    Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, DataProvider dataProvider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dataProvider.selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime.now().add(Duration(days: 30)), // Allow prediction for next 30 days
    );
    if (picked != null && picked != dataProvider.selectedDate) {
      dataProvider.setSelectedDate(picked);
    }
  }

  Widget _buildPredictButton(
    BuildContext context,
    DataProvider dataProvider,
    PredictionProvider predictionProvider,
  ) {
    return ElevatedButton(
      onPressed: !dataProvider.isFormComplete || predictionProvider.isLoading
          ? null
          : () async {
              // Get form data and make prediction
              final formData = dataProvider.getFormData();
              await predictionProvider.getPredictions(formData);
              
              // If prediction was successful, navigate to results screen
              if (predictionProvider.predictionResult != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PredictionResultScreen(
                      prediction: predictionProvider.predictionResult!,
                      formData: formData,
                    ),
                  ),
                );
              }
            },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        'PREDICT PRICES',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Colors.red[900]),
            ),
          ),
        ],
      ),
    );
  }
}
