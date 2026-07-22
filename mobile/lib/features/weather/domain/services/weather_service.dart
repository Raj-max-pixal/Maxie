import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';

class WeatherService {
  WeatherFactory? _weatherFactory;
  Weather? _currentWeather;
  String? _currentCity;

  Weather? get currentWeather => _currentWeather;
  String? get currentCity => _currentCity;

  Future<void> initialize({required String apiKey}) async {
    _weatherFactory = WeatherFactory(apiKey);
    await _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    await _fetchWeather(position.latitude, position.longitude);
  }

  Future<void> _fetchWeather(double lat, double lon) async {
    if (_weatherFactory == null) return;

    try {
      _currentWeather = await _weatherFactory!.currentWeatherByLocation(lat, lon);
      _currentCity = await _getCityName(lat, lon);
    } catch (e) {
      // Handle error
    }
  }

  Future<String> _getCityName(double lat, double lon) async {
    try {
      final placemarks = await Geolocator.placemarkFromCoordinates(lat, lon);
      return placemarks.first.locality ?? 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  String getWeatherReaction() {
    if (_currentWeather == null) {
      return 'I can\'t check the weather right now! ☁️';
    }

    final weatherCondition = _currentWeather!.weatherMain?.toLowerCase() ?? '';
    final temperature = _currentWeather!.temperature?.celsius ?? 20;

    if (weatherCondition.contains('rain') || weatherCondition.contains('drizzle')) {
      return _getRainReaction();
    } else if (weatherCondition.contains('clear') || weatherCondition.contains('sun')) {
      return _getSunnyReaction(temperature);
    } else if (weatherCondition.contains('cloud')) {
      return _getCloudyReaction();
    } else if (weatherCondition.contains('snow')) {
      return _getSnowReaction();
    } else if (weatherCondition.contains('storm') || weatherCondition.contains('thunder')) {
      return _getStormReaction();
    } else if (weatherCondition.contains('fog') || weatherCondition.contains('mist')) {
      return _getFogReaction();
    } else {
      return _getDefaultWeatherReaction(temperature);
    }
  }

  String _getRainReaction() {
    final reactions = [
      'It\'s raining! Don\'t forget an umbrella! ☔',
      'Rainy day! Perfect for staying inside with me! 🌧️',
      'Rain drops! Stay dry and cozy! 💧',
      'Pitter patter! It\'s raining outside! 🌧️',
    ];
    return reactions[(DateTime.now().millisecond) % reactions.length];
  }

  String _getSunnyReaction(double temperature) {
    if (temperature > 30) {
      return [
        'It\'s hot outside! Stay cool! ☀️',
        'Scorching hot! Don\'t forget sunscreen! 🌞',
        'Hot day! Stay hydrated! 💧',
        'It\'s baking outside! Stay cool! ❄️',
      ][(DateTime.now().millisecond) % 4];
    } else {
      return [
        'Beautiful sunny day! ☀️',
        'Sun is shining! Perfect weather! 🌞',
        'Lovely day! Enjoy the sunshine! ☀️',
        'Sunny vibes! Great day to go out! 🌤️',
      ][(DateTime.now().millisecond) % 4];
    }
  }

  String _getCloudyReaction() {
    final reactions = [
      'Cloudy day! Nice and cozy! ☁️',
      'Clouds are out! Perfect temperature! 🌥️',
      'Overcast but nice! Comfortable weather! ☁️',
      'Cloudy skies! Not too hot, not too cold! 🌥️',
    ];
    return reactions[(DateTime.now().millisecond) % reactions.length];
  }

  String _getSnowReaction() {
    final reactions = [
      'It\'s snowing! So magical! ❄️',
      'Snow day! Bundle up warm! ⛄',
      'Winter wonderland! Stay cozy! ❄️',
      'Snowflakes! Beautiful weather! ⛄',
    ];
    return reactions[(DateTime.now().millisecond) % reactions.length];
  }

  String _getStormReaction() {
    final reactions = [
      'Stormy weather! Stay safe inside! ⛈️',
      'Thunder and lightning! Scary but cool! ⚡',
      'Storm alert! Stay indoors! 🌩️',
      'Rough weather! I\'m a bit scared... ⛈️',
    ];
    return reactions[(DateTime.now().millisecond) % reactions.length];
  }

  String _getFogReaction() {
    final reactions = [
      'Foggy outside! Can\'t see far! 🌫️',
      'Misty day! Drive carefully! 🌫️',
      'Fog everywhere! Mysterious weather! 🌫️',
      'It\'s foggy! Stay safe if you go out! 🌫️',
    ];
    return reactions[(DateTime.now().millisecond) % reactions.length];
  }

  String _getDefaultWeatherReaction(double temperature) {
    if (temperature < 10) {
      return [
        'It\'s cold! Wear a sweater! 🧥',
        'Brrr! It\'s freezing outside! ❄️',
        'Cold weather! Stay warm! 🧣',
        'Chilly! Bundle up! 🧥',
      ][(DateTime.now().millisecond) % 4];
    } else if (temperature > 25) {
      return [
        'It\'s warm outside! Nice weather! 🌤️',
        'Pleasant temperature! Enjoy! ☀️',
        'Nice and warm! Great day! 🌞',
        'Comfortable weather! Perfect! 🌤️',
      ][(DateTime.now().millisecond) % 4];
    } else {
      return [
        'Nice weather! Not too hot, not too cold! 🌤️',
        'Perfect temperature! Just right! ☀️',
        'Comfortable day! Enjoy! 🌥️',
        'Great weather! Whatever you want to do! 🌤️',
      ][(DateTime.now().millisecond) % 4];
    }
  }

  String getTimeBasedReaction(int hour) {
    if (hour >= 5 && hour < 12) {
      // Morning
      return [
        'Good morning! *stretches* Rise and shine! ☀️',
        'Morning! Ready to conquer the day? 🌅',
        'Wakey wakey! Let\'s do this! ☀️',
        'Early bird! Great start to the day! 🐦',
      ][(DateTime.now().millisecond) % 4];
    } else if (hour >= 12 && hour < 17) {
      // Afternoon
      return [
        'Good afternoon! How\'s your day going? 🌤️',
        'Afternoon! Keep up the good work! 💪',
        'Midday! Halfway there! 🌞',
        'Afternoon vibes! Stay productive! ☀️',
      ][(DateTime.now().millisecond) % 4];
    } else if (hour >= 17 && hour < 21) {
      // Evening
      return [
        'Good evening! Time to relax! 🌆',
        'Evening! Wind down time! 🌅',
        'Sun\'s going down! Nice evening! 🌆',
        'Evening vibes! Great time to chill! 🌇',
      ][(DateTime.now().millisecond) % 4];
    } else {
      // Night
      return [
        'Nighty night! Sweet dreams! 🌙',
        'Time to sleep! I\'ll be here when you wake up 😴',
        'Good night! Rest well! 🌙',
        'Late night! Don\'t stay up too long! 😴',
      ][(DateTime.now().millisecond) % 4];
    }
  }
}

final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService();
});
