require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe SchoolsController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # School. As you add validations to School, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    { urn: 12345, name: 'test school' }
  }

  let(:invalid_attributes) {
    { name: nil }
  }

  context "As an admin user" do
    before(:each) do
      sign_in_user(:admin)
    end
    describe "GET #index" do
      it "assigns schools that are enrolled as @schools_enrolled" do
        school = FactoryGirl.create :school, enrolled: true
        get :index, params: {}
        expect(assigns(:schools_enrolled)).to eq([school])
      end
      it "assigns schools that haven't enrolled as @schools_not_enrolled" do
        school = FactoryGirl.create :school, enrolled: false
        get :index, params: {}
        expect(assigns(:schools_not_enrolled)).to eq([school])
      end
    end

    describe "GET #show" do
      context "the school is not enrolled" do
        context "user cannot manage school" do
          it "redirects to the enrol page" do
            sign_in_user(:guest)
            school = FactoryGirl.create :school, enrolled: false
            get :show, params: {id: school.to_param}
            expect(response).to redirect_to(enrol_path)
          end
        end
      end
      context "the school is enrolled" do
        it "assigns the requested school as @school" do
          school = FactoryGirl.create :school
          get :show, params: { id: school.to_param }
          expect(assigns(:school)).to eq(school)
        end
        it "assigns the school's meters as @meters" do
          school = FactoryGirl.create :school
          meter = FactoryGirl.create :meter, school_id: school.id
          get :show, params: { id: school.to_param }
          expect(assigns(:meters)).to include(meter)
        end
        it "assigns the latest activities as @activities" do
          school = FactoryGirl.create :school
          activity = FactoryGirl.create :activity, school_id: school.id
          get :show, params: { id: school.to_param }
          expect(assigns(:activities)).to include(activity)
        end
        it "does not include activities from other schools" do
          school = FactoryGirl.create :school
          other_school = FactoryGirl.create :school
          FactoryGirl.create :activity, school_id: school.id
          activity_other_school = FactoryGirl.create :activity, school_id: other_school.id
          get :show, params: { id: school.to_param }
          expect(assigns(:activities)).not_to include activity_other_school
        end
      end
    end

    describe "GET #new" do
      it "assigns a new school as @school" do
        get :new, params: {}
        expect(assigns(:school)).to be_a_new(School)
      end
    end

    describe "GET #edit" do
      it "assigns the requested school as @school" do
        school = FactoryGirl.create :school
        get :edit, params: { id: school.to_param }
        expect(assigns(:school)).to eq(school)
      end
    end

    describe "POST #create" do
      context "with valid params" do
        it "creates a new School" do
          expect {
            post :create, params: { school: valid_attributes }
          }.to change(School, :count).by(1)
        end
        it "assigns a newly created school as @school" do
          post :create, params: { school: valid_attributes }
          expect(assigns(:school)).to be_a(School)
          expect(assigns(:school)).to be_persisted
        end
        it "creates a calendar for the new School" do
          post :create, params: { school: valid_attributes }
          expect(assigns(:school).calendar).not_to be_nil
        end

        it "redirects to the created school" do
          post :create, params: { school: valid_attributes }
          expect(response).to redirect_to(School.last)
        end
      end

      context "with invalid params" do
        it "assigns a newly created but unsaved school as @school" do
          post :create, params: { school: invalid_attributes }
          expect(assigns(:school)).to be_a_new(School)
        end

        it "re-renders the 'new' template" do
          post :create, params: { school: invalid_attributes }
          expect(response).to render_template("new")
        end
      end
    end

    describe "PUT #update" do
      context "with valid params" do
        let(:new_attributes) {
          { name: 'new name' }
        }

        it "updates the requested school" do
          school = FactoryGirl.create :school
          put :update, params: { id: school.to_param, school: new_attributes }
          school.reload
          expect(school.name).to eq new_attributes[:name]
        end

        it "assigns the requested school as @school" do
          school = FactoryGirl.create :school
          put :update, params: { id: school.to_param, school: valid_attributes }
          expect(assigns(:school)).to eq(school)
        end

        it "redirects to the school" do
          school = FactoryGirl.create :school
          put :update, params: { id: school.to_param, school: valid_attributes }
          expect(response).to redirect_to(school)
        end
      end

      context "with invalid params" do
        it "assigns the school as @school" do
          school = FactoryGirl.create :school
          put :update, params: { id: school.to_param, school: invalid_attributes }
          expect(assigns(:school)).to eq(school)
        end

        it "re-renders the 'edit' template" do
          school = FactoryGirl.create :school
          put :update, params: { id: school.to_param, school: invalid_attributes }
          expect(response).to render_template("edit")
        end
      end
    end

    describe "DELETE #destroy" do
      it "destroys the requested school" do
        school = FactoryGirl.create :school
        expect {
          delete :destroy, params: { id: school.to_param }
        }.to change(School, :count).by(-1)
      end

      it "redirects to the schools list" do
        school = FactoryGirl.create :school
        delete :destroy, params: { id: school.to_param }
        expect(response).to redirect_to(schools_url)
      end
    end

    describe "GET #usage" do
      let!(:school) { FactoryGirl.create :school }
      let(:period) { :daily }
      it "assigns the requested school as @school" do
        get :usage, params: { id: school.to_param, period: period }
        expect(assigns(:school)).to eq(school)
      end
      context "to_date is specified" do
        let(:to_date) { Date.current - 1.days }
        it "assigns to_date to @to_date" do
          get :usage, params: { id: school.to_param, period: period, to_date: to_date }
          expect(assigns(:to_date)).to eq to_date
        end
      end
      context "to_date is not specified" do
        it "assigns yesterday's date to  @to_date" do
          get :usage, params: { id: school.to_param, period: period }
          expect(assigns(:to_date)).to eq Date.current - 1.days
        end
      end
      context "period is 'daily'" do
        let(:period) { :daily }
        it "renders the daily_usage template" do
          get :usage, params: { id: school.to_param, period: period }
          expect(response).to render_template('daily_usage')
        end
      end
      context "period is 'hourly'" do
        let(:period) { :hourly }
        it "renders the hourly_usage template" do
          get :usage, params: { id: school.to_param, period: period }
          expect(response).to render_template('hourly_usage')
        end
      end
    end
  end
end
