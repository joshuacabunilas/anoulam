import 'package:injectable/injectable.dart';
import 'package:mobile/src/common/constant/storage_helper.dart';
import 'package:mobile/src/utils/storage_utils.dart';

/// Recipe data kept on the device.
@injectable
class RecipeLocalDataSource {
  const RecipeLocalDataSource();

  List<String> getSavedIngredients() =>
      StorageUtil.getStringList(StorageHelper.savedIngredients);

  Future<void> saveIngredients(List<String> ingredients) async {
    final saved = await StorageUtil.putStringList(
      StorageHelper.savedIngredients,
      ingredients,
    );
    if (!saved) throw StateError('Could not save ingredients.');
  }

  /// Names of the result filters that are switched on.
  List<String> getSavedFilters() =>
      StorageUtil.getStringList(StorageHelper.savedRecipeFilters);

  Future<void> saveFilters(List<String> filters) async {
    final saved = await StorageUtil.putStringList(
      StorageHelper.savedRecipeFilters,
      filters,
    );
    if (!saved) throw StateError('Could not save filters.');
  }
}
