class InscriptionNotifierMailer < ApplicationMailer
	# default :from => 'mdavid.almiron@gmail.com'
	default :from => 'seccionalsur@iapg.org.ar'

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

  def remember_inscription inscription_id, inscription_email
    attachments['inscripcion_iapg.pdf'] = File.read( Rails.root.join("app/assets/images/inscriptions/#{inscription_id}/inscripcion_iapg.pdf"))
    mail( :to => inscription_email,
    :subject => 'Recordatorio evento de jovenes profesionales' )
  end
end
