class InscriptionNotifierMailer < ApplicationMailer
	# default :from => 'mdavid.almiron@gmail.com'
	default :from => 'soporte@maurosampaoli.com.ar'

  # send a signup email to the user, pass in the user object that   contains the user's email address
  def notifier_test
    mail( :to => 'web@maurosampaoli.com.ar',
    :subject => 'Registro exitoso' )
  end
 
  def notifier_inscription inscription
  	@inscription = inscription
  	attachments['inscripcion_iapg.pdf'] = File.read( Rails.root.join("app/assets/images/inscriptions/#{@inscription.id}/inscripcion_iapg.pdf"))
    mail( :to => inscription.email,
    :subject => 'Registro exitoso' )
  end
end
