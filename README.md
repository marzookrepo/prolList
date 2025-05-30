# prolist

A new Flutter project made for interview Task

## about this work

I kept my code clean and simple. I split the project into folders like models, services, providers, screens, and widgets so everything is in its right place."

all API work is done in ApiService. Reusable UI parts like product display cards are in the widgets folder.



Folder strustructure 

> presentation layer - the screen and widget 

> for managing state - by provider directory for product and favorite managing 
and state managing like filtering product togling favorite

> the data layer consist of calling API in service folder and model class respectivly

>the utilities folder contain the constand value and the whole app theme values

>for splash screen animation i have used lottie json file loading in from starting



this project is not made completly followed clean architechture or model view model arch but it seperate UI and statemangement, and data operation seperalty


UI Design & Layout:

used basic Flutter widgets like Scaffold, AppBar, GridView.builder, and Card to make the app look nice and easy to use

GridView.builder shows the products in a 2 grid that works on all screen sizes. Each product is shown using a custom ProductCard widget."

- CachedNetworkImage to load images faster and show placeholders while loading."

- Spacing is added with Padding, SizedBox, and EdgeInsets. Colors and styles are handled in app_theme.dart

- Hero animation is used for smooth screen transitions. Icons like search and favorite help users easily understand the UI


API and Error handle:
- fetching  products from fakestoreapi.com using the http package

- used async/await to load data without freezing

- Errors are caught using try-catch, and I show loading spinners or messages to loading the data


State Management
- i have used the provider package to manage state
(ProductProvider:Keeps the list of products,also managing the search, FavoritesProvider: Saves favorite products)


- Uses SharedPreferences to save favorites even after closing the app.

in main.dart the multiporovider added to add both provider , it will check the favorite also when initialising 

>> fetures added

Provider for state management.

SharedPreferences to remember favorite items.

Pull-to-Refresh using RefreshIndicator.

Search using SearchDelegate to filter products by title.

simple animated splash screen using lottie library

hero for smooth page animation and content loading

> To avoid crashing used practices like 


-  null safty in api calling strings
- async , wait future for api calling 
- used final in all variable 



