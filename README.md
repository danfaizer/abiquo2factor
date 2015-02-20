requires:
mysql lib
ruby
redis


start server
# bundle exec rackup

start Resque worker:
# rake resque:work QUEUE=*