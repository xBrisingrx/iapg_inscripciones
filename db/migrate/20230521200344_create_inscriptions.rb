class CreateInscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :inscriptions do |t|
      t.string :company
      t.string :name
      t.string :email
      t.string :dni
      t.integer :pay_method
      t.integer :exposes_work
      t.boolean :attended

      t.timestamps
    end
  end
end
