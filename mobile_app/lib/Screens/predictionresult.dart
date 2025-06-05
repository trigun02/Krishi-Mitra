import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/predictionprovider.dart';

class PredictionResultScreen extends StatelessWidget {
  final PredictionResult prediction;
  final Map<String, dynamic> formData;

  const PredictionResultScreen({
    Key? key,
    required this.prediction,
    required this.formData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Currency formatter for Indian Rupees
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Price Prediction Results'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildResultsCard(context, currencyFormat),
            SizedBox(height: 20),
            _buildInputSummaryCard(),
            SizedBox(height: 20),
            _buildInfoCard(),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'MAKE ANOTHER PREDICTION',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard(BuildContext context, NumberFormat currencyFormat) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              Icons.insights,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: 12),
            Text(
              'Predicted Prices',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            _buildPriceRow(
              context,
              label: 'Minimum Price',
              value: prediction.minPrice,
              formatter: currencyFormat,
              color: Colors.blue,
            ),
            SizedBox(height: 16),
            _buildPriceRow(
              context,
              label: 'Maximum Price',
              value: prediction.maxPrice,
              formatter: currencyFormat,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            _buildPriceRow(
              context,
              label: 'Modal Price',
              value: prediction.modalPrice,
              formatter: currencyFormat,
              color: Colors.green,
              isHighlighted: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    BuildContext context, {
    required String label,
    required double value,
    required NumberFormat formatter,
    required Color color,
    bool isHighlighted = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isHighlighted ? 18 : 16,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          formatter.format(value),
          style: TextStyle(
            fontSize: isHighlighted ? 22 : 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInputSummaryCard() {
    // Convert date from form data
    final date = DateTime(
      formData['Year'] as int,
      formData['Month'] as int,
      formData['Day'] as int,
    );
    final dateFormat = DateFormat('dd MMMM, yyyy');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prediction Parameters',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildDetailRow('Commodity', formData['Commodity']),
            _buildDetailRow('Variety', formData['Variety']),
            _buildDetailRow('Grade', formData['Grade']),
            Divider(),
            _buildDetailRow('Market', formData['Market']),
            _buildDetailRow('District', formData['District']),
            _buildDetailRow('State', formData['State']),
            Divider(),
            _buildDetailRow('Date', dateFormat.format(date)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label + ':',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'About Price Prediction',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'These prices are predicted using a two-stage machine learning model with 91% accuracy. The prediction is based on historical data of 9.2 million records.',
              style: TextStyle(
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Modal price is the most frequently occurring price and is commonly used as a reference price in agricultural markets.',
              style: TextStyle(
                color: Colors.blue[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

