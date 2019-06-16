
require 'file-tail' # Require a gem that allows us to tail a faile
require 'socket' # Import Socket so we can get the hostname and also make TCP requests to Graphite

class Graphiter

    def initialize(file, metric)
        @file = file # Which output file to monitor for Metric information
        @pattern = /\[([0-9K]{1,}).*\s([0-9]{1,})/ # Regex Pattern to extract bucket and value using capture groups
        @hostname = `hostname`.strip # Get the Hostname
        @metric = metric # Assign the metric name we are monitoring for

        @graphite_endpoint = ENV.fetch('GRAPHITE_ENDPOINT', 'localhost') # Setup a Graphite Endpoint we wish to send data to
        @graphite_port = ENV.fetch('GRAPHITE_PORT', '2003') # Setup a graphite port we need to use
    end

    def start_parsing
        socket = TCPSocket::new(@graphite_endpoint, @graphite_port)
        File.open(@file) do | log |
            log.extend(File::Tail)
            log.interval # 15
            log.tail { | line |
                if match = line.match(@pattern)
                    key = '%{hostname}.%{metric}.%{bucket}' % { hostname: @hostname, metric: @metric, bucket: match.captures[0] }
                    socket.puts("%{key} %{value} #{Time.now.to_i}\n" % { key: key, value: match.captures[1]})
                    puts "%{key} %{value} #{Time.now.to_i}\n" % { key: key, value: match.captures[1]}
                end
            }
        end

    end

end

cpu_lat = Graphiter.new('/opt/graphiter/.staging.txt', 'cpu-lat') # Get A Graphiter Object
cpu_lat.start_parsing() # Start the Parser
