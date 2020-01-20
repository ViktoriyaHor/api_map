class Ticket < ApplicationRecord

  has_many :excavators, dependent: :destroy
end
