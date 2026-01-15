#!/bin/env ruby
require 'json'
require 'yaml'
require 'tempfile'

class MewductUser
  USER_EDITABLE_TERMS = ["username", "description"]

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

    media = media.reject {|i| i["unlisted"] }.sort_by {|i| i["created_at"]}.reverse

    File.open(File.join(@webroot, "user", @user_id, "videos.json"), "w") do |f|
      JSON.dump(media, f)
    end

    usermeta["lastvideo_at"] = media[0]["created_at"]
    File.open(File.join(@webroot, "user", @user_id, "usermeta.json"), "w") do |f|
      JSON.dump(usermeta, f)
    end
  end

  def edit
    usermeta = JSON.load File.read File.join(@webroot, "user", @user_id, "usermeta.json")

    mod = usermeta.slice(*USER_EDITABLE_TERMS)

    Tempfile.create(["", ".yaml"]) do |f|
      f.write YAML.dump mod
      f.flush
      editor = ENV["EDITOR"] || "vi"
      system(editor, f.path)
      f.seek(0)
      mod = YAML.load(f).slice(*USER_EDITABLE_TERMS)
    end

    if !mod["username"] || mod["username"] =~ /^\s*$/ || mod["username"].include?("\n")
      exit 1
    end

    File.open(File.join(@webroot, "user", @user_id, "usermeta.json"), "w") do |f|
      JSON.dump(usermeta.merge(mod), f)
    end

    puts "Update success"
  end

  def check_user_id
    if !@user_id || # Needs user_id
      @user_id.empty? || # Empty user_id is invalid.
      @user_id.include?("/") || # Don't include /
      @user_id.include?("\n") || # Don't have newline
      @user_id !~ /^[A-Za-z][A-Za-z0-9_-]{1,62}[A-Za-z0-9]$/ ||
      File.exist?(File.join(@webroot, "user", @user_id))
      abort "Invalid user_id"
    end
  end
end

action = ARGV.shift
webroot = ARGV.shift
user_id = ARGV.shift

user = MewductUser.new webroot, user_id

case action&.downcase
when "create"
  user.check_user_id
  print "User display name? "
  username = $stdin.gets.strip
  if !username || username.empty? || username =~ /^\s*$/ || username.include?("\n")
    exit 1
  end
  user.create username
when "update"
  user.update
when "edit"
  user.edit
end