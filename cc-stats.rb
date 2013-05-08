#!/usr/bin/env ruby

require 'json'
require 'trollop'
require 'httparty'
require 'socket'
require 'uri'


def parse_cmd_line
  opts = Trollop::options do
    version "cc-stats 1.0.0"
    banner <<-EOS
    Description goes here.

    Usage:
       cc-stats [options] <metric_name>
           
    Examples:
       need examples

    where [options] are:
    EOS
    opt :graphite, "Graphite URI",             :short => "g", :default => "http://localhost:2003"
    opt :verbose,  "Enable verbose output",    :short => "v", :default => false
    opt :begin,    "Begin date in epoch time", :short => "b", :default => 0
    opt :end,      "End date in epoch time",   :short => "e", :default => 0
  end
  opts
end


def get_dates(start, stop)
  Trollop::die "The end date must be greater than the beginning date" if stop < start
  
  start = start != 0 ? Time.at(start) : Time.at(Time.now - 86400)  
  stop  = stop  == 0 ? start + 86400  : Time.at(stop)
  
  ["#{start.strftime("%H:%M")}_#{start.strftime("%Y%m%d")}", "#{stop.strftime("%H:%M")}_#{stop.strftime("%Y%m%d")}"]
end


def fetch_data(graphite, start, stop, metric)
  data_uri = URI.escape "#{graphite}/render?format=json&from=#{start}&until=#{stop}&target=#{metric}"
  
  begin
    response = HTTParty.get(data_uri)
  rescue StandardError=>e
    puts "ERROR: #{e}"; exit
  end

  if response.code == 200
    data = JSON.parse(response.body)
  else
    puts "Request failed:", response.code, response.body; exit
  end
end


def print_stats(metric, graphite, start, stop, verbose)
  Trollop::die "You must provide a metric name" if metric.nil?
  
  trap("INT") { puts " ABORTED"; exit }
  
  jobj = fetch_data graphite, start, stop, metric
  puts jobj
end


if __FILE__ == $0
  opts     = parse_cmd_line
  graphite = opts[:graphite]
  verbose  = opts[:verbose]

  start, stop = get_dates opts[:begin], opts[:end]
  
  print_stats ARGV[0], graphite, start, stop, verbose
end
