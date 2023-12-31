# frozen_string_literal: true

class Public::SessionsController < Devise::SessionsController
  before_action :customer_state, only: [:create]

  def guest_sign_in
    user = Customer.guest
    sign_in user
    redirect_to root_path, notice: 'ゲストユーザーとしてログインしました。'
  end

  protected
  # 退会しているかを判断するメソッド
  def customer_state
    # 入力されたemailのアカウントを取得
    @customer = Customer.find_by(email: params[:customer][:email])
    # 取得したアカウントのパスワードと入力されたパスワードが一致しているかを判別
    if (@customer.valid_password?(params[:customer][:password]) && (@customer.is_deleted))
      # 退会処理済の場合、処理を終了する
      flash[:notice] = "退会済みのためログインできません。"
      redirect_to new_customer_registration_path
    end
  end
end
