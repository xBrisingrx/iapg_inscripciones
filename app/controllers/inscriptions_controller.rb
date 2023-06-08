class InscriptionsController < ApplicationController
  skip_before_action :no_login, only: %i[ new create show ]
  before_action :set_inscription, only: %i[ show edit update destroy ]

  # GET /inscriptions or /inscriptions.json
  def index
    @inscriptions = Inscription.actives
    @confirm = Inscription.where(confirm: true).actives.count
  end

  # GET /inscriptions/1 or /inscriptions/1.json
  def show;end

  def credential
    @inscription = Inscription.find(params[:inscription_id])
  end

  # GET /inscriptions/new
  def new
    inscriptions = Inscription.actives
    @inscription = Inscription.new 
    generate_qr
  end

  # GET /inscriptions/1/edit
  def edit
  end

  # POST /inscriptions or /inscriptions.json
  def create
    @inscription = Inscription.new(inscription_params)
    @inscription.celiac = ( !params[:inscription][:celiac].nil? )
    respond_to do |format|
      if @inscription.save
        # generate_credential_qr(@inscription)
        generate_pdf(@inscription)
        # InscriptionNotifierMailer.notifier_inscription(@inscription).deliver_later

        format.json { render json: { status: 'success', msg: 'Registro exitoso', url: te_esperamos_path(@inscription) }, status: :created}
        format.html { redirect_to inscription_url(@inscription), notice: "Inscription was successfully created." }
      else
        format.json { render json: @inscription.errors, status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /inscriptions/1 or /inscriptions/1.json
  def update
    respond_to do |format|
      if @inscription.update(inscription_params)
        format.json { render json: { status: 'success', msg: 'Inscripción editada' }, status: :ok}
        format.html { redirect_to inscription_url(@inscription), notice: "Inscription was successfully updated." }
      else
        format.json { render json: @inscription.errors, status: :unprocessable_entity }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /inscriptions/1 or /inscriptions/1.json
  def destroy
    @inscription.destroy

    respond_to do |format|
      format.html { redirect_to inscriptions_url, notice: "Inscription was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def disable
    @inscription = Inscription.find(params[:inscription_id])

    if @inscription.update(active:false)
      render json: { status: 'success', msg: 'Inscripcion eliminada' }, status: :ok
    else
      render json: { status: 'error', msg: 'Ocurrio un error al realizar la operación' }, status: :unprocessable_entity
    end

    rescue => e
      @response = e.message.split(':')
      render json: { @response[0] => @response[1] }, status: 402
  end

  def generate_credential_qr inscription
    # url = url_for(action: 'credential', inscription_id: inscription.id, only_path: false)
    # url = inscription_credential_path(inscription)
    qrcode = RQRCode::QRCode.new("https://inscripcionessur.iapg.org.ar/inscriptions/#{inscription.id}/credential")
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
      size: 120
    )
    # Attach the QR code to the active storage
    inscription.qrcode.attach(
      io: StringIO.new(png.to_s),
      filename: "qrcode.png",
      content_type: "image/png",
    )

    dir = Rails.root.join("app/assets/images/inscriptions/#{inscription.id}")
    if File.exist?( dir )
      IO.binwrite("#{dir}/inscription_qr.png", png.to_s)
    else
      FileUtils.mkdir_p( dir )
      IO.binwrite("#{dir}/inscription_qr.png", png.to_s)
    end
  end

  def generate_pdf inscription
    receipt_pdf = Prawn::Document.new
    logo = Rails.root.join("app/assets/images/iapg_small.png")
    qr_image = ActiveStorage::Blob.service.path_for(inscription.qrcode.key)
    receipt_pdf.image logo, :at => [150,700], :width => 200

    receipt_pdf.draw_text 'Presente el siguiente QR en mostrador cuando ingrese al evento', at: [10, 550]

    receipt_pdf.image qr_image, :at => [120,500], :width => 300
    receipt_pdf.render_file File.join(Rails.root, "app/assets/images/inscriptions/#{inscription.id}", "inscripcion_iapg.pdf")
  end

  def pdf_inscription 
    inscription = Inscription.find(params[:inscription_id])
    inscription.update( confirm: true )
    dir = Rails.root.join("app/assets/iapg")
    doc = HexaPDF::Document.open("#{dir}/iapg_ticket.pdf")
    page = doc.pages[0]
    canvas = page.canvas(type: :overlay)
    inscription_name = inscription.name
    tf = HexaPDF::Layout::TextFragment.create( inscription_name,
                                            font: doc.fonts.add("Helvetica", variant: :bold), font_size: 18)
    tl = HexaPDF::Layout::TextLayouter.new
    tl.style.align(:center).valign(:top)
    tl.fit([tf], 212, 98).draw(canvas, 1, 80)

    tf_com = HexaPDF::Layout::TextFragment.create( inscription.company,
                                            font: doc.fonts.add("Helvetica"), font_size: 14)
    tl_com = HexaPDF::Layout::TextLayouter.new

    tl_com.style.align(:center).valign(:top)
    tl_com.fit([tf_com], 212, 98).draw(canvas, 1, 40)
    filename = "#{inscription.dni}.pdf"
    doc.write("#{dir}/#{filename}", optimize: true)

    send_file( "#{dir}/#{filename}", filename: filename, type: 'application/pdf', disposition: 'attachment')
  end

  def registrarse;end

  def inscription_list
    @inscriptions = Inscription.actives.where(confirm: true)
  end

  # def send_mails_all_inscripts
  #   @inscriptions = Inscription.actives 
  #   @inscriptions.each do |inscription|
  #     InscriptionNotifierMailer.remember_inscription(inscription).deliver_later
  #     sleep 10
  #   end
  # end

  def generate_qr
    @inscriptions = Inscription.actives
    @inscriptions.each do |inscription|
      # inscription.generate_qrcode
      # generate_pdf inscription
      # generate_credential_qr(inscription)
      generate_pdf(inscription)
    end
    puts "========== fin"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_inscription
      @inscription = Inscription.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def inscription_params
      params.require(:inscription).permit(:company, :name, :email, :dni, :pay_method, :exposes_work, :attended, :file_transfer, :celiac)
    end
end
