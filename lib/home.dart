import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app_flutter/login.dart';
import 'package:weather_app_flutter/model/model.dart';
import 'package:weather_app_flutter/services/services.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService('0316fab323fb5cba6587212f599f28b3');
  Weather? _weather;
  final TextEditingController _controller = TextEditingController();

  _fetchWeather() async {
    String cityName = await _weatherService.getCurrentCity();

    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      print(e);
    }
  }

  _searchWeather(String cityName) async {
    try {
      final weather = await _weatherService.getWeather(cityName);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultPage(weather: weather),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  _logout() async {
    await clearSession();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  String getWeatherAnimation(String? mainCondition) {
    switch (mainCondition) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/cloud.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rain.json';
      case 'thunderstorm':
        return 'assets/thunder.json';
      case 'clear':
        return 'assets/sunny.json';
      default:
        return 'assets/sunny.json';
    }
  }

  String _translateCondition(String? condition) {
    switch (condition) {
      case 'clouds':
        return 'Berawan';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'Hujan';
      case 'thunderstorm':
        return 'Badai Petir';
      case 'clear':
        return 'Cerah';
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'Berkabut';
      default:
        return 'Cerah';
    }
  }

  String _selectedTimeZone = 'WIB';

  String getCurrentTime(String timeZone) {
    final now = DateTime.now();
    DateTime convertedTime;

    switch (timeZone) {
      case 'WITA':
        convertedTime = now.toUtc().add(const Duration(hours: 8));
        break;
      case 'WIT':
        convertedTime = now.toUtc().add(const Duration(hours: 9));
        break;
      case 'WIB':
      default:
        convertedTime = now.toUtc().add(const Duration(hours: 7));
        break;
    }

    return DateFormat('HH:mm:ss').format(convertedTime);
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cari nama kota'),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: 'Masukkan nama kota'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _searchWeather(_controller.text);
              },
              child: const Text('Cari'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      _logout();
                    },
                  ),
                  if (_weather != null)
                    Text(
                      _weather!.cityName,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    )
                  else
                    const Text(
                      'Loading...',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _showSearchDialog,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(getCurrentTime(_selectedTimeZone),
                      style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 20),
                  DropdownButton<String>(
                    value: _selectedTimeZone,
                    items: <String>['WIB', 'WITA', 'WIT'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTimeZone = newValue!;
                      });
                    },
                  ),
                ],
              ),
              if (_weather != null) ...[
                Lottie.asset(getWeatherAnimation(_weather!.mainCondition)),
                const SizedBox(height: 10),
                Text(
                  '${_weather!.temperature}°C',
                  style: const TextStyle(
                      fontSize: 38, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  _translateCondition(_weather!.mainCondition),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.wb_incandescent_sharp),
                          onPressed: () {},
                        ),
                        Column(
                          children: [
                            Text(
                              '${_weather!.humidity}%',
                              style: const TextStyle(fontSize: 18),
                            ),
                            const Text('Kelembapan')
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.speed),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 5),
                        Column(
                          children: [
                            Text(
                              '${_weather!.windSpeed} m/s',
                              style: const TextStyle(fontSize: 18),
                            ),
                            const Text('Kecepatan Angin')
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ] else
                const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchResultPage extends StatefulWidget {
  final Weather weather;

  const SearchResultPage({required this.weather, super.key});

  @override
  _SearchResultPageState createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  String _selectedTimeZone = 'WIB';

  String getWeatherAnimation(String? mainCondition) {
    switch (mainCondition) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/cloud.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rain.json';
      case 'thunderstorm':
        return 'assets/thunder.json';
      case 'clear':
        return 'assets/sunny.json';
      default:
        return 'assets/sunny.json';
    }
  }

  String _translateCondition(String? condition) {
    switch (condition) {
      case 'clouds':
        return 'Berawan';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'Hujan';
      case 'thunderstorm':
        return 'Badai Petir';
      case 'clear':
        return 'Cerah';
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'Berkabut';
      default:
        return 'Cerah';
    }
  }

  Future<void> saveCityWeather(Weather weather) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_city', weather.cityName);
    await prefs.setDouble('saved_temperature', weather.temperature);
    await prefs.setString('saved_condition', weather.mainCondition ?? '');
    await prefs.setInt('saved_humidity', weather.humidity);
    await prefs.setDouble('saved_windSpeed', weather.windSpeed);
  }

  String getCurrentTime(String timeZone) {
    final now = DateTime.now();
    DateTime convertedTime;

    switch (timeZone) {
      case 'WITA':
        convertedTime = now.toUtc().add(const Duration(hours: 8));
        break;
      case 'WIT':
        convertedTime = now.toUtc().add(const Duration(hours: 9));
        break;
      case 'WIB':
      default:
        convertedTime = now.toUtc().add(const Duration(hours: 7));
        break;
    }

    return DateFormat('HH:mm:ss').format(convertedTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    widget.weather.cityName,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      saveCityWeather(widget.weather);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Success'),
                            content: Text(
                                'Cuaca di ${widget.weather.cityName} berhasil disimpan'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(getCurrentTime(_selectedTimeZone),
                      style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 20),
                  DropdownButton<String>(
                    value: _selectedTimeZone,
                    items: <String>['WIB', 'WITA', 'WIT'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTimeZone = newValue!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Lottie.asset(getWeatherAnimation(widget.weather.mainCondition)),
              const SizedBox(height: 10),
              Text(
                '${widget.weather.temperature}°C',
                style:
                    const TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                _translateCondition(widget.weather.mainCondition),
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.wb_incandescent_sharp),
                        onPressed: () {},
                      ),
                      Column(
                        children: [
                          Text(
                            '${widget.weather.humidity}%',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const Text('Kelembapan')
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.speed),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 5),
                      Column(
                        children: [
                          Text(
                            '${widget.weather.windSpeed} m/s',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const Text('Kecepatan Angin')
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
