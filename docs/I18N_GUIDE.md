# Internationalization (i18n) Guide

## Overview

Dreamland PRO CRM supports **Russian** and **English** languages, with Russian as the default.

## How It Works

### Locale Detection Priority

1. **URL Parameter** (`?locale=en`) - Highest priority
2. **Session** - Remembers user's choice
3. **User Preference** - From logged-in user's profile (if implemented)
4. **Browser Language** - Detects from Accept-Language header
5. **Default** - Falls back to Russian (`ru`)

### Switching Languages

#### Via URL Parameter

Add `?locale=en` or `?locale=ru` to any URL:

```
https://pro.dreamland.kz/settings?locale=en  # Switch to English
https://pro.dreamland.kz/settings?locale=ru  # Switch to Russian
https://pro.dreamland.kz/settings            # Uses Russian (default)
```

#### Via Language Switcher UI

A language switcher dropdown is available on the settings page:
- Click the "RU" or "EN" button
- Select your preferred language
- The choice is saved in your session

### Session Persistence

Once you set a language via `?locale=` parameter, it's stored in the session and persists across pages until:
- You explicitly change it
- Your session expires
- You log out

## For Developers

### Using Translations in Views

```erb
<!-- Simple translation -->
<%= t('settings.title') %>
<!-- Output: "Настройки" (Russian) or "Settings" (English) -->

<!-- With variables -->
<%= t('leads.created_by', name: @lead.agent_name) %>

<!-- With default fallback -->
<%= t('custom.key', default: 'Default text') %>

<!-- Translation with HTML -->
<%= t('welcome.html', name: @user.name).html_safe %>
```

### Using Translations in Controllers

```ruby
redirect_to settings_path, notice: t('flash.success')

flash[:alert] = t('errors.not_authorized')
```

### Using Translations in Models

```ruby
errors.add(:phone, I18n.t('activerecord.errors.messages.invalid'))
```

### Adding New Translations

Edit the locale files:

**Russian (`config/locales/ru.yml`)**
```yaml
ru:
  my_section:
    my_key: "Мой текст"
```

**English (`config/locales/en.yml`)**
```yaml
en:
  my_section:
    my_key: "My text"
```

### Translation File Structure

```
config/locales/
├── en.yml          # English translations
└── ru.yml          # Russian translations
```

Translations are organized by section:
- `common` - Common UI elements (buttons, labels)
- `navigation` - Menu and navigation items
- `settings` - Settings page
- `leads`, `clients`, `bookings`, etc. - Model-specific translations
- `activerecord` - Model and error messages

## Configuration

### Application Config (`config/application.rb`)

```ruby
config.i18n.default_locale = :ru  # Default to Russian
config.i18n.available_locales = [:en, :ru]
config.i18n.fallbacks = [:en]  # Fallback to English if translation missing
```

### Application Controller (`app/controllers/application_controller.rb`)

```ruby
before_action :set_locale

private

def set_locale
  locale = extract_locale_from_params ||
           session[:locale] ||
           current_user&.preferred_language ||
           extract_locale_from_accept_language_header ||
           I18n.default_locale

  I18n.locale = locale
  session[:locale] = locale if params[:locale].present?
end

def default_url_options
  # Only add locale to URLs if it's not the default (Russian)
  I18n.locale == I18n.default_locale ? {} : { locale: I18n.locale }
end
```

## URL Behavior

### Clean URLs for Russian (Default)

Russian users see clean URLs without locale parameter:
```
https://pro.dreamland.kz/settings
https://pro.dreamland.kz/leads
https://pro.dreamland.kz/clients/5
```

### Explicit Locale for English

English users see `?locale=en` in URLs:
```
https://pro.dreamland.kz/settings?locale=en
https://pro.dreamland.kz/leads?locale=en
https://pro.dreamland.kz/clients/5?locale=en
```

This keeps URLs clean for the primary Russian/Kazakh market while supporting English.

## Language Switcher Component

Location: `app/views/shared/_language_switcher.html.erb`

To add to any view:
```erb
<%= render 'shared/language_switcher' %>
```

Current implementation:
- Dropdown with 🇷🇺 Russian and 🇬🇧 English options
- Shows current language (RU/EN)
- Plain JavaScript (no framework dependencies)
- Fully responsive

## Testing

### Test in Development

```bash
# Start Rails server
bin/dev

# Test Russian (default)
open http://localhost:3000/settings

# Test English
open http://localhost:3000/settings?locale=en
```

### Test Locale Detection

```ruby
# In Rails console
I18n.locale = :en
I18n.t('settings.title')  # => "Settings"

I18n.locale = :ru
I18n.t('settings.title')  # => "Настройки"
```

## Common Patterns

### Model Name Translation

```ruby
# Automatic translation via activerecord
Lead.model_name.human  # => "Лид" (ru) or "Lead" (en)
```

### Enum Translation

```ruby
# In model
enum status: { new: 'new', contacted: 'contacted' }

# In view
<%= t("leads.statuses.#{@lead.status}") %>
# => "Новый" (ru) or "New" (en)
```

### Date Formatting

```ruby
# In locale file
ru:
  date:
    formats:
      default: "%d.%m.%Y"  # 12.01.2026

en:
  date:
    formats:
      default: "%m/%d/%Y"  # 01/12/2026
```

### Number Formatting

```ruby
number_to_currency(@booking.total_amount, locale: I18n.locale)
# => "1 234,56 ₽" (ru) or "$1,234.56" (en)
```

## Best Practices

### 1. Always Use Translation Keys

❌ **Bad:**
```erb
<h1>Settings</h1>
```

✅ **Good:**
```erb
<h1><%= t('settings.title') %></h1>
```

### 2. Use Scoped Keys

❌ **Bad:**
```yaml
ru:
  settings_title: "Настройки"
  settings_subtitle: "Управление настройками"
```

✅ **Good:**
```yaml
ru:
  settings:
    title: "Настройки"
    subtitle: "Управление настройками"
```

### 3. Provide Meaningful Defaults

```ruby
t('custom.message', default: 'Default message in English')
```

### 4. Use Interpolation for Dynamic Content

```ruby
t('welcome.message', name: @user.name)
# welcome.message: "Здравствуйте, %{name}!"
```

### 5. Group Related Translations

Keep related translations together:
```yaml
ru:
  leads:
    title: "Лиды"
    new: "Новый лид"
    edit: "Редактировать лид"
    statuses:
      new: "Новый"
      contacted: "Контактирован"
```

## Troubleshooting

### Translation Missing Error

```
translation missing: ru.my.key
```

**Solution:** Add the key to `config/locales/ru.yml`

### Locale Not Persisting

**Check:**
1. Session is enabled
2. `session[:locale]` is being set in controller
3. No conflicting `before_action` overriding locale

### URLs Not Including Locale

This is expected behavior for Russian (default locale). English URLs will include `?locale=en`.

To force locale in all URLs:
```ruby
def default_url_options
  { locale: I18n.locale }
end
```

## Resources

- [Rails I18n Guide](https://guides.rubyonrails.org/i18n.html)
- [I18n Gem Documentation](https://github.com/ruby-i18n/i18n)
- Translation files: `config/locales/`

---

**Last Updated:** 2026-01-12
**Default Locale:** Russian (ru)
**Available Locales:** Russian (ru), English (en)
