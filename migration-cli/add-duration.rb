#!/bin/env ruby
require 'yaml'

webroot = ARGV.shift
unless File.directory?(webroot)
  abort "add-duration.rb <mewduct_webroot>"
end

cmd = File.expand_path(File.join(__dir__, "..", "cli", "mewduct-duration.zsh"))
unless File.executable? cmd
  abort "mewduct-duration.zsh is not found."
end

Dir.chdir(webroot)

Dir.glob("media/*/*").each do |media_dir|
  meta = YAML.load File.read File.join(media_dir, "titlemeta.yaml")

  next if meta["duration"]

  Dir.children(media_dir).each do |fn|
    if %w:.mp4 .webm:.include? File.extname(fn)
      duration = 0
      IO.popen([cmd, File.join(media_dir, fn)]) do |io|
        meta["duration"] = io.read.strip
      end
      puts "New duration for #{meta["title"]} -> #{meta["duration"]}"
      File.open(File.join(media_dir, "titlemeta.yaml"), "w") do |f|
        YAML.dump(meta, f)
      end
      break
    end
  end
end