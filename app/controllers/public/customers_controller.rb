class Public::CustomersController < ApplicationController
  before_action :check_guest_account, only: [:update]

  def show
    @customer = current_customer
  end

  def update
    @customer = current_customer
    if @customer.update(customer_params)
      flash[:notice] = "変更内容を保存しました"
      redirect_to customers_my_page_path
    else
      render :show
    end
  end

  def leave
    @customer = current_customer
    @customer.update(is_deleted: true)
    reset_session
    flash[:notice] = "退会しました"
    redirect_to root_path
  end

  private
  def customer_params
    params.require(:customer).permit(:email, :name, :is_deleted)
  end

  def check_guest_account
    if current_customer.email = 'guest@example.com'
      flash[:error] = "ゲストアカウントの情報は変更できません。"
      redirect_to customers_my_page_path
    end
  end
end
