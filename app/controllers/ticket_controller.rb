# frozen_string_literal: true

class TicketController < ApplicationController

  before_action :find_ticket, only: %i[show destroy]

  def index
    @tickets = Ticket.all
  end

  def show
    @digsite_info = [] << to_global_array(between_parentheses(@ticket.digsite_info))
    @excavator = @ticket.excavators.first
  end

  def accept
    @ticket = Ticket.find_or_initialize_by(dig_ticket_params)
    if @ticket.save!
      @excavator = @ticket.excavators.find_or_create_by(excavator_params)
      respond_to do |format|
        format.html {redirect_to ticket_show_path(@ticket),
                                 success: 'Ticket created' and return}
      end
    else
      render plain: "Error"
    end
  end

  def destroy
    @ticket.destroy
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'Ticket was successfully destroyed.' }
    end
  end

  private

  def dig_ticket_params
    [ticket_params, response_due_date_time, primary_service_area_code,
     additional_service_area_codes, digsite_info].inject(&:merge)
  end

  def ticket_params
    params.permit('request_number', 'sequence_number', 'request_type' )
  end

  def response_due_date_time
    { response_due_date_time: params.permit( date_times: [:response_due_date_time])
                                  .dig(:date_times, :response_due_date_time) }
  end

  def primary_service_area_code
    { primary_service_area_code:
          params.permit( service_area: [primary_service_area_code: [:sa_code]])
                                     .dig(:service_area, :primary_service_area_code, :sa_code) }
  end

  def additional_service_area_codes
    { additional_service_area_codes:
          params.permit( service_area: [additional_service_area_codes: [sa_code: []]])
                                         .dig(:service_area, :additional_service_area_codes, :sa_code) }
  end

  def digsite_info
    { digsite_info:
          params.permit( excavation_info: [digsite_info: [:well_known_text]])
                        .dig(:excavation_info, :digsite_info, :well_known_text) }
  end

  def excavator_params
    params.require(:excavator).permit( 'company_name', 'crew_onsite' ).
        merge(excavator_param_adress)
  end

  def excavator_param_adress
    { address: params.require(:excavator).
        permit( 'address', 'city', 'state', 'zip' ).values.join(',') }
  end

  def transform(item)
    item.split.map(&:to_f)
  end

  def between_parentheses(digsite_info)
    digsite_info[/\(([^()]*)\)/, 1]
  end

  def to_global_array(info)
    info.split(',').map(&method(:transform))
  end

  def find_ticket
    @ticket = Ticket.find(params[:id])
  end
end
