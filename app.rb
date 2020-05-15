require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'


def is_barber_exists? db, name # db - принимает обьект для работы с базой данной  || name - имя парикмахера, будет спрашивать есть он или нету || эта функция обращаеться в db 41 строка
	db.execute('select*from Barbers where name=?', [name]).length > 0 # выражение возврщает(какой то набор) или тру или фелс || существует парикмахер или нет

end

def seed_db db, barbers #db - принимает обьект для работы с базой данной  и принимать || # seed - наполнение чего то 	

		barbers.each do |barber| # будет проходиться по всем 
		if !is_barber_exists? db, barber # будет спрошиват есть ли этот парикмахер 
			db.execute 'insert into Barbers (name) values(?)', [barber] # будет вставлять парикмахера если его нету
		end
	end	 
end


def get_db
	db = SQLite3::Database.new 'barbershop.db'# создает новую базу данных
	db.results_as_hash = true
	return db
end	

before do # предназначен для синатры для того что бы исполнять какой то код перед кажыдым запросом  
	db = get_db
	@barbers = db.execute 'select * from Barbers' # пременная которая теперь будет во всех вью
end 	

configure do # запускаеться во время включения програмы ||  функция создана для того что бы быводить из базы данный списки в веб для разных таблиц
	db = get_db
	db.execute 'CREATE TABLE IF NOT EXISTS
		"Users" 
		(
			"id" INTEGER PRIMARY KEY AUTOINCREMENT, 
			"username" TEXT, 
			"phone"	TEXT, 
			"datestamp"	TEXT, 
			"barber" TEXT, 
			"color"	TEXT
		)'	

	db.execute 'CREATE TABLE IF NOT EXISTS
		"Barbers" 
		(
			"id" INTEGER PRIMARY KEY AUTOINCREMENT, 
			"name" TEXT 
		)'		
	
	seed_db db,['Jessie Pinkman','Walter White','Gus Fring','Mike Ehrmantraut'] # будет вызывать функцию из def is_barber_exists? db, name
end	


get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/about' do
	erb :about
end

#============================================================================================================================================================================================================================================
get '/visit' do
	erb :visit
end


post '/visit' do

	@username = params[:username]
	@phone = params[:phone]
	@datetime = params[:datetime]
	@barber = params[:barber]
	@color = params[:color]

	# хеш
	hh = { 	:username => 'Введите имя',
			:phone => 'Введите телефон',
			:datetime => 'Введите дату и время' }

	@error = hh.select {|key,_| params[key] == ""}.values.join(", ")

	if @error != ''
		return erb :visit
	end

	db = get_db
	db.execute 'insert into 
	 	Users 
	 	(
			username , 
			phone , 
			datestamp, 
			barber , 
			color
		) 		
		values (?, ?, ?, ?, ?)', [@username, @phone, @datetime, @barber, @color]

    erb "<h2>Спасибо #{@username},Вы записались на #{@datetime},к #{@barber}<h2>"

end

#==============================================================================================================================================================================================================================

get '/showusers' do
	db = get_db
	
	@results = db.execute 'select *  from Users order by id desc'
	
	erb :showusers
end	

#====================================================================================================================================================================
get '/contacts' do
	erb :contacts
end

post '/contacts' do 

	@email = params[:email]
	@text = params[:text]

	# хеш
	hh = { 	:email => 'Введите email',
			:text => 'Введите text' }

	@error = hh.select {|key,_| params[key] == ""}.values.join(", ")

	if @error != ''
		return erb :contacts
	end
	
 erb "Даныне получены"
end	
#=======================================================================================================================================================================

#======================================================================================================================================================================