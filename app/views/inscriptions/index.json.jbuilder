json.data @inscriptions do |inscription|
	json.name inscription.name
	json.company inscription.company
	json.dni inscription.dni
	json.email inscription.email
	json.pay_method ''
	json.celiac (inscription.celiac?) ? 'Si' : 'No'
	json.actions "<a class='btn btn-danger btn-sm text-white' data-toggle='tooltip' title='Dar de baja' onclick='modal_disable_inscription( #{ inscription.id } )'>
                    <i class='fa fa-trash' aria-hidden='true'></i> </a>"
end
