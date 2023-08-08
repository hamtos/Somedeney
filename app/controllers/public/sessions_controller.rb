# frozen_string_literal: true

class Public::SessionsController < Devise::SessionsController
  defore_action :customer_state, only: [:create]

  protected
  # 退会しているかを判断するメソッド
  def costomer_state
    # 入力されたemailのアカウントを取得
    @customer = Customer.find_by(email: params[:customer][:email])
    # 取得したアカウントのパスワードと入力されたパスワードが一致しているかを判別
    if (@customer.valid_password?(params[:customer][:password]) && (@customer.is_deleted))
      # 退会処理済の場合、処理を終了する
      flash[:notice] = "退会済みのためログインできません。"
      redirect_to new_customer_registration_path
    end
  end

    def is_quit_status
    @customer = Customer.find_by(email: params[:customer][:email].downcase)
      if (@customer.valid_password?(params[:customer][:password]) && (@customer.active_for_authentication? == false))
        flash[:notice] = "退会済みのためログインできません。"
        redirect_to new_customer_registration_path
      end
  end

end
