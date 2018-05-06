require('sinatra')
require('sinatra/reloader')
require('pry')

get('/') do
  erb(:input)
end

get('/output') do
  length = params.fetch("length")
  if length
    @rectangle = "This is a square."
  erb(:output)
end