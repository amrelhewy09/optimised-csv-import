class CreateMovies < ActiveRecord::Migration[7.1]
  def change
    create_table :movies do |t|
      t.string :name
      t.string :description
      t.string :year
      t.references :director, null: false, foreign_key: true
      t.string :filming_location
      t.string :country
      t.timestamps
    end
    add_index :movies, :name, unique: true
  end
  
end
