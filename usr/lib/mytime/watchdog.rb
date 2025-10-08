require 'httparty'
require 'optparse'

options = {
  message: nil
}

args = ARGV

parser = OptionParser.new do |opts|
  opts.banner = "Usage: mytime-watchdog [identifier] [run] [event] [options]"

  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end

  opts.on('-m', '--message=MESSAGE', String, "An optional message to send with the event") { |o| options[:message] = o }
end

parser.parse!(args)

def send_watchdog(watchdog, run, event, message: nil)
  response = HTTParty.post("https://mytime.skylight.be/api/radar/watchdog/#{watchdog}/#{run}/#{event}", body: { message: message })

  response.code == 200
end

if args.size != 3
  puts "\n\n#{parser}\n\n"
  exit 1
end

identifier = args[0]
run = args[1]
event = args[2]
message = options[:message]

exit 1 if !send_watchdog(identifier, run, event, message: message)