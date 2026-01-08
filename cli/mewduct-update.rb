#!/bin/env ruby
require 'yaml'
require 'json'

# Update metadatas for video.
class MewductUpdate
  def usage
    abort "mewduct-update.rb <webroot_dir> <user_id> <media_id>"
  end

  def initialize
    @webroot = ARGV.shift
    @user_id = ARGV.shift
    @media_id = ARGV.shift
    @now = Time.now
    initial_check
    @lang_method = language_name_method
  end

  def language_name_method
    begin
      require 'iso-639'
      return "gem"
    rescue LoadError
      if system("node -v", out: File::NULL, err: File::NULL)
        return "node"
      else
        return nil
      end
    end
  end

  def initial_check
    usage unless @webroot && !(@webroot.empty?) &&
      @user_id && !(@user_id.empty?) &&
      @media_id && !(@media_id.empty?) &&
      File.directory?(@webroot) &&
      File.exist?(File.join(@webroot, "user", @user_id)) &&
      File.directory?(File.join(@webroot, "media", @user_id, @media_id))
  end

  def read_titlemeta
    titlemeta = YAML.load File.read File.join(@webroot, "media", @user_id, @media_id, "titlemeta.yaml")

    jsonmeta_fp = File.join(@webroot, "media", @user_id, @media_id, "meta.json")

    if File.exist? jsonmeta_fp
      jsonmeta = JSON.load File.read jsonmeta_fp
      titlemeta = jsonmeta.merge titlemeta
    end

    @titlemeta = titlemeta
    titlemeta
  end

  def create_sources
    data = {"type" => "video", "title" => @titlemeta["title"], "sources" => []}
    Dir.children(File.join(@webroot, "media", @user_id, @media_id)).each do |fn|
      next unless %w:.mp4 .webm:.include? File.extname(fn)
      size = File.basename(fn, ".*").to_i
      next if size.zero?

      mime = case File.extname(fn)
      when ".mp4"
        "video/mp4"
      when ".webm"
        "video/webm"
      end

      this_video = {
        "src" => ["", "media", @user_id, @media_id, fn].join("/"),
        "type" => mime,
        "size" => size
      }

      data["sources"].push this_video
    end

    data["poster"] = ["", "media", @user_id, @media_id, "thumbnail.webp"].join("/")

    captions = create_captions
    data["tracks"] = captions if captions

    data
  end

  def create_captions
    captions = []
    unless @lang_method
      $stderr.puts "mewduct-update requires iso-639 gem or Node.js for import caption."
      return nil
    end

    Dir.children(File.join(@webroot, "media", @user_id, @media_id)).each do |fn|
      next unless fn =~ /^captions\.(\w+)\.vtt$/
      captions.push({
        "code" => $1,
        "filename" => fn,
        "filepath" => File.join(@webroot, "media", @user_id, @media_id, fn),
        "srcpath" => ["media", @user_id, @media_id, fn].join("/")
      })
    end

    converted_captions = []
    case @lang_method
    when "gem"
      captions.each do |cp|
        converted_captions.push({
          "kind" => "captions",
          "label" => ISO639.find(cp[:code])&.english_name || "Unknwon",
          "srclang" => cp["code"],
          "src" => cp["srcpath"]
        })
      end
    when "node"
      IO.popen(["node", "#{__dir__}/mewduct-codeenglishname.js"], "w+") do |io|
        io.write JSON.dump captions
        io.close_write
        converted_captions = JSON.load io.read
      end
    end

    converted_captions.empty? ? nil : converted_captions
  end

  def write_sources
    data = create_sources
    File.open(File.join(@webroot, "media", @user_id, @media_id, "sources.json"), "w") do |f|
      JSON.dump data, f
    end
  end

  def write_meta
    titlemeta = read_titlemeta
    titlemeta["created_at"] ||= @now.to_i
    titlemeta["updated_at"] = @now.to_i
    titlemeta["user_id"] = @user_id
    titlemeta["media_id"] = @media_id

    File.open(File.join(@webroot, "media", @user_id, @media_id, "meta.json"), "w") do |f|
      JSON.dump titlemeta, f
    end
  end

  def main
    write_meta
    write_sources
  end
end

MewductUpdate.new.main