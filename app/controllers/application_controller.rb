class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Set locale
  before_action :set_locale

  # Authentication
  before_action :require_authentication

  helper_method :current_user, :logged_in?

  private

  def set_locale
    # Priority: URL param > Session > User preference > Browser > Default (Russian)
    locale = extract_locale_from_params ||
             session[:locale] ||
             current_user&.preferred_language ||
             extract_locale_from_accept_language_header ||
             I18n.default_locale

    I18n.locale = locale
    session[:locale] = locale if params[:locale].present?
  end

  def extract_locale_from_params
    parsed_locale = params[:locale]
    I18n.available_locales.map(&:to_s).include?(parsed_locale) ? parsed_locale : nil
  end

  def extract_locale_from_accept_language_header
    return unless request.env['HTTP_ACCEPT_LANGUAGE']

    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
  end

  def default_url_options
    # Only add locale to URLs if it's not the default (Russian)
    I18n.locale == I18n.default_locale ? {} : { locale: I18n.locale }
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def require_authentication
    unless logged_in?
      redirect_to login_path, alert: t('auth.sign_in')
    end
  end
end
