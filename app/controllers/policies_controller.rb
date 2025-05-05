class PoliciesController < ApplicationController
  allow_unauthenticated_access

  def show
    if params[:version].present?
      @policy = Policy.find_by(kind: params[:kind], version: params[:version])
    else
      @policy = Policy.where(kind: params[:kind], is_active: true).order(version: :desc).first
    end

    if @policy.nil?
      redirect_to root_path, alert: "요청하신 정책을 찾을 수 없습니다."
      return
    end

    respond_to do |format|
      format.html
      format.json { render json: @policy }
    end
  end

  def data_deletion
  end
end
