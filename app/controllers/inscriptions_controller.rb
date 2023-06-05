class InscriptionsController < ApplicationController
  skip_before_action :no_login, only: %i[ new create show ]
  before_action :set_inscription, only: %i[ show edit update destroy ]

  # GET /inscriptions or /inscriptions.json
  def index
    @inscriptions = Inscription.actives
  end

  # GET /inscriptions/1 or /inscriptions/1.json
  def show;end

  def credential
    @inscription = Inscription.find(params[:inscription_id])
  end

  # GET /inscriptions/new
  def new
    inscriptions = Inscription.actives
    @limit = ( inscriptions.count >= 90 )
    @inscription = Inscription.new 
  end

  # GET /inscriptions/1/edit
  def edit
    POS::Printer.print('nexus-1') do |p|
      p.align_center
      p.print_logo
      p.big_font
      p.text 'MY HEADER'
      p.align_left
      p.small_font
      p.text 'some body'
    end
  end

  # POST /inscriptions or /inscriptions.json
  def create
    @inscription = Inscription.new(inscription_params)
    @inscription.celiac = ( !params[:inscription][:celiac].nil? )
    respond_to do |format|
      if @inscription.save
        generate_credential_qr(@inscription)
        generate_pdf(@inscription)
        InscriptionNotifierMailer.notifier_inscription(@inscription).deliver_later

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
    url = url_for(action: 'credential', inscription_id: inscription.id, only_path: false)
    # url = inscription_credential_path(inscription)
    qrcode = RQRCode::QRCode.new( "http://200.24.249.87:3050/inscriptions/#{inscription.id}/credential" )
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

    receipt_pdf.draw_text 'Presente el siguiente QR en mostrador al momento de ir al evento', at: [10, 550]

    receipt_pdf.image qr_image, :at => [120,500], :width => 300
    receipt_pdf.render_file File.join(Rails.root, "app/assets/images/inscriptions/#{inscription.id}", "inscripcion_iapg.pdf")
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
