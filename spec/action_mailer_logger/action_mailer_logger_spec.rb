require "spec_helper"

ActionMailer::Base.template_root = File.dirname(__FILE__) + "/templates"
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

describe ActionMailer do
  before do
    ActionMailerLogger.logging_class = MailerLogger
    MailerLogger.delete_all
  end

  it "should deliver email normally" do
    lambda {
      UserMailer.deliver_signup
    }.should change { ActionMailer::Base.deliveries.size }.by(1)
  end

  it "should be able to set the logging class" do
    a_class = Class.new
    ActionMailerLogger.logging_class = a_class
    ActionMailerLogger.logging_class.should == a_class
  end

  it "should log when an email gets sent" do
    lambda {
      UserMailer.deliver_signup
    }.should change { MailerLogger.count }.by(1)
  end

  it "should log the class name" do
    UserMailer.deliver_signup
    MailerLogger.find(:first).class_name.should == "UserMailer"
  end

  it "should log the mailer's method_name" do
    UserMailer.deliver_signup
    MailerLogger.find(:first).method_name.should == "signup"
  end

  it "should serialize the tmail object" do
    UserMailer.deliver_signup
    MailerLogger.find(:first).mailer.should be_a_kind_of(TMail::Mail)
  end

  it "should set the delivered to true" do
    UserMailer.deliver_signup
    MailerLogger.find(:first).delivered.should be_true
  end

  class FailedMailer < ActionMailer::Base
    def signup
    end

    def perform_delivery_test(*args)
      raise "error"
    end
  end

  it "should set delivered to false if there is a delivery error" do
    FailedMailer.raise_delivery_errors = false
    FailedMailer.deliver_signup
    MailerLogger.find(:first).delivered.should be_false
  end

  it "should log failed emails even when raise_delivery_errors = true" do
    FailedMailer.raise_delivery_errors = true

    begin
      FailedMailer.deliver_signup
    rescue
    end

    MailerLogger.find(:first).delivered.should be_false
  end
end