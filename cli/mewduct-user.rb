#!/bin/env ruby
require 'json'

class MewductUser
  def initialize webroot, user_id
    @webroot = webroot
    @user_id = user_id
    @now = Time.now

    if !File.directory?(File.join(@webroot, "user")) || !@user_id || @user_id.empty?
      abort "mewduct-user.rb <action> <webroot_directory> <user_id>"
    end
  end

  def create username
    Dir.mkdir(File.join(@webroot, "user", @user_id))
    File.open(File.join(@webroot, "user", @user_id, "usermeta.json"), "w") do |f|
      JSON.dump({
        "username" => username,
        "created_at" => @now.to_i,
        "lastvideo_at" => @now.to_i
      }, f)
    end
    File.open(File.join(@webroot, "user", @user_id, "videos.json"), "w") do |f|
      JSON.dump([], f)
    end

    Dir.mkdir(File.join(@webroot, "media", @user_id))
  end

  def update
    usermeta = JSON.load File.read File.join(@webroot, "user", @user_id, "usermeta.json")
    media = Dir.children(File.join(@webroot, "media", @user_id)).map do |fn|
      fp = File.join(@webroot, "media", @user_id, fn, "meta.json")
      meta = JSON.load File.read fp
      meta["user"] = @user_id
      meta["username"] = usermeta["username"]
      meta["src"] = ["", "media", @user_id, meta["media_id"]].join("/")

      meta
    end

    media = media.sort_by {|i| i["created_at"]}.reverse

    File.open(File.join(@webroot, "user", @user_id, "videos.json"), "w") do |f|
      JSON.dump(media, f)
    end

    usermeta["lastvideo_at"] = media[0]["created_at"]
    File.open(File.join(@webroot, "user", @user_id, "usermeta.json"), "w") do |f|
      JSON.dump(usermeta, f)
    end
  end
end

action = ARGV.shift
webroot = ARGV.shift
user_id = ARGV.shift

user = MewductUser.new webroot, user_id

case action&.downcase
when "create"
  print "User display name? "
  username = $stdin.gets.strip
  if !username || username.empty?
    exit 1
  end
  user.create username
when "update"
  user.update
end