# Crack-Rack-Session

Customized the PentesterLab Rack Cookies and Commands Injection section from the PentesterLab Bootcamp (http://pentesterlab.com/bootcamp) to automate tampering rack session cookies to gain a shell to the web server without having to touch the command line more than once.

### Prerequisities
1. If running on a `*.nix` machine, configure the pentesterlab vm to be reached from your host or guest VM. Go to `/etc/hosts` and create a hostname to match the IP of their vm. More instructions to download it can be found on their page (http://pentesterlab.com/exercises/rack_cookies_and_commands_injection/course). I am running on a Kali Linux vm and both my vm and pentesterlab's vm is configured on a NAT network.
1. Make sure `ruby` is installed on your machine.

### Instructions
1. Download this repo and make sure all files are saved in the same directory (for convenience).
1. `crack_rack_cookie.rb` is not marked as an executable. To call it, you can either:
    1. call it as `ruby crack_rack_cookie.rb` or
    1. Mark it as executable: `chmod +x crack_rack_cookie.rb`and then you can call it as `./crack_rack_cookie.rb`
        1. Running `file crack_rack_cookie.rb` in the command line should output that the file is now a Ruby script.
1. Command line arguments are wordlists used for brute forcing the login and brute forcing the key used to sign the cookie. I've included a sample wordlist `bigol.txt` that can be used for both command line arguments.
    1. Sample call: `./crack_rack.cookie.rb {ARG0} {ARG1}` where both arguments can either be `bigol.txt` or any wordlist of your choosing.

