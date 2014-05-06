#encoding:utf-8
require 'rest_client'
require 'json'
require 'yaml'
require 'mustache'


credentials = YAML.load(File.read("credentials.yml"))

def url_events(api_key)
  return "https://api.sharypic.com/v1/user/events.json?api_key=#{api_key}"
end

def last_images(api_key,uid_event,opts = {})
  length = opts[:length] || 50
  return "https://api.sharypic.com/v1/user/events/#{uid_event}/collections/all/media/latest.json?api_key=#{api_key}&length=#{length}"
end

mustache_template = File.read("illustration_post.mustache")

events = JSON.parse(RestClient.get(url_events(credentials["SHARY_API_KEY"])))

events.each do |event|
  last_ones = JSON.parse(RestClient.get(last_images(credentials["SHARY_API_KEY"],event["uid"])))

  event[:photos] = []
  last_ones["next_media"].each do |media|
    tmp_tof = {}
    ["author_name","author_profile_photo_url","created_at","large_url","original_height","original_width","small_url","thumbnail_url","title"].each do |key|
      tmp_tof[key] = media[key]
    end
    event[:photos] << tmp_tof
  end

  result = Mustache.render mustache_template, event

  File.open("#{event["uid"]}.html",'w+'){|f| f.write result}
end



