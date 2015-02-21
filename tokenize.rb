require "abiquo-api"
require "resque"
require "securerandom"
require "mail"
require "./model"

def update_event(status,event_id)
  begin
    event = Event.get(event_id)
    event.updated_at = Time.now
    event.status = status
    event.save
  rescue => e
    puts e
  end
end

def send_token(token,email)
  options = { :address              => APP_CONFIG['smtp']['smtp_server'],
              :port                 => APP_CONFIG['smtp']['smtp_port'],
              :user_name            => APP_CONFIG['smtp']['smtp_user'],
              :password             => APP_CONFIG['smtp']['smtp_pass'],
              :authentication       => 'plain',
              :enable_starttls_auto => true  }

  Mail.defaults do
    delivery_method :smtp, options
  end

  Mail.deliver do
    to       email
    from     APP_CONFIG['smtp']["mail_from"]
    subject  APP_CONFIG['smtp']["mail_subject"]
    body     "Token: #{token}"
  end
end

# Resque background task
class Tokenize

  @queue = :tokenize

  def self.perform(username,email,event_id)

    
    begin
      abiquo = AbiquoAPI.new(:abiquo_api_url => APP_CONFIG['abiquo']['api_url'], :abiquo_username => APP_CONFIG['abiquo']['api_user'], :abiquo_password => APP_CONFIG['abiquo']['api_pass'])

      enterprises_link = AbiquoAPI::Link.new(:href => '/api/admin/enterprises', :type => 'application/vnd.abiquo.enterprises+json', :client => abiquo)
      enterprises = enterprises_link.get

      $found = false
      $user_id = nil
      $enterprise_id = nil
      enterprises.each do |enterprise|
        users = enterprise.link(:users).get
        users.each do |user|
          if (user.email == email && user.nick == username)
            $user_id = user.id
            $enterprise_id = enterprise.id
            $found = true
            break
          end
        end
        break if $found
      end
    rescue => e
      puts e
      update_event('CONNECTION_ERROR',event_id)
    end

    if $found
      begin
        token = Token.new(:token => SecureRandom.uuid, :created_at => Time.now, :username => username, :email => email, :user_id => $user_id, :enterprise_id => $enterprise_id)
        token.save
        send_token(token.token,token.email)
        update_event('SENT',event_id)
      rescue => e
        puts e
        update_event('DELIVERY_ERROR',event_id)
      end
    else
      update_event('LOOKUP_ERROR',event_id)
    end
  end

end