# Systematic I18n Update Plan

## Status: IN PROGRESS

### Completed
- ✅ **Leads views** (5 files) - Fully updated with I18n
  - index.html.erb
  - show.html.erb
  - new.html.erb
  - edit.html.erb
  - _form.html.erb

### Pattern for Remaining Views

All view files follow the same pattern for I18n updates:

#### 1. Page Titles & Headers
```erb
<!-- Before -->
<h1>Tours</h1>

<!-- After -->
<h1><%= t('tours.title') %></h1>
```

#### 2. Buttons & Actions
```erb
<!-- Before -->
<%= link_to "New Tour", new_tour_path %>
<%= form.submit "Create Tour" %>

<!-- After -->
<%= link_to t('tours.new'), new_tour_path %>
<%= form.submit t('tours.form.create_tour') %>
```

#### 3. Form Labels
```erb
<!-- Before -->
<%= form.label :name, "Tour Name" %>

<!-- After -->
<%= form.label :name, t('tours.attributes.name') %>
```

#### 4. Status/Enum Values
```erb
<!-- Before -->
<%= tour.status.titleize %>

<!-- After  -->
<%= t("tours.statuses.#{tour.status}") %>
```

#### 5. Table Headers
```erb
<!-- Before -->
<th>Tour Name</th>

<!-- After -->
<%= t('tours.attributes.name') %>
```

#### 6. Empty States
```erb
<!-- Before -->
<h3>No tours found</h3>
<p>Get started by creating a new tour.</p>

<!-- After -->
<h3><%= t('tours.no_tours_found') %></h3>
<p><%= t('tours.get_started_message') %></p>
```

### Remaining View Directories

#### Tours (5 files) - IN PROGRESS
- app/views/tours/index.html.erb
- app/views/tours/show.html.erb
- app/views/tours/new.html.erb
- app/views/tours/edit.html.erb
- app/views/tours/_form.html.erb

#### Tour Departures (5 files) - PENDING
- app/views/tour_departures/index.html.erb
- app/views/tour_departures/show.html.erb
- app/views/tour_departures/new.html.erb
- app/views/tour_departures/edit.html.erb
- app/views/tour_departures/_form.html.erb

#### Bookings (6 files) - PENDING
- app/views/bookings/index.html.erb
- app/views/bookings/show.html.erb
- app/views/bookings/create.html.erb
- app/views/bookings/new.html.erb
- app/views/bookings/edit.html.erb
- app/views/bookings/_form.html.erb

#### Clients (8 files) - PENDING
- app/views/clients/index.html.erb
- app/views/clients/show.html.erb
- app/views/clients/new.html.erb
- app/views/clients/edit.html.erb
- app/views/clients/create.html.erb
- app/views/clients/update.html.erb
- app/views/clients/destroy.html.erb
- app/views/clients/_form.html.erb

#### Payments (7 files) - PENDING
- app/views/payments/index.html.erb
- app/views/payments/show.html.erb
- app/views/payments/new.html.erb
- app/views/payments/edit.html.erb
- app/views/payments/create.html.erb
- app/views/payments/update.html.erb
- app/views/payments/_form.html.erb

#### Communications (4 files) - PENDING
- app/views/communications/create.html.erb
- app/views/communications/edit.html.erb
- app/views/communications/_message.html.erb
- app/views/communications/_deleted_message.html.erb

#### WhatsApp Templates (5 files) - PENDING
- app/views/whatsapp_templates/index.html.erb
- app/views/whatsapp_templates/show.html.erb
- app/views/whatsapp_templates/new.html.erb
- app/views/whatsapp_templates/edit.html.erb
- app/views/whatsapp_templates/_form.html.erb

#### Sessions & Registrations (2 files) - PENDING
- app/views/sessions/new.html.erb
- app/views/registrations/new.html.erb

### Translation Key Structure

All translation keys are being added to both:
- `config/locales/ru.yml` (Russian - primary)
- `config/locales/en.yml` (English - secondary)

Structure:
```yaml
en/ru:
  common: # Shared across all views
    save, cancel, delete, edit, etc.

  navigation: # Nav bar items
    dashboard, leads, tours, etc.

  [model_name]: # e.g., tours, bookings, leads
    title, new, edit, show, list
    create_success, update_success, delete_success

    attributes: # Model fields
      name, email, status, etc.

    statuses/sources/types: # Enum values
      new, active, pending, etc.

    show: # Show page specific
      section titles, labels

    form: # Form specific
      field hints, submit buttons
```

### Next Steps

1. Complete ru.yml with ALL necessary keys for all views
2. Create complete en.yml with English translations
3. Apply systematic find/replace for each view directory
4. Test all views in both Russian and English

### Testing Checklist

After completion, test:
- [ ] All page titles display correctly
- [ ] All form labels are translated
- [ ] All buttons show correct text
- [ ] All status badges use translated values
- [ ] All empty states show translated messages
- [ ] Language switcher toggles all text
- [ ] No hardcoded English remains in views
