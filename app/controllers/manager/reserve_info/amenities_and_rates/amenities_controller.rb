module Manager
  module ReserveInfo
    module AmenitiesAndRates
      class AmenitiesController < ApplicationController
        layout "manager"
        before_action :authenticate_user!
        before_action :confirm_manager!

        def edit
          form = AmenityForm.new(amenity: amenity)
          @presenter = Manager::ReserveInfo::AmenitiesAndRates::AmenityEditPresenter.new(form: form)
        end

        def update
          form = AmenityForm.new(amenity: amenity, params: amenity_params)
          
          respond_to do |format|
            if form.save
              format.turbo_stream { redirect_to manager_reserve_reserve_info_amenities_and_rates_path(current_reserve) }
              format.html { redirect_to manager_reserve_reserve_info_amenities_and_rates_path(current_reserve) }
            else
              @presenter = Manager::ReserveInfo::AmenitiesAndRates::AmenityEditPresenter.new(form: form)

              format.turbo_stream { render turbo_stream: turbo_stream.replace(
                  "modal-content",
                  partial: "modals/amenities/edit_amenity",
                  locals: { presenter: @presenter },
                ),
                status: :unprocessable_entity
              }
              format.html { render template: "edit", status: :unprocessable_entity }
            end
          end
        end

        private

        def amenity
          @amenity ||= current_reserve.amenities.find(params[:id])
        end

        def amenity_params
          params.require(:amenity).permit(
            :id,
            :reserve_id,
            :title,
            :comment,
            :total_capacity,
            :units_type,
            :time_type,
            :sort_order,
            :visible,
            :disable,
            :reserve_id_temp,
            :default_select,
            :show_on_invoice,
            :outside_reservation_system,
            :email_notification_system,
            :email_notification_address,
            :amenities_code,
            :group_number,
            :description,
            :amenities_type,
            :image_url,
          )
        end
      end
    end
  end
end
