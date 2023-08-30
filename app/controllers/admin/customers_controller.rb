class Admin::CustomersController < ApplicationController

  def index
    @customers = Customer.all
  end

  def update
    @customer = Customer.find(params[:id])
    if @customer.update(customer_params)
      flash[:notice] = "ステータスを更新しました"
      redirect_to admin_customers_path
    else
      flash[:notice] = "ステータスの更新に失敗しました"
      redirect_to admin_customers_path
    end
  end

  private
  def customer_params
    params.require(:customer).permit(:email, :name, :is_deleted)
  end

end
