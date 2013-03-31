require 'lib/database_setup.rb'

module DatabaseAware
  include DatabaseSetup

  def self.included(base)
    class << base
      db_file = File.join(File.dirname(__FILE__), '..', 'db', 'breadstore.db')
      @@db = SQLite3::Database.new db_file
      DatabaseSetup.setup(@@db)

      def db
        @@db
      end
    end

    base.send(:extend, ClassMethods)
    base.send(:include, InstanceMethods)

    base.class_variables.inspect
    base.instance_variables.inspect
  end

  module ClassMethods
    def columns
      columns = db.execute "PRAGMA table_info(#{self.table_name})"
      columns.shift
      columns.map! {|column| column[1]}.join(", ")
    end

    def table_name
      self.name.downcase + "s"
    end
  end

  module InstanceMethods
    def attr_values
      this = self
      columns = self.class.columns.split(", ")
      columns.map {|attribute| "'#{this.send(attribute)}'"}.join(", ")
    end

    def save
      self.class.db.execute "INSERT INTO #{self.class.table_name} (#{self.class.columns}) VALUES(#{attr_values})"
    end
  end
end

