require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'omniauth-github'
require 'pry'

require_relative 'config/application'
set :environment, :development

Dir['app/**/*.rb'].each { |file| require_relative file }

helpers do
  def current_user
    user_id = session[:user_id]
    @current_user ||= User.find(user_id) if user_id.present?
  end

  def signed_in?
    current_user.present?
  end
end

def set_current_user(user)
  session[:user_id] = user.id
end

def authenticate!
  unless signed_in?
    flash[:notice] = 'You need to sign in if you want to do that!'
    redirect '/'
  end
end

get '/' do
  erb :index
end

get '/meetups' do
  authenticate!
  meetups = Meetup.order(:title)
  erb :meetups, locals: { meetups: meetups }
end

get '/create' do
  authenticate!
  erb :create
end

post '/create' do
  title = params[:title]
  location = params[:location]
  description = params[:description]
  meetup = Meetup.create(title: title, location: location, description: description)
  if meetup.save
    flash[:notice] = "You've successfully created #{title}!"
  else
    flash[:notice] = "This meetup has already been created!"
  end
  redirect '/'
end

get '/meetups/:id' do
  authenticate!
  meetup = Meetup.find(params[:id])
  users = meetup.users
  erb :meetup_id, locals: { meetup: meetup, users: users }
end

post '/meetups/:id' do
  meetup = Meetup.find(params[:id])
  user = session[:user_id]
  new_roster = Roster.new(meetup: meetup, user_id: user)
  if new_roster.save
    flash[:notice] = "You've successfully joined #{meetup.title}!"
  else
    flash[:notice] = "You've already joined this meetup, try another one!"
  end
  redirect '/'
end

get '/auth/github/callback' do
  auth = env['omniauth.auth']

  user = User.find_or_create_from_omniauth(auth)
  set_current_user(user)
  flash[:notice] = "You're now signed in as #{user.username}!"

  redirect '/'
end

get '/sign_out' do
  session[:user_id] = nil
  flash[:notice] = "You have been signed out."

  redirect '/'
end

get '/example_protected_page' do
  authenticate!
end
