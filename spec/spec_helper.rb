require "action_mailer"
require File.dirname(__FILE__) + "/../lib/action_mailer_logger"

ActionMailer::Base.template_root = File.dirname(__FILE__) + "/action_mailer_logger/templates"
ActionMailer::Base.delivery_method = :test

class UserMailer < ActionMailer::Base
  def signup
    from        "foo@example.com"
    recipients  "bar@example.com"
    subject     "TEST"
    sent_on     Time.now.utc
  end
end

require "active_record"

class MailerLogger < ActiveRecord::Base
  serialize :mailer
end

ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database  => ':memory:'
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :mailer_loggers, :force => true do |t|
    t.string :class_name
    t.string :method_name
    t.text   :mailer
    t.boolean :delivered
    t.timestamps
  end
end

