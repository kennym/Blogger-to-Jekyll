#!/usr/bin/env ruby
#
# Convert blogger (blogspot) posts to jekyll posts
#
# Basic Usage
# -----------
#
#   ruby blogger_to_jekyll.rb feed_url
#
#  where `feed_url` can have the following format:
#
#  http://{your_blog_name}.blogspot.com/feeds/posts/default
#
# Requirements
# ------------
# 
#  * feedzirra: https://github.com/pauldix/feedzirra
#

require 'feedzirra'
require 'date'
require 'optparse'


def parse_post_entries(feed, verbose)
  posts = []
  feed.entries.each do |post|
    obj = Hash.new
    created_datetime = post.last_modified
    creation_date = Date.strptime(created_datetime.to_s, "%Y-%m-%d")
    title = post.title
    file_name = creation_date.to_s + "-" + title.split(/  */).join("-").delete('\/') + ".html"
    content = post.content
    
    obj["file_name"] = file_name
    obj["title"] = title
    obj["creation_datetime"] = created_datetime
    obj["content"] = content
    posts.push(obj)
  end
  return posts
end

def write_posts(posts, verbose)
  Dir.mkdir("_posts") unless File.directory?("_posts")

  total = posts.length, i = 1
  posts.each do |post|
    file_name = "_posts/".concat(post["file_name"])
    header = %{---           
layout: post
title: #{post["title"]}
date: #{post["creation_datetime"]}
comments: false
categories:
---

}
    File.open(file_name, "w+") {|f|
      f.write(header)
      f.write(post["content"])
      f.close
    }
    
    if verbose
      puts "  [#{i}/#{total[0]}] Written post #{file_name}"
      i += 1
    end
  end
end

def main
  options = {}
  opt_parser = OptionParser.new do |opt|
    opt.banner = "Usage: blogger_to_jekyll.rb FEED_URL [OPTIONS]"
    opt.separator ""
    opt.separator "Options"
    
    opt.on("-v", "--verbose", "Print out all.") do
      options[:verbose] = true
    end
  end

  opt_parser.parse!
  
  if ARGV[0]
    feed_url = ARGV.first
  else
    puts opt_parser
    exit()
  end

  puts "Fetching feed #{feed_url}..."
  feed = Feedzirra::Feed.fetch_and_parse(feed_url)
  
  puts "Parsing feed..."
  posts = parse_post_entries(feed, options[:verbose])
  
  puts "Writing posts to _posts/..."
  write_posts(posts, options[:verbose])

  puts "Done!"
end

main()
