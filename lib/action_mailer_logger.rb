require "action_mailer"

class ActionMailerLogger
  class << self
    attr_accessor :logging_class
  end
end

ActionMailer::Base.class_eval do
  alias_method :initialize_aliased_by_action_mailer_logger, :initialize

  def initialize(method_name=nil, *parameters) #:nodoc:
    @method_name = method_name
    initialize_aliased_by_action_mailer_logger(method_name, *parameters)
  end

  def deliver!(mail = @mail)
    raise "no mail object available for delivery!" unless mail
    unless logger.nil?
      logger.info  "Sent mail to #{Array(recipients).join(', ')}"
      logger.debug "\n#{mail.encoded}"
    end

    begin
      __send__("perform_delivery_#{delivery_method}", mail) if perform_deliveries
      log_success(mail)
    rescue Exception => e  # Net::SMTP errors or sendmail pipe errors
      log_failure(mail)
      raise e if raise_delivery_errors
    end

    return mail
  end

private

  def log_success(mail)
    database_log(mail, true)
  end

  def log_failure(mail)
    database_log(mail, false)
  end

  def database_log(mail, delivered)
    ActionMailerLogger.logging_class.create!({
      :class_name   => self.class.to_s,
      :method_name  => @method_name,
      :mailer       => mail,
      :delivered    => delivered
    })
  end
end