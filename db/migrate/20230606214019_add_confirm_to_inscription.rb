class AddConfirmToInscription < ActiveRecord::Migration[5.2]
  def change
    add_column :inscriptions, :confirm, :boolean, default:false
  end
end
