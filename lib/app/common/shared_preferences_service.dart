import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  Future<String> getLanguage() async {
    var pref = await SharedPreferences.getInstance();
    String lang = pref.getString('language') ?? 'ja';
    return lang;
  }

  Future<bool> setLanguage(String lang) async {
    var pref = await SharedPreferences.getInstance();
    await pref.setString('language', lang);
    Intl.defaultLocale = lang;

    return true;
  }
}
