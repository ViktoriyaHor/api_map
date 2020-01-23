class TicketController < ApplicationController

  before_action :find_ticket, only: %i[show destroy]

  def index
    @tickets = Ticket.all
  end

  def show
    @id = @ticket.id
    @digsite_info = [] << to_global_array(between_parentheses(@ticket.digsite_info))
  end

  def accept
    @ticket = Ticket.find_or_initialize_by(dig_ticket_params)
    if @ticket.save!
      @excavator = @ticket.excavators.find_or_create_by(excavator_params)
      respond_to do |format|
        format.html {redirect_to ticket_show_path(@ticket), success: 'Ticket created' and return}
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
    { primary_service_area_code: params.permit( service_area: [primary_service_area_code: [:sa_code]])
                                     .dig(:service_area, :primary_service_area_code, :sa_code) }
  end

  def additional_service_area_codes
    { additional_service_area_codes: params.permit( service_area: [additional_service_area_codes: [sa_code: []]])
                                         .dig(:service_area, :additional_service_area_codes, :sa_code) }
  end

  def digsite_info
    { digsite_info: params.permit( excavation_info: [digsite_info: [:well_known_text]])
                        .dig(:excavation_info, :digsite_info, :well_known_text) }
  end

  def excavator_params
    params.require(:excavator).permit( 'company_name', 'crew_onsite' ).merge(excavator_param_adress)
  end

  def excavator_param_adress
    { address: params.require(:excavator).permit( 'address', 'city', 'state', 'zip' ).values.join(',') }
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

#p = 'POLYGON((-81.13390268058475 32.07206917625161,-81.14660562247929 32.04064386441295,-81.08858407706913 32.02259853170128,-81.05322183341679 32.02434500961698,-81.05047525138554 32.042681017283066,-81.0319358226746 32.06537765335268,-81.01202310294804 32.078469305179404,-81.02850259513554 32.07963291684719,-81.07759774894413 32.07090546831167,-81.12154306144413 32.08806865844325,-81.13390268058475 32.07206917625161))'
#p[/\(([^()]*)\)/, 1]
#
#
#p.split(',').map(&method(:transform))
#
#[
#    [-67.13734351262877, 45.137451890638886],
#    [-66.96466, 44.8097],
#    [-68.03252, 44.3252],
#    [-69.06, 43.98],
#    [-70.11617, 43.68405],
#    [-70.64573401557249, 43.090083319667144],
#    [-70.75102474636725, 43.08003225358635],
#    [-70.79761105007827, 43.21973948828747],
#    [-70.98176001655037, 43.36789581966826],
#    [-70.94416541205806, 43.46633942318431],
#    [-71.08482, 45.3052400000002],
#    [-70.6600225491012, 45.46022288673396],
#    [-70.30495378282376, 45.914794623389355],
#    [-70.00014034695016, 46.69317088478567],
#    [-69.23708614772835, 47.44777598732787],
#    [-68.90478084987546, 47.184794623394396],
#    [-68.23430497910454, 47.35462921812177],
#    [-67.79035274928509, 47.066248887716995],
#    [-67.79141211614706, 45.702585354182816],
#    [-67.13734351262877, 45.137451890638886]
#]