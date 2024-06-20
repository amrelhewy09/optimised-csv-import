class CreateActors < ActiveRecord::Migration[7.1]
  def change
    create_table :actors do |t|
      t.string :name
      t.timestamps
    end
    add_index :actors, :name, unique: true
  end
end
