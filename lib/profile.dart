import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _username;
  String _selectedCurrency = 'IDR';
  double _exchangeRate = 1.0; // Default to 1 for IDR
  final TextEditingController _amountController = TextEditingController();
  double _convertedAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _fetchExchangeRate();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username');
    });
  }

  Future<void> _fetchExchangeRate() async {
    final response = await http
        .get(Uri.parse('https://api.exchangerate-api.com/v4/latest/IDR'));

    if (response.statusCode == 200) {
      final rates = json.decode(response.body)['rates'];
      setState(() {
        _exchangeRate = rates[_selectedCurrency];
      });
    } else {
      throw Exception('Failed to load exchange rate');
    }
  }

  void _convertCurrency() {
    final amountInIDR = double.tryParse(_amountController.text) ?? 0.0;
    setState(() {
      _convertedAmount = amountInIDR * _exchangeRate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: _username == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/icon.png'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '$_username',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('username');
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text('Logout'),
                  ),
                  const SizedBox(height: 50),
                  DropdownButton<String>(
                    value: _selectedCurrency,
                    items: <String>['IDR', 'USD', 'EUR', 'JPY', 'GBP']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCurrency = newValue!;
                        _fetchExchangeRate();
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Jumlah Uang di Rupiah',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _convertCurrency,
                    child: const Text('Convert'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Jumlah Konversi Mata Uang : $_convertedAmount $_selectedCurrency',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
      ),
    );
  }
}
