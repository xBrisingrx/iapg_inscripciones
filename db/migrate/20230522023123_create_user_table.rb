class CreateUserTable < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :username, null: false
      t.string :email, null: false
      t.integer :rol, default: 2
      t.string :password_digest
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
