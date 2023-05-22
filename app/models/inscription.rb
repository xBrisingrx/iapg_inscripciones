class Inscription < ApplicationRecord
	has_one_attached :file_transfer
	has_one_attached :qrcode
	validates :name, presence: true 
	validates :company, presence: true 
	validates :email, presence: true, 
    format: {
      with: /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i,
      message: 'Ingrese un correo valido'
    }

  validates :pay_method, presence: { message: 'Seleccione un metodo de pago' }
  validates :dni, presence: true,
  	numericality: { only_integer: true, message: 'Ingrese su numero de dni sin puntos' }

  before_commit :generate_qrcode, on: :create

  enum pay_method: {
    credit_card: 1, 
    transfer: 2
  }

  def show_pay_method
    if self.pay_method == 'credit_card'
      'Tarjeta de credito'
    else
      'Transferencia'
    end
  end
  
  private
  
  def generate_qrcode
    # Get the host
    # host = Rails.application.routes.default_url_options[:host]
    # host = Rails.application.config.action_controller.default_url_options[:host]
    
    # Create the QR code object
    # qrcode = RQRCode::QRCode.new("http://#{host}/posts/#{id}")
    qrcode = RQRCode::QRCode.new("http://200.24.249.87:3050/inscriptions/#{self.id}/credential")

    # Create a new PNG object
    png = qrcode.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: "black",
      file: nil,
      fill: "white",
      module_px_size: 6,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: 120,
    )

    # Attach the QR code to the active storage
    self.qrcode.attach(
      io: StringIO.new(png.to_s),
      filename: "qrcode.png",
      content_type: "image/png",
    )
  end
end
