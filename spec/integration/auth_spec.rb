require 'swagger_helper'

RSpec.describe 'Auth API', type: :request do
  path '/auth/register' do
    post 'Register' do
      tags 'Auth'
      consumes 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string },
          full_name: { type: :string }
        },
        required: %w[email password full_name]
      }
      response '200', 'ok' do
        let(:user) { { email: 'test@example.com', password: 'password', full_name: 'Test User' } }
        run_test!
      end
    end
  end
end
