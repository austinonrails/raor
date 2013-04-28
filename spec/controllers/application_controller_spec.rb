require 'spec_helper'

describe ApplicationController do
  context "does not throw exception" do
    # anonymous controller because ApplicationController can't be instantiated
    controller do
      def index
        render :text => 'faker'
      end
    end

    context "with a valid session" do
      login_user

      it "should be successful" do
        get :index
        response.code.should == '200'
      end
    end

    context 'without a valid session' do
      before(:each) do
        get :index
      end

      it "should require authentication" do
        response.code.should_not == '200'
      end

      it "should redirect" do
        response.should redirect_to(new_user_session_path)
      end
    end
  end


  context "throws access denied exception" do
    # anonymous controller because ApplicationController can't be instantiated
    controller do
      def index
        raise CanCan::AccessDenied, 'Access Denied'
      end
    end

    login_user

    it "should redirect to root" do
      get :index
      response.should redirect_to(root_url)
    end
  end
end