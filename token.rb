require "data_mapper"
require 'yaml'

$CONFIG = YAML.load_file('./config.yml')
connection_string = "mysql://#{$CONFIG['mysql']['user']}:#{$CONFIG['mysql']['pass']}@#{$CONFIG['mysql']['host']}/#{$CONFIG['mysql']['db']}"

# Token model creation
DataMapper.setup(:default, connection_string)
DataMapper.finalize

class Token

  include DataMapper::Resource

  property :token_id,    Serial
  property :token, String
  property :created_at, DateTime
  property :username, String
  property :email, String
  property :enabled, Boolean, :default  => false
  property :enterprise_id, Integer
  property :user_id, Integer

end

Token.auto_upgrade!
Token.raise_on_save_failure = true 