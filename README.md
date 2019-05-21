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
 to set the `index` controller and action `index` as the default app's page
4. The login function will be implemented using sessions. Session vars `user_id` and `user_name` will store user's id and name
5. Pass those session vars to the view via `@current_user_id` and `@current_user_name` local variables. `index` view displays whether 
user is logged in or not, and login/logout links depending on the current state. 
6. Created `logout` action which simply resets the session and redirects to `/`
7. According to the GitHub's docs in order to login using OAuth we need to send GET request to `https://github.com/login/oauth/authorize`.
The only required parameter is the `cliend_id`. For the purpose of storing GitHub API credintials I will create an `github.rb` initializer
under `config/initializers` and will put `client_id` and `secret` there. I will also include `public_repo` scope
in order to have an access to user's public repos and implement the bonus task
8. Created an `index_helper.rb` under `app/helpers` to put there all the miscellaneous functions
9. Created a `login` action which will redirect user to GitHub's login page and add it to `routes.rb`
10. Created a `callback` action in `index` controller. Mapped it to `/oauth` url `routes.rb` which is a callback url for GitHub OAuth app
11. Created a `github_access_token` helper in `index` helper. Function utilize `net/http`, performs a POST request to `https://github.com/login/oauth/access_token`
in order to receive the `access_token` from OAuth API
12. Created `get_user_details` method in `index` helper which retrieves user's details

  