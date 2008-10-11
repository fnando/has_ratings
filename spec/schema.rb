ActiveRecord::Schema.define(:version => 0) do
  create_table :users do |t|
    t.string :name
  end
  
  create_table :beers do |t|
    t.string :name
    t.float :rating, :precision => 3, :scale => 2, :default => 0, :null => false
    t.integer :ratings_count, :default => 0, :null => false
  end
  
  create_table :donuts do |t|
    t.string :flavor
    t.float :rating, :precision => 3, :scale => 2, :default => 0, :null => false
    t.integer :ratings_count, :default => 0, :null => false
  end
  
  create_table :ratings do |t|
    t.integer :rating, :default => 0, :null => false
    t.references :rateable, :polymorphic => true
    t.references :user
    t.timestamps
  end
end