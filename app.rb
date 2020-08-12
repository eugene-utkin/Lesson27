#encoding: utf-8

require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pony'
require 'sqlite3'

def get_db
		db = SQLite3::Database.new 'BarberShop.db'
		db.results_as_hash = true
		return db
end

def get_dbbarbers
		dbbarbers = SQLite3::Database.new 'Barbers.db'
		return dbbarbers
end

configure do
	db = get_db
	db.execute	'CREATE TABLE IF NOT EXISTS
			"Users" (
			"id" INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE,
    		"username" TEXT,
    		"phone" TEXT,
    		"datestamp" TEXT,
    		"barber" TEXT,
    		"color" TEXT)'
end

configure do
	dbarbers = get_dbbarbers
	dbarbers.execute	'CREATE TABLE IF NOT EXISTS
			"Barbers" (
			"barbername" TEXT PRIMARY KEY UNIQUE)'
end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/about' do
	@error="Something wrong"
	erb :about
end

get '/visit' do
	@barbers = []
	dbbarbers = get_dbbarbers
	dbbarbers.execute 'SELECT * from Barbers' do |row|
        @barbers = @barbers + row
end
	erb :visit
end

post '/visit' do
	@username = params[:username]
	@phone = params[:phone]
	@date = params[:date]
	@barber = params[:barber]
	@color = params[:color]
	@barbers = params[:@barbers]

	hh = { 	:username => 'Пустое имя!',
			:phone => 'Пустой номер телефона!',
			:date => 'Не введена дата!' }

	@error = hh.select {|key,_| params[key] == ""}.values.join("<br />")


	if @error != ''
			@barbers = []
			dbbarbers = get_dbbarbers
			dbbarbers.execute 'SELECT * from Barbers' do |row|
        	@barbers = @barbers + row
        end
		return erb :visit
	end

		
	f = File.open './public/users.txt', 'a'
	f.write "Name: #{@username}, Phone: #{@phone}, Date: #{@date}, Barber: #{@barber}, Color: #{@color}."
	f.close

	@title = "Поздравляем!"
	@message = "#{@username}, вы успешно записались в Barber Shop.<br />Мы будем ждать вас #{@date}.<br />Ваш парикмахер: #{@barber}.<br />Выбранный цвет: #{@color}.<br />В случае измений мы позвоним вам на номер #{@phone}."



db = get_db

	db.execute 'INSERT INTO Users (username, phone, datestamp, barber, color) VALUES (?, ?, ?, ?, ?)', [@username, @phone, @date, @barber, @color]

	erb :message
end



get '/contacts' do
	erb :contacts
end

post '/contacts' do
	@mail = params[:mail]
	@letter = params[:letter]

	hh = { 	:mail => 'Пустая почта!',
			:letter => 'Вы не ввели сообщение!'}

	@error = hh.select {|key,_| params[key] == ""}.values.join("<br />")


	if @error != ''
		return erb :contacts
	end

	Pony.mail(:to => 'mistergrib@mail.ru',
  :via => :smtp,
  :via_options => {
    :address              => 'smtp.mail.ru',
    :port                 => '587',
    :enable_starttls_auto => true,
    :user_name            => 'mistergrib',
    :password             => 'mnog',
    :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
    :domain               => "localhost.localdomain" # the HELO domain provided by the client to the server
  }, :from => "#{@mail}", :subject => "New client!", :body => "#{@letter}")

	@title = "Спасибо за обратную связь!"
	@message = "Мы внимательно изучим ваше послание и дадим ответ на почту #{@mail}."

	erb :message
end

get '/showusers' do
	db = get_db
	@results = db.execute 'SELECT * FROM Users ORDER BY id DESC'
	erb :showusers
end


