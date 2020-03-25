# frozen_string_literal: true

require 'sinatra'
require 'sinatra/flash'
require './lib/database_connection_setup.rb'
require './lib/user.rb'
require './lib/space'

class MakersBnB < Sinatra::Base
  enable :sessions, :method_override
  register Sinatra::Flash

  # before do
  #   @user = User.instance
  # end

  get '/' do
    @spaces = Space.all
    erb :index
  end

  get '/sign_up' do
    erb :'users/sign_up'
  end

  post '/sign_up' do
    # Saves into users DB (params - Name, email, username password)
    # Update parameter names when decided
    User.create(name: params[:name], email: params[:email], password: params[:password])
    redirect '/sign_in'
  end

  get '/sign_in' do
    erb :'users/sign_in'
  end

  post '/sign_in' do
    @@user = User.log_in(email: params[:email], password: params[:password])

    redirect '/user'
  end

  get '/user' do
    erb :user
  end

  get '/create_space' do
    erb :'spaces/create'
  end

  post '/create_space' do
    # Saves into spaces DB
    # Update parameter names when decided

    # As we are not log_in yet, authenticate the user is registered in DB
    # If user exists, create the new space, if not, throw error
    unless User.authenticate(email: params[:email], password: params[:password])
      Flash[:notice] = 'Invalid User'
    end

    user_id = User.find_id(email: params[:email])

    Space.create(space_name: params[:space_name], description: params[:description], price: params[:price], user_id: user_id)
    redirect '/user'
  end

  get '/book_space/:space_id' do
    # find_space gets all the information from a space from the DB with the id
    @space = Space.find_space(params[:space_id])

    erb :'spaces/book'
  end

  post '/book_space/:space_id' do
    # change availability in spaces DB

    # As we are not log_in yet, authenticate the user is registered in DB
    # If user exists, create the new space, if not, throw error
    unless User.authenticate(email: params[:email], password: params[:password])
      Flash[:notice] = 'Invalid User'
    end

    Space.book(space: params[:space_id])
    redirect '/user'
  end

  run! if app_file == $PROGRAM_NAME
end
