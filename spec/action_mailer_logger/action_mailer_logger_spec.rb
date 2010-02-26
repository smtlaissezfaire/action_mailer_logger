require "spec_helper"

describe ActionMailer do
  before do
    MailerLogger.delete_all
  end

  it "should deliver email normally" do
    lambda {
      UserMailer.deliver_signup
    }.should change { ActionMailer::Base.deliveries.size }.by(1)
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