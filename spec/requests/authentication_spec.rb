require 'rails_helper'

RSpec.describe "User Authentication", type: :request do
  let(:user) { create(:user) }

  describe "POST /users/sign_in" do
    context "with valid credentials" do
      it "signs in the user" do
        post user_session_path, params: { user: { email: user.email, password: user.password } }
        follow_redirect!
        expect(response.body).to include("Login efetuado com sucesso.")
      end
    end

    context "with invalid credentials" do
      it "does not sign in the user" do
        post user_session_path, params: { user: { email: user.email, password: "wrongpassword" } }
        expect(response.status).to eq(422)  # Verifica o status HTTP
        expect(response.body).to include("E-mail ou senha inválidos.")
      end
    end
  end
end
