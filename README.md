requires:
mysql
ruby
redis

prepare:
config.yml
mysql -u user -p password -e 'create database token'

start server:
bundle exec rackup

start Resque worker:
rake resque:work QUEUE=*