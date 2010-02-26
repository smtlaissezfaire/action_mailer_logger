class CreateMailerLogger < ActiveRecord::Migration
  def self.up
    create_table :mailer_logger do |t|
      t.string :class_name
      t.string :method_name
      t.text   :mailer
      t.boolean :delivered
      t.timestamps
    end
  end

  def self.down
    drop_table :mailer_logger
  end
end