json.data @inscriptions do |inscription|
	json.name inscription.name
	json.company inscription.company
	json.dni inscription.dni
	json.email inscription.email
	json.pay_method ''
	json.celiac (inscription.celiac?) ? 'Si' : 'No'
	json.actions ""
end
