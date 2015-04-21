# Two Factor Auth example app

An example app using Authy for two factor authentication.

## Follow Along

### Get to the starting line

  1. Check out this repo at tag v0.1.0
    - Basic log in & out functionality is present.
    - There is a User model, using Rails' `has_secure_password`
    - Sessions are the current User's id stored in `session[:user_id]`
  2. [Sign up for a trial Authy account](https://www.authy.com/developers)
    - create a test app
    - from the dashboard, copy your "Api Key for Production"
    - save that key as `authy_key` in config/secrets.yml
  3. Follow the install steps at https://github.com/authy/authy-ruby
    - Your API key in `config/initializers/authy.rb` will be `Rails.application.secrets.authy_key`

### Let Users turn on 2FA

Most times you'll want 2FA to be optional. Registration has two steps:

1. **Setup:** Providing a cellphone number, which creates a user in Authy
  At this point, Authy will always return approve ANY code for this id until we
  verify them. So we do that straight away.
2. **Verify:** Them proving they own that number by entering a 2FA code

I do this by creating a controller called `TwoFactorAuthenticationController`.

1. `GET #setup` for rendering the setup page
2. `POST #register` for
  - receiving the POST
  - firing those deetz to Authy
  - storing the unverified Authy ID in the session (cos I'm lazy)
  - redirecting to verify
3. `GET #verify` for rending the page where they enter their code
4. `POST #verify` for receiving the post
  * if we can verify that code for the ID in the session
    * save it to the user - the user is now "2FA enabled"

### Verify 2FA tokens on Sign In

1. During the regular SessionsController#create, check if 2FA is enabled
2. If it is, 
  * tell Authy to send an SMS / show token in app
  * render `#two_factor_required`
3. Verify the token POSTed to `#two_factor_verification` is valid
4. Continue with sign in

## Excercises for the reader

### Code Smells:

  * Don't store the unverified Authy ID in the session; it shouldn't be something the user can mess with
  * Make the controller actions thin (extract Authy methods somewhere)

### Features:

  * Let a user turn off 2FA
  * Let a user force a (re)send of the SMS,
    if the app is broken or they didn't get it the first time
  * Implement RecoveryCodes for if their phone is lost / stolen
  * Implement "Remember this computer for 30 days"