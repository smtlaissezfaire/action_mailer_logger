class ActionMailerLoggerGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.directory          "models"
      m.file               "models/mailer_logger.rb", "app/models/mailer_logger.rb"
      m.migration_template "migrate/create_mailer_logger.rb", "db/migrate", {
        :migration_file_name => 'create_mailer_logger',
      }
    end
  end
end
