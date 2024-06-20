# Menu feeds

The iPhone app reads public HTTPS feeds. No key is required.

| Feed | What it contributes |
| --- | --- |
| [TheMealDB](https://www.themealdb.com/api.php) | Snack photos, instructions, ingredients, and area |
| [DummyJSON recipes](https://dummyjson.com/docs/recipes) | Extra snacks, prep time, and rating |
| [DummyJSON groceries](https://dummyjson.com/docs/products) | Market items and their dollar prices |
| [Open Food Facts Prices](https://prices.openfoodfacts.org/) | Shelf prices matched by name |
| [Frankfurter](https://www.frankfurter.app/docs/) | Conversion of those shelf prices into US dollars |

A shelf price is used when the snack name and the product name share a word, and the converted price is at most $40. Otherwise the app uses a DummyJSON grocery price. Dessert names, including a cake named after a fruit, use the dessert anchor rather than a fruit price. The snack page states which source you are looking at.

Delivery is the shop's own rule: $3.50, or free once the bag reaches $35.

If every feed fails, the app shows the built-in counter samples and says the live menu did not load. A successful menu is cached on the phone for 30 minutes.
