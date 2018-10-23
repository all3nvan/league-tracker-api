require 'rails_helper'

RSpec.describe AuthChecksController, type: :controller do
  describe '#index' do
    context 'when token is invalid' do
      it 'is a 401' do
        request.headers['Authorization'] = 'fake token'

        get :index

        expect(response.status).to eq(401)
      end
    end

    context 'when token is valid' do
      it 'is a 204' do
        admin = Admin.create(username: 'admin', password: '1')
        token = Knock::AuthToken.new(payload: { sub: admin.id }).token
        request.headers['Authorization'] = "Bearer #{token}"

        get :index

        expect(response.status).to eq(204)
      end
    end
  end
end
