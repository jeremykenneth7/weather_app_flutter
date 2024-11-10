import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Cari nama kota ...',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      _searchWeather(_controller.text);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_weather != null) ...[
                Text(
                  _weather!.cityName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Lottie.asset(getWeatherAnimation(_weather!.mainCondition)),
                const SizedBox(height: 20),
                Text(
                  '${_weather!.temperature}°C',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 10),
                Text(
                  _translateCondition(_weather!.mainCondition),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  'Kelembapan: ${_weather!.humidity}%',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  'Kecepatan Angin: ${_weather!.windSpeed} m/s',
                  style: const TextStyle(fontSize: 18),
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

class SearchResultPage extends StatelessWidget {
  final Weather weather;

  const SearchResultPage({required this.weather, Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cuaca di ${weather.cityName} sekarang'),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  weather.cityName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Lottie.asset(getWeatherAnimation(weather.mainCondition)),
                const SizedBox(height: 20),
                Text(
                  '${weather.temperature}°C',
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 10),
                Text(
                  _translateCondition(weather.mainCondition),
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  'Kelembapan: ${weather.humidity}%',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  'Kecepatan Angin: ${weather.windSpeed} m/s',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
