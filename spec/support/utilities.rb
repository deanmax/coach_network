def sign_in(coach, options={})
  if options[:no_capybara]
    # Sign in when not using Capybara.
    remember_token = Coach.new_remember_token
    cookies[:remember_token] = remember_token
    coach.update_attribute(:remember_token, Coach.hash(remember_token))
  else
    visit signin_path
    fill_in "Email",    with: coach.email
    fill_in "Password", with: coach.password
    click_button "Sign in"
  end
end