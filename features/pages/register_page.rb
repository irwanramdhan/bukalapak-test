class BukaLapakPage < SitePrism::Page
  set_url '/register?from=nav_header&comeback=https://www.bukalapak.com/'

  element :nama_lengkap, '#user_name'
  element :email, '#email_or_phone'
  element :radio_button_male, :xpath, '//span[contains(text(),"Laki-laki")]'
  element :username, '#user_username'
  element :password, '#user_password'
  element :confirm_password, '#user_password_confirmation'
  element :checkbox, :xpath, '/html[1]/body[1]/main[1]/div[2]/div[1]/form[1]/div[8]/label[1]/span[1]'
  element :btn_daftar, :xpath, '//button[contains(text(),"Daftar")]'
  elements :profile_name, '.bl-link.is-hide-underline'
  element :avatar, '.bl-avatar.sigil-avatar'

  def fill_register_data(data_register)
    nama_lengkap.set data_register[:input_nama_lengkap]
    email.set data_register[:input_email]
    username.set data_register[:input_username]
    password.set data_register[:input_password]
    confirm_password.set data_register[:input_confirm_password]
  end
end