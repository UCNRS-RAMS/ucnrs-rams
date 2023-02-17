module Manager
  module ReserveInfo
    module AmenitiesAndRates
      class AmenitiesController < Manager::ApplicationController
        layout "manager"
        before_action :authenticate_user!
        before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }
        before_action :is_administrator!, only: [:create, :update]

        def new
          form = AmenityForm.new(params: { reserve_id: current_reserve.id })
          @presenter = Manager::ReserveInfo::AmenitiesAndRates::AmenityNewPresenter.new(form: form)
        end

        def create
          form = AmenityForm.new(params: amenity_params.merge(reserve_id: current_reserve.id))

          if form.save
            redirect_to manager_reserve_reserve_info_amenities_and_rates_path(current_reserve)
          else
            @presenter = Manager::ReserveInfo::AmenitiesAndRates::AmenityNewPresenter.new(form: form)
            render :new, status: :unprocessable_entity
          end
        end

        def edit
          form = AmenityForm.new(amenity: amenity)
          @presenter = Manager::ReserveInfo::AmenitiesAndRates::AmenityEditPresenter.new(form: form)
        end

        def update
          form = AmenityForm.new(amenity: amenity, params: amenity_params)

          if form.save
            redirect_to manager_reserve_reserve_info_amenities_and_rates_path(current_reserve)
          else
            @presenter = Manager::ReserveInfo::AmenitiesAndRates::AmenityEditPresenter.new(form: form)
            render :edit, status: :unprocessable_entity
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
            :listing_photo,
            :listing_photo_cache,
          )
        end
      end
    end
  end
end
