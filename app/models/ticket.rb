# frozen_string_literal: true

class Ticket < ApplicationRecord

  has_many :excavators, dependent: :destroy
  validates :digsite_info, presence: true
end
