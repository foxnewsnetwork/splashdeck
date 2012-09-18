require 'spec_helper'

describe PagesController do

  describe "GET 'legal'" do
    it "returns http success" do
      get 'legal'
      response.should be_success
    end
  end

  describe "GET 'about'" do
    it "returns http success" do
      get 'about'
      response.should be_success
    end
  end

end
