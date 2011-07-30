# Convert blogger (blogspot) posts to jekyll posts
#
# What it does
# ------------
#
# 1) Fetches the blog's feed
# 2) For each post create a file with name
#    "YYYY-MM-DD-{post-title}.html", with the following structure:
#
#       ---
#       layout: post
#       title: {post-title}
#       date: {YYYY-mm-dd HH:MM}
#       comments: false
#       categories: 
#       ---
#
#       #{blog_post_content_in_html_format}
# 3) Write each file to a directory named `_posts`
#
# Requirements
# ------------
#
#  * feedzirra: https://github.com/pauldix/feedzirra
#
# How to use
# ----------
#
# ruby blogger_to_jekyll.rb [feed_url]
#

require 'feedzirra'
require 'date'

def parse_post_entries(feed)
  posts = []
  feed.entries.each do |post|
    obj = Hash.new
    created_datetime = post.last_modified
    creation_date = Date.strptime(created_datetime.to_s, "%Y-%m-%d")
    title = post.title
    file_name = creation_date.to_s + "-" + title.split(/  */).join("-").delete('\/') + ".markdown"

    obj["file_name"] = file_name
    obj["title"] = title
    obj["creation_datetime"] = created_datetime
    obj["content"] = post.content
    posts.push(obj)
  end
  return posts
end

def write_posts(posts)
  Dir.mkdir("_posts") unless File.directory?("_posts")

  posts.each do |post|
    file_name = "_posts/".concat(post["file_name"])
    header = %{---           
layout: post
title: #{post["title"]}
date: #{post["creation_datetime"]}
comments: false
categories:
---

%}
    File.open(file_name, "w+") {|f|
      f.write(header)
      f.write(post["content"])
      f.close
    }
  end
end

def main(feed_url="http://feeds.feedburner.com/Kennys/dev/null?format=xml")
  puts "Fetching feed..."
  feed = Feedzirra::Feed.fetch_and_parse(feed_url)
  
  puts "Parsing feed..."
  posts = parse_post_entries(feed)
  puts "Writing posts..."
  write_posts(posts)
end

main()