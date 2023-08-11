# frozen_string_literal: true

class Public::RegistrationsController < Devise::RegistrationsController
  before_action :ensure_normal_user, only: [:destroy, :update]

  # ゲストユーザーの退会禁止
  def ensure_normal_user
    if resource.email == 'guest@example.com'
      redirect_to root_path, alert: 'ゲストユーザーの変更・削除はできません。'
    end
  end
end
