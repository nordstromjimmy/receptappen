class AppStrings {
  AppStrings._();

  // ── App ──────────────────────────────────────────────────
  static const String appName = 'Matrecept';
  static const String myRecipes = 'Mina recept';

  // ── Navigation ───────────────────────────────────────────
  static const String navHome = 'Hem';
  static const String navFavorites = 'Favoriter';
  static const String navShopping = 'Inköp';
  static const String navProfile = 'Profil';

  // ── Home ─────────────────────────────────────────────────
  static const String searchHint = 'Sök bland dina recept...';
  static const String recentlyAdded = 'Senast tillagda';
  static const String favoritesTitle = 'Favoriter';
  static const String allRecipes = 'Alla recept';

  static String recipesCount(int n) =>
      n == 1 ? '1 sparat recept' : '$n sparade recept';

  // ── Categories ───────────────────────────────────────────
  static const String catAll = 'Alla';
  static const String catEveryday = 'Vardagsmat';
  static const String catBaking = 'Bakning';
  static const String catVegetarian = 'Vegetariskt';
  static const String catSoup = 'Soppa';
  static const String catDessert = 'Dessert';
  static const String catBreakfast = 'Frukost';

  // ── Recipe detail ────────────────────────────────────────
  static const String ingredients = 'Ingredienser';
  static const String instructions = 'Instruktioner';
  static const String source = 'Källa';
  static const String openSource = 'Öppna originalsida';
  static const String deleteRecipe = 'Ta bort recept';
  static const String editRecipe = 'Redigera';
  static const String confirmDelete = 'Ta bort receptet?';
  static const String confirmDeleteMsg = 'Det här går inte att ångra.';
  static const String cancel = 'Avbryt';
  static const String confirm = 'Ta bort';

  static String minutesLabel(int min) => '$min min';
  static String servingsLabel(int n) => '$n port.';

  // ── Add / Edit recipe ────────────────────────────────────
  static const String addRecipeTitle = 'Nytt recept';
  static const String editRecipeTitle = 'Redigera recept';
  static const String saveRecipe = 'Spara recept';
  static const String fieldName = 'Receptets namn *';
  static const String fieldUrl = 'Länk till originalrecept';
  static const String fieldSource = 'Källans namn (t.ex. Arla, ICA)';
  static const String fieldDesc = 'Beskrivning';
  static const String fieldCategory = 'Kategori';
  static const String fieldPrepTime = 'Förberedelsetid (min)';
  static const String fieldCookTime = 'Tillagningstid (min)';
  static const String fieldServings = 'Antal portioner';
  static const String fieldIngredient = 'Ingrediens (t.ex. 2 dl mjölk)';
  static const String addIngredient = '+ Lägg till ingrediens';
  static const String fieldStep = 'Steg';
  static const String addStep = '+ Lägg till steg';
  static const String fieldImageUrl = 'Bildlänk (valfritt)';
  static const String sectionBasic = 'Grundinformation';
  static const String sectionTiming = 'Tid & portioner';
  static const String sectionIngredients = 'Ingredienser';
  static const String sectionInstructions = 'Instruktioner';

  // ── Empty states ─────────────────────────────────────────
  static const String emptyTitle = 'Inga recept ännu';
  static const String emptySubtitle =
      'Tryck på + för att spara ditt första recept';
  static const String emptySearch = 'Inga recept matchade sökningen';
  static const String emptyFavorites = 'Du har inga favoriter ännu';
  static const String emptyFavSub =
      'Tryck på hjärtat på ett recept för att spara det här';

  // ── Snackbars ─────────────────────────────────────────────
  static const String savedOk = 'Recept sparat!';
  static const String deletedOk = 'Recept borttaget';
  static const String errorSaving = 'Kunde inte spara receptet';
}
