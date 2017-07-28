# Sure does suck that Google Reader shut down. Please pick your favorite news website (NYTimes, Hacker News, Reddit, BBC, etc.) and build an RSS reader for that site. It has to have two functions. i) shows the headlines. ii) allows me to save an article (favorite / star / or something like that). Please push the results to GitHub and deploy it somewhere (Heroku, Digital Ocean, etc.). I've noticed that candidates that have used Sinatra to build this have had particular luck, but you're welcome to use whatever framework you like.

require 'sinatra'
require 'rss'
require 'json'

class RssReader < Sinatra::Base
  @@expire_date = Time.now + (60 * 60 * 24 * 7)

  get '/' do
    rss_items = RSS::Parser.parse('https://www.nasa.gov/rss/dyn/breaking_news.rss').items
    favorites = request.cookies["favorites"] || []
    favorites = JSON.parse(favorites) unless favorites == []

    @posts = rss_items.map do |item|
      is_favorite = favorites.include?(item.dc_identifier)
      { id: item.dc_identifier, title: item.title, is_favorite: is_favorite, link: item.link }
    end

    erb :index
  end

  post '/' do
    favorites = request.cookies["favorites"] || []
    favorites = JSON.parse(favorites) unless favorites == []


    if favorites.include?(params[:post_id])
      favorites.delete(params[:post_id])
    else
      favorites.push(params[:post_id])
    end

    response.set_cookie("favorites", :value => favorites.to_json, :expires => @@expire_date)

    redirect "/"
  end
end
