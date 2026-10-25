class StringHelper {
  StringHelper._();

  // App
  static const appName = 'AnoUlam';

  // Common actions
  static const ok = 'OK';
  static const cancel = 'Cancel';
  static const done = 'Done';
  static const save = 'Save';
  static const submit = 'Submit';
  static const retry = 'Retry';
  static const close = 'Close';
  static const next = 'Next';
  static const back = 'Back';

  // Common states
  static const loading = 'Loading...';
  static const noData = 'No data available.';

  // Errors
  static const somethingWentWrong = 'Something went wrong. Please try again.';
  static const noInternet =
      'No internet connection. Please check your network.';
  static const requestTimedOut = 'The request timed out. Please try again.';
  static const serviceUnavailable =
      'Service temporarily unavailable. Please try again in a few moments.';
  static const sessionExpired =
      'Your session has expired. Please log in again.';

  // Validation
  static const fieldRequired = 'This field is required.';
  static const invalidEmail = 'Please enter a valid email address.';
  static const invalidMobileNumber = 'Please enter a valid mobile number.';

  // Ingredients
  static const ingredientsTitle = "What's in your kitchen?";
  static const couldNotLoadIngredients =
      "Couldn't load your saved ingredients.";
  static const couldNotSaveIngredients = "Couldn't save your ingredients.";
  static const ingredientsSubtitle =
      "Add what you have and we'll suggest dishes you can make. "
      'Salt, pepper, oil and water are assumed.';
  static const ingredientLabel = 'Ingredient';
  static const ingredientHint = 'e.g. eggs, rice, garlic';
  static const addIngredient = 'Add ingredient';
  static const ingredientSearchHint = 'Search or add an ingredient';
  static const yourIngredients = 'Your basket';
  static const browseIngredients = 'Browse the market';
  static String itemCount(int count) => '$count items';
  static String selectedCount(int count) => '$count selected';
  static const clearAll = 'Clear all';
  static const noIngredientsMessage =
      'Nothing in your basket yet. Search above, or pick from the market.';
  static const basketEmpty = 'Your basket is empty';
  static const basketEmptyHint = 'Add what you have to find dishes';
  static String basketCount(int count) =>
      count == 1 ? '1 ingredient' : '$count ingredients';
  static const seeRecipes = 'See recipes';
  static String alreadyAdded(String name) => '"$name" is already on your list.';
  static String removeNamed(String name) => 'Remove $name';
  static String removedNamed(String name) => 'Removed $name';
  static String clearedCount(int count) =>
      count == 1 ? 'Cleared 1 ingredient' : 'Cleared $count ingredients';
  static String listFull(int max) =>
      'You can add up to $max ingredients. Remove one to add another.';
  static const undo = 'Undo';

  // Recipe results
  static const recipesTitle = 'Recipes for you';
  static const findingRecipes = 'Finding recipes...';
  static const wakingUpServer =
      'Waking up the recipe server. This can take up to a minute.';
  static const recipesErrorTitle = "Couldn't get recipes";
  static const noRecipesTitle = 'No recipes found';
  static const noRecipesMessage =
      'None of our recipes use these ingredients. Try adding a main '
      'ingredient such as chicken, eggs or rice.';
  static const editIngredientsAction = 'Edit ingredients';
  static const canCookNow = 'Ready to cook';
  static String missingCount(int count) =>
      count == 1 ? '+ 1 ingredient' : '+ $count ingredients';
  static String needsNamed(List<String> names) => 'Needs ${names.join(', ')}';

  // Recipe filters
  static const filterReadyToCook = 'Ready to cook';
  static const filterQuick = 'Under 30 min';
  static const filterEasy = 'Easy';
  static const filterVegetarian = 'Vegetarian';
  static const allDishTypes = 'All types';
  static const noFilterMatchTitle = 'No recipes match these filters';
  static const noFilterMatchMessage = 'Try turning off some filters.';
  static const clearFilters = 'Clear filters';
  static String usingIngredients(String names, int more) =>
      more > 0 ? 'Using: $names +$more' : 'Using: $names';
  static const editIngredients = 'Edit';
  static String showingCount(int shown, int total) =>
      shown == total ? '$total recipes' : 'Showing $shown of $total recipes';

  // Dish types
  static const categoryRice = 'Rice';
  static const categoryNoodles = 'Noodles & pasta';
  static const categorySoup = 'Soup';
  static const categoryEgg = 'Eggs';
  static const categoryMeat = 'Meat';
  static const categorySeafood = 'Seafood';
  static const categoryVegetable = 'Vegetables';
  static const categoryBread = 'Bread & breakfast';
  static const categoryDessert = 'Dessert';
  static const categoryDrink = 'Drinks';
  static const categorySnack = 'Snacks';

  // Recipe detail
  static const ingredients = 'Ingredients';
  static String youHave(int count) => 'You have ($count)';
  static String youNeed(int count) => 'You still need ($count)';
  static String stepNumber(int number) => 'Step $number';
  static const steps = 'Steps';
  static String minutes(int value) => '$value min';
  static String servings(int value) =>
      value == 1 ? '1 serving' : '$value servings';
  static const easy = 'Easy';
  static const medium = 'Medium';
  static const hard = 'Hard';
}
