class CreateMailerLogger < ActiveRecord::Migration
  def self.up
    create_table :mailer_loggers do |t|
      t.string  :class_name
      t.string  :method_name
      t.text    :mailer
      t.boolean :delivered
      t.timestamps
    end
  end

  def self.down
    drop_table :mailer_loggers
  end
end