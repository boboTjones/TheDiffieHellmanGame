require 'rubygems'
require 'data_mapper'


class You
    include DataMapper::Resource
    property :id, Serial
    property :privkey, Integer
    property :pubkey, Integer
    property :secret, String
end


configure do
    DataMapper.setup(:default, "sqlite3:///#{Dir.pwd}/resources/app.db")
    DataMapper.auto_upgrade!
end
