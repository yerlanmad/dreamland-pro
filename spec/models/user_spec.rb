require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:assigned_leads).class_name('Lead').with_foreign_key('assigned_agent_id').dependent(:nullify) }
  end

  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:role) }
    it { should validate_presence_of(:preferred_language) }
    it { should validate_presence_of(:preferred_currency) }

    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should allow_value('user@example.com').for(:email) }
    it { should_not allow_value('invalid_email').for(:email) }

    it { should have_secure_password }
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(agent: 'agent', manager: 'manager', admin: 'admin').backed_by_column_of_type(:string) }
    it { should define_enum_for(:preferred_language).with_values(en: 'en', ru: 'ru').backed_by_column_of_type(:string) }
    it { should define_enum_for(:preferred_currency).with_values(USD: 'USD', KZT: 'KZT', EUR: 'EUR', RUB: 'RUB').backed_by_column_of_type(:string) }
  end

  describe 'scopes' do
    let!(:agent) { create(:user, role: :agent) }
    let!(:manager) { create(:user, :manager) }
    let!(:admin) { create(:user, :admin) }

    describe '.agents' do
      it 'returns only agents' do
        expect(User.agents).to include(agent)
        expect(User.agents).not_to include(manager, admin)
      end
    end

    describe '.managers' do
      it 'returns only managers' do
        expect(User.managers).to include(manager)
        expect(User.managers).not_to include(agent, admin)
      end
    end

    describe '.admins' do
      it 'returns only admins' do
        expect(User.admins).to include(admin)
        expect(User.admins).not_to include(agent, manager)
      end
    end
  end

  describe 'callbacks' do
    describe '#downcase_email' do
      it 'downcases email before save' do
        user = build(:user, email: 'USER@EXAMPLE.COM')
        user.save
        expect(user.email).to eq('user@example.com')
      end

      it 'handles empty string email' do
        user = build(:user, email: '')
        user.save(validate: false)
        expect(user.email).to eq('')
      end
    end
  end

  describe 'password authentication' do
    let(:user) { create(:user, password: 'SecurePass123', password_confirmation: 'SecurePass123') }

    it 'authenticates with correct password' do
      expect(user.authenticate('SecurePass123')).to eq(user)
    end

    it 'does not authenticate with incorrect password' do
      expect(user.authenticate('WrongPassword')).to be_falsey
    end
  end

  describe 'default values' do
    it 'defaults role to agent' do
      user = User.new(name: 'Test User', email: 'test@example.com', password: 'password123')
      expect(user.role).to eq('agent')
    end

    it 'defaults preferred_language to ru' do
      user = create(:user)
      expect(user.preferred_language).to eq('ru')
    end

    it 'defaults preferred_currency to KZT' do
      user = create(:user)
      expect(user.preferred_currency).to eq('KZT')
    end
  end
end
