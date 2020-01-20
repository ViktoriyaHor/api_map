class TicketController < ApplicationController

  before_action :find_ticket, only: %i[show destroy]
  skip_before_action :verify_authenticity_token, if: :accept

  def index
    @tickets = Ticket.all
  end

  def show

  end

  def accept
    @ticket = Ticket.create(ticket_params)
    #@excavator = @ticket.excavators.find_or_create_by(excavator_params)
  end

  def destroy
    @ticket.destroy
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'Ticket was successfully destroyed.' }
    end
  end

  private

  def ticket_params

  end

  def permit_params
    params.permit('RequestNumber', 'SequenceNumber', 'RequestType',
                  'DateTimes' => 'ResponseDueDateTime',
                  'ServiceArea' => { 'PrimaryServiceAreaCode' => 'SACode',
                                    'AdditionalServiceAreaCodes' => 'SACode'},
                  'ExcavationInfo' => { 'DigsiteInfo' => 'WellKnownText' }
    )
  end

  #def excavator_params
  #  params.permit( :Excavator => { :CompanyName, :Address, :City, :State, :Zip, :CrewOnsite } )
  #end

  def find_ticket
    @ticket = Ticket.find(params[:id])
  end
end
