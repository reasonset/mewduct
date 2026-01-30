#!/bin/env ruby
require 'yaml'
require 'json'

source_dir = ARGV.shift
media_prefix = ARGV.shift

def usage
  abort "generate-sources.rb <media_source_directory> <media_url_prefix>"
end

if (!source_dir || !media_prefix)
  usage
end

titlemeta = YAML.load File.read File.join(source_dir, "titlemeta.yaml")

files = Dir.children(source_dir).select {|i| %w:.mp4 .webm:.include? File.extname(i) }.sort_by {|i| i.to_i }

sources = {
  "type" => "video",
  "title" => titlemeta["title"],
  "sources" => files.map {|i|
    {
      "src" => [media_prefix, i].join("/"),
      "type" => (File.extname(i) == ".mp4" ? "video/mp4" : "video/webm"),
      "size" => i.to_i
    }
  },
  "poster" => [media_prefix, "thumbnail.webp"].join("/")
}

File.open(File.join(source_dir, "sources.json"), "w") do |f|
  JSON.dump sources, f
end