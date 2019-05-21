class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :external_id
      t.string :login
      t.string :name
      t.text :jsonObject

      t.timestamps
    end
  end
end
