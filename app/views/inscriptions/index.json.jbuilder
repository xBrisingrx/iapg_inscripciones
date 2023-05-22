json.data @inscriptions do |inscription|
	json.name inscription.name
	json.company inscription.company
	json.dni inscription.dni
	json.email inscription.email
	json.pay_method inscription.show_pay_method
	json.exposes_work (inscription.exposes_work?) ? 'Si' : 'No'
	json.actions ""
end
