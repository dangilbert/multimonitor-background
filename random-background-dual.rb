#!/usr/bin/ruby

require 'rubygems'
require 'bundler'
Bundler.require(:default)

require 'open-uri'
require 'nokogiri'

wallpaper_root = "#{ENV["HOME"]}/Wallpaper/Dual"
base_url = "http://www.dualmonitorbackgrounds.com"
category = "nature"

reached_end = false
thumbnails_list = []
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

# Pick a random image
chosen_image = thumbnails_list.sample

chosen_image_doc = Nokogiri::HTML(open("#{base_url}/#{chosen_image}"))
wallpaper_name = chosen_image["#{category}/".length + 1, chosen_image.length]
wallpaper_name = wallpaper_name[0, wallpaper_name.length - 8]
screens = ["left", "right"]
parts = chosen_image_doc.css("#DownloadOptions a").map { |part| "#{base_url}#{part.attributes["href"].value}" }

parts.each_index do |index|
  open("#{wallpaper_root}/#{wallpaper_name}-#{screens[index]}.jpg", "wb") do |file|
    open(parts[index]) do |uri|
      file.write(uri.read)
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
