Given('user is on bukalapak register page') do
  @pages.bukalapak_page.load
end

When('user fill the register form') do
  sleep 1
  @user_register = {
    input_nama_lengkap: Faker::Name.first_name,
    input_email: Faker::Name.first_name + '@gmail.com',
    input_password: 'gmail.com' + '123',
    input_confirm_password: 'gmail.com' + '123',
  }
  @pages.bukalapak_page.fill_register_data @user_register
  @profile_name = @pages.bukalapak_page.nama_lengkap.value
  @pages.bukalapak_page.radio_button_male.click
  @pages.bukalapak_page.checkbox.click
  @pages.bukalapak_page.btn_daftar.click
  sleep 5
end

Then('system should redirect user to home page') do
  @pages.bukalapak_page.avatar.click
  expect(@pages.bukalapak_page.profile_name[3].value).to eq @profile_name
end