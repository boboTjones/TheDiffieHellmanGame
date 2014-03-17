%w[ rubygems sinatra haml base64 sha3 pp data_mapper].each {|x| require x}

load 'backend.rb'

set :root, File.dirname(__FILE__)

def generate_private_key
    rand(88888)
end

def generate_public_key(privkey)
    (@g**privkey) % @p
end

def generate_secret_key(pubkey,privkey)
    (pubkey**privkey) % @p
end

before do
    if request.path == "/"
        @you = You.new(:privkey => generate_private_key, :pubkey => "")
        @you.save!
    end
    @g = 3
    @p = 31337
end

get "/" do
    haml :index
end

get "/get_public_key/:id" do
    @you = You.get params[:id]
    @you.update_attributes(:pubkey => generate_public_key(@you.privkey))
    haml :moose
end

post "/generate_secret_key/:id" do
    @you = You.get params[:id]
    sk = generate_secret_key(params[:dc].to_i, @you.privkey)
    pp sk
    @you.update_attributes(:secret => sk)
    pp @you.secret
    redirect "/get_secret_key/#{@you.id}"
end

get "/get_secret_key/:id" do
    @you = You.get params[:id]
    haml :squirrel
end


helpers do
    def longhand(a,g,p)
       a,b = ((g**a).divmod(p).map! {|x| x.to_s})
       buf = ""
       while a.size > 0
           buf << a.slice!(0,40) << "\n"
       end
       return buf, b
    end
    
    def makehex(a)
        xx = Digest::SHA1::hexdigest(a.to_s)
        hex = ""
        while xx.size > 2
            hex << xx.slice!(0,2) << ":"
        end
        return hex + xx
    end
end
