class AddIsCeliactoInscription < ActiveRecord::Migration[5.2]
  def change
    add_column :inscriptions, :celiac, :boolean, default:false
  end
end
