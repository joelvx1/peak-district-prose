require "require_all"
require "sequel"
require "logger"
require "sinatra"

#so we can escape characters in the views files
include ERB::Util

# Sessions so we can store stuff about the user
enable :sessions


# Database
mode = ENV.fetch("APP_ENV", "Production")
path = File.dirname(__FILE__)
file_minus_ext = "#{path}/#{mode}"

DB = Sequel.sqlite("#{file_minus_ext}.sqlite3",
                   logger: Logger.new("#{file_minus_ext}.log"))


# makes sure the user is logged in when accessing certain routes
set(:auth) do |*roles|
  condition do
    need_to_redirect = true
    roles.each { |role|
      session[:login_redirect] = request.path
      if role == :user
        need_to_redirect = false if session['logged_in']
      elsif role == :admin
        need_to_redirect = false if session['admin_logged_in']
      elsif role == :manager
        need_to_redirect = false if session['manager_logged_in']
      end
    }
    if need_to_redirect
      redirect '/login'
    end
  end
end



# Require main app files
require_rel "models", "controllers"


