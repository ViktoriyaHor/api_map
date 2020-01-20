
Rails.application.routes.draw do

  root 'ticket#index'
  match 'accept', to: 'ticket#accept', via: :post
  get 'ticket/:id', to: 'ticket#show', as: 'ticket_show'

end
