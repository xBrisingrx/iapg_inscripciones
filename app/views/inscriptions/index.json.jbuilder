json.data @inscriptions do |inscription|
	json.name inscription.name
	json.company inscription.company
	json.dni inscription.dni
	json.email inscription.email
	json.pay_method inscription.pay_method
	json.exposes_work inscription.exposes_work
	json.actions "#{ link_to '<i class="fa fa-edit"></i>'.html_safe, edit_inscription_path(inscription), 
									remote: :true, class: 'btn btn-sm u-btn-primary text-white', title: 'Editar' } 
								<button class='btn btn-sm u-btn-red text-white' 
  								title='Eliminar' 
  								onclick='modal_disable_inscription( #{ inscription.id } )'>
									<i class='fa fa-trash-o' aria-hidden='true'></i></button> "
end
