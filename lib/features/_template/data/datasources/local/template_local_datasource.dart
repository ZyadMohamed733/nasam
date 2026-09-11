import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../models/template_model.dart';

abstract class TemplateLocalDataSource {
  Future<void> cacheTemplate(TemplateModel model);
  Future<TemplateModel?> getCachedTemplate(String id);
}

@LazySingleton(as: TemplateLocalDataSource)
class TemplateLocalDataSourceImpl implements TemplateLocalDataSource {
  const TemplateLocalDataSourceImpl(this._prefs);
  final SharedPreferences _prefs;

  static const String _keyPrefix = 'cached_template_';

  @override
  Future<void> cacheTemplate(TemplateModel model) async {
    final jsonStr = jsonEncode(model.toJson());
    await _prefs.setString('$_keyPrefix${model.id}', jsonStr);
  }

  @override
  Future<TemplateModel?> getCachedTemplate(String id) async {
    final jsonStr = _prefs.getString('$_keyPrefix$id');
    if (jsonStr == null) return null;
    try {
      return TemplateModel.fromJson(
        jsonDecode(jsonStr) as Map<String, dynamic>,
      );
    } on Object catch (e, stack) {
      // A cache entry written by an older model version no longer parses.
      throw CacheException(message: e.toString(), stackTrace: stack);
    }
  }
}
