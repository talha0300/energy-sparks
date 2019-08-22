module Schools
  class PupilsController < ApplicationController
    load_and_authorize_resource :school

    def new
      @pupil = @school.users.pupil.new
      authorize! :create, @pupil
    end

    def create
      @pupil = User.new_pupil(@school, pupil_params)
      if @pupil.save
        redirect_to school_users_path(@school)
      else
        render :new
      end
    end

    def edit
      @pupil = @school.users.pupil.find(params[:id])
      authorize! :edit, @pupil
    end

    def update
      @pupil = @school.users.pupil.find(params[:id])
      authorize! :update, @pupil
      if @pupil.update(pupil_params)
        redirect_to school_users_path(@school)
      else
        render :edit
      end
    end

    private

    def pupil_params
      params.require(:user).permit(:name, :pupil_password)
    end
  end
end
