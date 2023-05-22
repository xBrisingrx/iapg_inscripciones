# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  name            :string(255)      not null
#  username        :string(255)      not null
#  email           :string(255)      not null
#  rol             :integer          default("consulta")
#  password_digest :string(255)
#  active          :boolean          default(TRUE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class User < ApplicationRecord
	has_secure_password

	validates :name, presence: true
	validates :username, presence: true, 
		uniqueness: { case_sensitive: false, message: "Este usuario ya se encuentra registrado" },
    length: { in: 3..15 },
    format: {
      with: /\A[a-z0-9A-Z]+\z/,
      message: :invalid
    }
	validates :password_digest, presence: true, length: { minimum: 6 }
	validates :email, presence: true, 
		uniqueness: { case_sensitive: false, message: "Este email ya se encuentra en uso" },
    format: {
      with: /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i,
      message: :invalid
    }

  before_save :downcase_attributes

  scope :actives, -> { where(active: true) }
  
  enum rol: {
    admin: 1, 
    consulta: 2
  }

  private

  def downcase_attributes
    self.username = username.downcase
    self.email = email.downcase
  end
end
