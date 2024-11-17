# user_auth.rb
require_relative 'user'

class UserAuth
  attr_reader :user
  attr_writer :user
  def initialize
    @user = nil
  end

  def signup(username, password)
    @user = User.new(username, password)
    @user.save_highscore(0)
  end

  def login(username, password)
    @user = User.new(username, password)
    user_data = @user.load_data(password)
    user_data ? @user : nil
  end

  def logout
    @user = nil
  end
end
