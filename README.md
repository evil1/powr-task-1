# POWr home task #1

This app enables a user to login using GitHub OAuth API and save the user details once the login was successful.
It also ensures that the data of the particular user was not saved before.

## Bonus  
The app inserts the `script` tags into `head` and `body` sections of a `powr/index.html` in `evil1/evil1.github.io` repository.
There is also a dummy validation that `script` tags where not inserted before to avoid duplication.

### General detail of how the app created
1. First I've generated the basic scaffold for the user entity `rails generate scaffold user external_id:string login:string name:string jsonObject:text`.
That step has created a database migration, generated a model, and controller with a basic CRUD functionality
2. `rails db:migrate` to apply the migration
3. Created an `index_controller.rb`, `index` action of the controller, and `views/index/index.html.erb`. Configured `root('index#index')` option in `config/routes.rb`
 to set the `index` controller adn action `index` as thh default app's page
4. The login function will be implemented using sessions. Session vars `user_id` and `user_name` will store user's id and name
5. Pass those session vars to the vie useing `@current_user_id` and `@current_user_name` local variables. `index` view displays whether 
user is logged in or not, and login/logout links depending on the current state. 