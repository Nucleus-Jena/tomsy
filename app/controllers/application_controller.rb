class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :set_paper_trail_whodunnit
  before_action :set_raven_context

  rescue_from CanCan::AccessDenied do |exception|
    has_layout = exception.subject.to_s != "rails_admin"
    respond_to do |format|
      format.html { render template: "pages/not_authorized", status: 403, layout: has_layout }
      format.json { head :forbidden }
    end
  end

  private

  def set_raven_context
    Raven.user_context(id: current_user.id, email: current_user.email) if defined?(current_user) && current_user
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
end
