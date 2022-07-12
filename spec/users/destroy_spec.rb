require 'rails_helper'

RSpec.describe "users#destroy", type: :request do
  subject(:make_request) do
    jsonapi_delete "/users/#{user.id}"
  end

  describe 'basic destroy' do
    let!(:user) { create(:user) }

    before { allow_any_instance_of(Auth).to receive(:current_user).and_return(user) }

    it 'fake deletes the resource' do
      expect(UserResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to have_enqueued_job
      expect { user.reload }
        .to change { user.delete_requested_at }
      expect(json).to eq('meta' => {})
    end
  end
end
