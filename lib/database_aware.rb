require_relative 'database_setup.rb'

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
  end

  module ClassMethods
    def all
      wrap_results(db.execute "SELECT * from #{table_name}")
    end

    def columns(with_id = false)
      columns = db.execute "PRAGMA table_info(#{self.table_name})"
      columns.shift unless with_id
      columns.map! {|column| column[1] }.join(", ")
    end

    def delete(ids)
      if ids.is_a? Array
        ids = ids.join(", ")
      end

      db.execute "DELETE from #{table_name} WHERE id IN (#{ids})"
    end

    def find_attribute_with_values(attribute, values)
      column = attribute
      values = values.map {|value| "'#{value}'" }.join(", ")

      wrap_results(db.execute "SELECT * from #{table_name} where #{column} IN (#{values})")
    end

    # needs handling for multi-word names to be underscored
    def table_name
      self.name.downcase + "s"
    end

    def wrap_results(results)
      column_set = columns(true).split(", ")

      results.map do |result|
        hs = {}

        result.each_with_index do |field, id|
          hs[column_set[id].downcase.to_sym] = field
        end

        hs
      end
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

