json.extract! inscription, :id, :company, :name, :email, :dni, :pay_method, :exposes_work, :attended, :created_at, :updated_at
json.url inscription_url(inscription, format: :json)
