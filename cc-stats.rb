#!/usr/bin/env ruby

require 'json'
require 'trollop'
require 'httparty'
require 'socket'
require 'uri'


class Array
  def mean
    self.sum / self.length
  end


  def sum
    self.inject(0) { |accum, n| accum + n.to_f }
  end


  def variance
    mean = self.mean
    sum  = self.inject(0) {|accum, n| accum + (n.to_f - mean) ** 2 }

    sum / (self.length - 1)
  end


  def stdev
    Math.sqrt(self.variance)
  end
end


def parse_cmd_line
  opts = Trollop::options do
    version "cc-stats 1.0.0"
    banner <<-EOS
    Description goes here.

    Usage:
       cc-stats [options] <metric_name>
           
    Examples:
       cc-stats stats_counts.metric.name
       cc-stats -b 1367366400 -e 1367539200 -g http://graphite.mydomain.com stats_counts.metric.name

    where [options] are:
    EOS
    opt :graphite,   "Graphite URI",               :short => "g", :default => "http://localhost:2003"
    opt :verbose,    "Enable verbose output",      :short => "v", :default => false
    opt :begin,      "Begin date in epoch time",   :short => "b", :default => 0
    opt :end,        "End date in epoch time",     :short => "e", :default => 0
    opt :hour_start, "Hour when operations start", :short => "h", :default => 12
    opt :duration,   "Duration of operations",     :short => "d", :default => 24
    opt :interval,   "Interval in minutes",        :short => "i", :default => 60
  end
  opts
end


def get_dates(start, stop)
  Trollop::die "The end date must be greater than the beginning date" if stop < start
  
  start = start != 0 ? Time.at(start) : Time.at(Time.now - 86400)  
  stop  = stop  == 0 ? start + 86400  : Time.at(stop)
  
  [start, stop]
end


def format_date(epoch)
  "#{epoch.strftime("%H:%M")}_#{epoch.strftime("%Y%m%d")}"
end


def fetch_data(graphite, start, stop, metric, interval, hour_start, duration, verbose)
  from_date  = start
  until_date = start + interval
 
  values = []
  while until_date <= stop
    current_hour = from_date.strftime("%H").to_i
    current_step = "#{'%02d' % (((from_date - start) / interval) + 1).round} of #{'%02d' % ((stop - start) / interval).round} => #{from_date} ... #{until_date}"
    
    if current_hour < hour_start || current_hour >= hour_start + duration
      puts current_step if verbose
  
      data_uri = URI.escape "#{graphite}/render?format=json&from=#{format_date(from_date)}&until=#{format_date(until_date)}&target=#{metric}"

      begin
        response = HTTParty.get(data_uri)
      rescue StandardError=>e
        puts "ERROR: #{e}"; exit
      end

      if response.code == 200
        begin
          data = JSON.parse(response.body)
        rescue StandardError=>e
          puts "ERROR: #{e}"; exit
        end
        data.first["datapoints"].each { |v, t| values << v.to_f }
      else
        puts "Request failed:", response.code, response.body; exit
      end

    else
      puts "SKIPPING #{current_step}" if verbose
    end
    
    from_date  = until_date
    until_date = from_date + interval
  end
  values
end


def print_stats(metric, graphite, start, stop, interval, hour_start, duration, verbose)
  Trollop::die "You must provide a metric name" if metric.nil?
  
  trap("INT") { puts " ABORTED"; exit }
  
  puts "\nFETCHING DATA" if verbose
  values = fetch_data graphite, start, stop, metric, interval, hour_start, duration, verbose

  puts "\nRESULTS\nMean = #{values.mean.round(2)}\nStandard Deviation = #{values.stdev.round(2)}\n\n"
end


if __FILE__ == $0
  opts       = parse_cmd_line
  graphite   = opts[:graphite]
  interval   = opts[:interval] * 60
  hour_start = opts[:hour_start]
  duration   = opts[:duration]
  verbose    = opts[:verbose]

  start, stop   = get_dates opts[:begin], opts[:end]
  
  print_stats ARGV[0], graphite, start, stop, interval, hour_start, duration, verbose
end
