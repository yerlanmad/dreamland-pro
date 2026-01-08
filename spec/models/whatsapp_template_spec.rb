require 'rails_helper'

RSpec.describe WhatsappTemplate, type: :model do
  describe 'validations' do
    subject { build(:whatsapp_template) }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end
  end

  describe 'factory' do
    it 'creates a valid whatsapp template' do
      template = create(:whatsapp_template)
      expect(template).to be_persisted
      expect(template.active).to be true
    end

    it 'creates inactive template with trait' do
      template = create(:whatsapp_template, :inactive)
      expect(template.active).to be false
    end

    it 'creates booking confirmation template with trait' do
      template = create(:whatsapp_template, :booking_confirmation)
      expect(template.category).to eq('booking_confirmation')
      expect(template.content).to include('{{reference_number}}')
    end

    it 'creates payment reminder template with trait' do
      template = create(:whatsapp_template, :payment_reminder)
      expect(template.category).to eq('payment_reminder')
      expect(template.content).to include('{{amount}}')
    end
  end

  describe 'attributes' do
    let(:template) { create(:whatsapp_template) }

    it 'has a name' do
      expect(template.name).to be_present
    end

    it 'has content' do
      expect(template.content).to be_present
    end

    it 'has variables as JSON' do
      expect(template.variables).to be_present
    end

    it 'has a category' do
      expect(template.category).to be_present
    end

    it 'has an active flag' do
      expect(template.active).to be_in([true, false])
    end
  end

  describe 'variable substitution' do
    let(:template) do
      create(:whatsapp_template,
             content: "Hello {{name}}, your tour on {{date}} is confirmed!",
             variables: ['name', 'date'].to_json)
    end

    it 'stores variables as JSON' do
      parsed_variables = JSON.parse(template.variables)
      expect(parsed_variables).to eq(['name', 'date'])
    end

    it 'content contains placeholders' do
      expect(template.content).to include('{{name}}')
      expect(template.content).to include('{{date}}')
    end
  end
end
