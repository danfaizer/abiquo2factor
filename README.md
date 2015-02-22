requires:
mysql
ruby
redis

prepare:
config.yml
mysql -u user -p password -e 'create database token'

start server:
bundle exec rackup

start Resque workers (one per each queue):
TERM_CHILD=1 QUEUE=* COUNT=2 rake resque:workers