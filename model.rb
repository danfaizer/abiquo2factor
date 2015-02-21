require "data_mapper"
require "yaml"

APP_CONFIG = YAML.load_file('./config.yml')
connection_string = "mysql://#{APP_CONFIG['mysql']['user']}:#{APP_CONFIG['mysql']['pass']}@#{APP_CONFIG['mysql']['host']}/#{APP_CONFIG['mysql']['db']}"

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

class Event

  include DataMapper::Resource

  property :event_id,    Serial
  property :created_at, DateTime
  property :updated_at, DateTime
  property :username, String
  property :email, String
  property :ip_address, String
  property :status, String

end

Token.auto_upgrade!
Token.raise_on_save_failure = true 
Event.auto_upgrade!
Event.raise_on_save_failure = true 