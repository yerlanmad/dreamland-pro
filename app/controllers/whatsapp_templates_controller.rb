class WhatsappTemplatesController < ApplicationController
  before_action :require_authentication
  before_action :set_template, only: [:show, :edit, :update, :destroy, :toggle_active]

  def index
    @templates = WhatsappTemplate.order(created_at: :desc)
    @templates = @templates.where(category: params[:category]) if params[:category].present?
    @templates = @templates.page(params[:page]).per(20)

    @stats = {
      total: WhatsappTemplate.count,
      active: WhatsappTemplate.active.count,
      by_category: WhatsappTemplate.group(:category).count
    }
  end

  def show
    # Generate preview with sample data if clients exist
    if Client.any?
      sample_client = Client.first
      @preview = @template.render_for(sample_client)
    end
  end

  def new
    @template = WhatsappTemplate.new
  end

  def create
    @template = WhatsappTemplate.new(template_params)

    if @template.save
      redirect_to @template, notice: 'Template was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @template.update(template_params)
      redirect_to @template, notice: 'Template was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @template.destroy
    redirect_to whatsapp_templates_path, notice: 'Template was successfully deleted.'
  end

  def toggle_active
    @template.update(active: !@template.active)
    redirect_to whatsapp_templates_path, notice: "Template #{@template.active? ? 'activated' : 'deactivated'}."
  end

  private

  def set_template
    @template = WhatsappTemplate.find(params[:id])
  end

  def template_params
    params.require(:whatsapp_template).permit(:name, :content, :category, :active, variables: [])
  end
end
