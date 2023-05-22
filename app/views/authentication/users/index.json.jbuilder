json.data @users do |user|
	json.name user.name
	json.email user.email
	json.username user.username
	json.rol user.rol
	json.actions "#{ link_to '<i class="fa fa-edit"></i>'.html_safe, edit_user_path(user), remote: :true, class: 'btn btn-sm u-btn-primary text-white', title: 'Editar' } 
								<button class='btn btn-sm u-btn-red text-white' 
  								title='Eliminar' 
  								onclick='modal_disable_user( #{ user.id } )'>
									<i class='fa fa-trash-o' aria-hidden='true'></i></button> "
end
