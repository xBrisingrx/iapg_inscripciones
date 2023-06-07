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
    qrcode = RQRCode::QRCode.new( "http://192.168.1.10:3000/inscriptions/#{inscription.id}/credential" )
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

  def pdf_inscription 
    inscription = Inscription.find(params[:inscription_id])
    dir = Rails.root.join("app/assets/iapg")
    doc = HexaPDF::Document.open("#{dir}/iapg_ticket.pdf")
    page = doc.pages[0]
    canvas = page.canvas(type: :overlay)
    if inscription.name.split.count > 2
      large_text = inscription.name.split
      inscription_name = "#{large_text[0]} #{large_text[2]}"
    else
      inscription_name = inscription.name
    end
    
    # canvas.font('Helvetica', size: 18, variant: :bold).text(inscription_name, at: [30, 70])
    tf = HexaPDF::Layout::TextFragment.create( inscription_name,
                                            font: doc.fonts.add("Helvetica"), font_size: 18)
    tl = HexaPDF::Layout::TextLayouter.new
    tl.style.align(:center).valign(:top)
    tl.fit([tf], 212, 98).draw(canvas, 1, 80)

    tf_com = HexaPDF::Layout::TextFragment.create( inscription.company,
                                            font: doc.fonts.add("Helvetica"), font_size: 14)
    tl_com = HexaPDF::Layout::TextLayouter.new

    tl_com.style.align(:center).valign(:top)
    tl_com.fit([tf_com], 212, 98).draw(canvas, 1, 40)
    # if inscription.company.length > 24
    #   large_text = inscription.company.split
    #   y = 50
    #   company_name = ''
    #   large_text.each do |text|
    #     company_name += "#{text} "
    #     if company_name.length > 24
    #       # canvas.font('Helvetica', size: 12).text(company_name, at: [25, y])
    #       tf = HexaPDF::Layout::TextFragment.create( company_name,
    #                                         font: doc.fonts.add("Helvetica"), font_size: 12)
    #       tl = HexaPDF::Layout::TextLayouter.new
    #       tl.style.align(:center).valign(:top)
    #       tl.fit([tf], 212, 98).draw(canvas, 1, y)
    #       y -= 15
    #       company_name = ''
    #     end
    #   end
    #   y -= 15
    #   # canvas.font('Helvetica', size: 12).text(company_name, at: [25, y])
    #   tf = HexaPDF::Layout::TextFragment.create( company_name,
    #                                         font: doc.fonts.add("Helvetica"), font_size: 12)
    #   tl = HexaPDF::Layout::TextLayouter.new
    #   tl.style.align(:center).valign(:top)
    #   tl.fit([tf], 212, 98).draw(canvas, 1, y)
    # else
    #   # canvas.font('Helvetica', size: 14).text(inscription.company, at: [10, 30])
    #   tf = HexaPDF::Layout::TextFragment.create( inscription.company,
    #                                         font: doc.fonts.add("Helvetica"), font_size: 14)
    #   tl = HexaPDF::Layout::TextLayouter.new

    #   tl.style.align(:center).valign(:top)
    #   tl.fit([tf], 212, 98).draw(canvas, 1, 40)
    #   # canvas.stroke_color(1, 1, 1).rectangle(0, 0, 25, 30)
    # end
    # rectangulo para el contenido del pdf
    # canvas.stroke_color(128, 0, 0).rectangle(2, 5, 208, 90).stroke 

    filename = "#{inscription.dni}.pdf"
    doc.write("#{dir}/#{filename}", optimize: true)

    # custom_pdf = Prawn::Document.new(:page_size => [212,98])
    # custom_pdf.bounding_box([0, 98], width: 212, height: 98) do
    #   text 'This text is flowing from the left. ', align: :center

    #   move_down 10
    #   text 'This text is flowing from the center. ' * 3, align: :center

    #   transparent(0.5) { stroke_bounds }
    # end
    # custom_pdf.draw_text 'un buen texto al medio', at: [50, 50]
    # tl = HexaPDF::Layout::TextLayouter.new
    # tl.style.align(:center).valign(:top)
    # tl.fit([tf], 200, 40).draw(canvas, 30, 70)
    # canvas.rectangle(0, 0, 0).rectangle(58, 431, 495, 30)
    # custom_pdf.float do 
    #   custom_pdf.text inscription.name, align: :center, valing: :top
    # end
    # custom_pdf.text inscription.company, valing: :bottom
    # custom_pdf.render_file File.join(Rails.root, "app/assets/iapg", "customisado.pdf")
    pdf_custom(dir)
    send_file( "#{dir}/#{filename}", filename: filename, type: 'application/pdf', disposition: 'attachment')
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
