#!/bin/env ruby
require 'json'

class MewductHome
  def initialize
    @webroot = ARGV.shift

    unless File.directory?(File.join(@webroot))
      abort "mewduct-home.rb <webroot_directory>"
    end
  end
  
  def create_home
    all_videos = []
    Dir.children(File.join(@webroot, "user")).each do |userdir|
      fp = File.join(@webroot, "user", userdir, "videos.json")
      next unless File.exist?(fp)
      videos = JSON.load File.read fp
      all_videos.concat videos
    end

    File.open(File.join(@webroot, "meta", "index.json"), "w") do |f|
      JSON.dump(all_videos.sort_by {|i| i["created_at"]}.reverse[0, 40], f)
    end

    all_users = []
    Dir.children(File.join(@webroot, "user")).each do |userdir|
      fp = File.join(@webroot, "user", userdir, "usermeta.json")
      user = JSON.load File.read fp
      user["user_id"] = userdir
      all_users.push user
    end

    File.open(File.join(@webroot, "meta", "users.json"), "w") do |f|
      JSON.dump(all_users.sort_by {|i| i["lastvideo_at"]}.reverse[0, 40], f)
    end
  end
end

MewductHome.new.create_home