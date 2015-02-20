require "resque"
require "securerandom"
require "./token"

# Resque background task
class Tokenize

  @queue = :tokenize

  def self.perform(username,email)
    token = Token.new(:token => SecureRandom.uuid, :created_at => Time.now, :username => username, :email => email)
    token.save
  end

  Token.auto_upgrade!
  Token.raise_on_save_failure = true

end