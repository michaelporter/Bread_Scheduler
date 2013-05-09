module DatabaseSetup
  def self.setup(db)
    db.execute "CREATE TABLE IF NOT EXISTS breads(
                  Id INTEGER PRIMARY KEY AUTOINCREMENT, 
                  name TEXT, 
                  rise FLOAT, 
                  bake FLOAT, 
                  loaves INTEGER, 
                  pan BOOLEAN, 
                  pan_rise FLOAT
                )"
  end
end
