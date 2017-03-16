#!/usr/bin/ruby

require 'rubygems'
require 'bundler'
Bundler.require(:default)

require 'open-uri'
require 'nokogiri'
require 'yaml'
require 'optparse'

options[:wallpaper_dir] = "#{ENV["HOME"]}/Wallpaper/Dual"
base_url = "http://www.dualmonitorbackgrounds.com"

# Load args
options = {}
options[:category] = "nature"
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on('-c NAME', '--category=NAME', 'Category name (choose one)',
  " abstract",
  " animals",
  " astronomy",
  " computers",
  " crafted-nature",
  " nature",
  " celebrities",
  " popular-culture",
  " science-fiction"
  ) { |v| options[:category] = v }
  opts.on('-r', '--refresh', 'Force a refresh of the list for this category') { |v| options[:refresh] = v }
  opts.on('-d PATH', '--directory=PATH', 'Choose the directory for the images to be stored') { |v| options[:wallpaper_dir] = v }

end.parse!

category = options[:category]
wallpaper_root = options[:wallpaper_dir]

yaml_file = "#{category}-dual.yaml"

reached_end = false
if File.file?(yaml_file) then
  thumbnails_list = YAML.load_file(yaml_file)
else
  thumbnails_list = []
end

if thumbnails_list.length == 0 || options[:refresh] then
  i = 1

  until reached_end
    @html_doc = Nokogiri::HTML(open("#{base_url}/#{category}/page/#{i}"))

    new_items = @html_doc.css("li.image a").map { |thumbnail| thumbnail.attributes["href"].value }.uniq
    thumbnails_list.concat(new_items)
    if new_items.count < 20
      reached_end = true
    end
    i += 1
  end
  File.open(yaml_file, 'w') { |file| file.write(thumbnails_list.to_yaml) }
end

# Pick a random image
chosen_image = thumbnails_list.sample

chosen_image_doc = Nokogiri::HTML(open("#{base_url}/#{chosen_image}"))
wallpaper_name = chosen_image["#{category}/".length + 1, chosen_image.length]
wallpaper_name = wallpaper_name[0, wallpaper_name.length - 8]
screens = ["left", "right"]
parts = chosen_image_doc.css("#DownloadOptions a").map { |part| "#{base_url}#{part.attributes["href"].value}" }

puts "Downloading wallpaper: #{wallpaper_name}"

parts.each_index do |index|
  image_filename = "#{wallpaper_root}/#{wallpaper_name}-#{screens[index]}.jpg"
  unless File.file?(image_filename) then
    open(image_filename, "wb") do |file|
      open(parts[index]) do |uri|
        file.write(uri.read)
      end
    end
  end
end

def osascript(script)
  system 'osascript', *script.split(/\n/).map { |line| ['-e', line] }.flatten
end

osascript <<-END
 tell application "System Events"
	tell desktop 1
		set picture to "#{wallpaper_root}/#{wallpaper_name}-left.jpg"
	end tell
	tell desktop 2
		set picture to "#{wallpaper_root}/#{wallpaper_name}-right.jpg"
	end tell
end tell
END
