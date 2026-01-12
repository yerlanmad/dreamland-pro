# Phone Number Format Clarification - @c.us Usage

## Summary

**TL;DR**: The `@c.us` suffix is **NOT** used anywhere in wazzup24 integration. It does NOT appear in incoming webhook payloads. Our code includes defensive handling for it, but wazzup24 sends plain phone numbers in both webhooks and API responses.

## The Confusion

Earlier documentation incorrectly stated that:
1. We add `@c.us` suffix when sending (incorrect - API doesn't accept it)
2. Incoming webhooks include `@c.us` suffix (incorrect - webhooks send plain numbers)

Both statements are **incorrect** based on actual wazzup24 API v3 behavior.

## Correct Phone Number Flow

### Format Overview

| Context | Format | Example |
|---------|--------|---------|
| **wazzup24 API** (sending) | Numbers only, no prefix | `79001234567` |
| **wazzup24 Webhook** (receiving) | Numbers only, no prefix | `79001234567` |
| **Our Database** | E.164 standard | `+79001234567` |

### Detailed Flow

#### 1. Incoming Messages (Webhook → Database)

**wazzup24 sends us:**
```json
{
  "chatId": "79001234567",
  "text": "Hello",
  "senderName": "John"
}
```

**We process it:**
```ruby
# app/services/whatsapp/message_handler.rb
def normalize_phone(phone)
  # Step 1: Remove @c.us suffix (defensive, not expected in actual webhooks)
  phone = phone.split('@').first if phone.include?('@')

  # Step 2: Remove spaces, dashes, parentheses
  phone = phone.gsub(/[\s\-\(\)]/, '')

  # Step 3: Add + prefix for E.164 format
  phone = "+#{phone}" unless phone.start_with?('+')
  # "79001234567" → "+79001234567"

  phone
end
```

**Result stored in DB:** `+79001234567`

#### 2. Outgoing Messages (Database → API)

**We have in DB:** `+79001234567`

**We prepare for API:**
```ruby
# app/clients/wazzup24_client.rb
def normalize_phone(phone)
  return nil if phone.blank?

  # Step 1: Remove spaces, dashes, parentheses
  phone = phone.gsub(/[\s\-\(\)]/, '')

  # Step 2: Remove + prefix (API requirement)
  phone = phone.gsub(/^\+/, '')
  # "+79001234567" → "79001234567"

  phone
  # ✅ NO @c.us added!
end
```

**Sent to API:**
```json
{
  "channelId": "d08f693e-9808-469b-92be-3af1c46c7b53",
  "chatType": "whatsapp",
  "chatId": "79001234567",  // ✅ No @c.us, no +
  "text": "Hello from CRM"
}
```

## API Documentation Reference

From `docs/Wazzup24_Intergration.md`:

> **chatId** - Chat ID (contact's account in messenger):
> - for "whatsapp" and "viber" — **only numbers, without spaces and special characters in the format 79011112233**

This clearly states:
- ✅ Only numbers
- ❌ No `@c.us`
- ❌ No `+` prefix
- ❌ No spaces or special characters

## Why @c.us Exists (Historical Note)

The `@c.us` suffix is WhatsApp's internal format for identifying users:
- `@c.us` = Regular WhatsApp user
- `@g.us` = WhatsApp group
- `@broadcast` = Broadcast list

**Important:** wazzup24 **does NOT include** the `@c.us` suffix in webhook payloads. The chatId comes as plain numbers only. Our code includes defensive handling for `@` symbols, but in practice, wazzup24 webhooks send phone numbers without any suffix.

## Code Implementation

### ✅ Correct - Current Implementation

**Wazzup24Client (Outgoing):**
```ruby
def normalize_phone(phone)
  return nil if phone.blank?
  phone = phone.gsub(/[\s\-\(\)]/, '')
  phone = phone.gsub(/^\+/, '')  # Remove + prefix
  phone                           # Return: "79001234567"
end
```

**MessageHandler (Incoming):**
```ruby
def normalize_phone(phone)
  phone = phone.split('@').first if phone.include?('@')  # Remove @c.us
  phone = phone.gsub(/[\s\-\(\)]/, '')
  phone = "+#{phone}" unless phone.start_with?('+')      # Add + prefix
  phone                                                   # Return: "+79001234567"
end
```

### ❌ Incorrect - Old Implementation (Fixed)

```ruby
# OLD - WRONG - Don't use!
def normalize_phone(phone)
  phone = phone.gsub(/[\s\-\(\)]/, '')
  phone += '@c.us' unless phone.include?('@')  # ❌ API doesn't want this!
  phone
end
```

## Testing

### Test Incoming Message

```ruby
# Simulate wazzup24 webhook
handler = Whatsapp::MessageHandler.new({
  'chatId' => '79001234567@c.us',  # With @c.us (from webhook)
  'text' => 'Hello',
  'senderName' => 'Test User',
  'messageId' => 'msg_123'
})

handler.process

client = Client.last
client.phone  # => "+79001234567" (stored without @c.us)
```

### Test Outgoing Message

```ruby
# Client has phone: "+79001234567"
client = Client.create!(phone: '+79001234567', name: 'Test')

# When sending via API
Wazzup24Client.new.send_message(
  phone: client.phone,  # "+79001234567"
  text: 'Hello'
)

# API receives chatId: "79001234567" (no +, no @c.us)
```

## Documentation Updates

Updated files to reflect correct behavior:
- ✅ `docs/WHATSAPP_INTEGRATION.md` - Fixed phone format section
- ✅ `docs/WAZZUP24_UPDATE_SUMMARY.md` - Documents no @c.us
- ✅ `docs/PHONE_FORMAT_CLARIFICATION.md` - This file

Still need to update:
- ⚠️ `docs/IMPLEMENTATION_SUMMARY.md` - Contains outdated info
- ⚠️ `CHANGELOG.md` - Historical, leave as-is for reference

## Common Mistakes to Avoid

### ❌ Don't Add @c.us to Outgoing Messages
```ruby
# WRONG
chatId = "#{phone}@c.us"  # API will reject this
```

### ❌ Don't Send + Prefix to API
```ruby
# WRONG
chatId = "+79001234567"  # API expects no prefix
```

### ❌ Don't Store @c.us in Database
```ruby
# WRONG
Client.create!(phone: "79001234567@c.us")  # Store E.164 format instead
```

### ✅ Do Normalize Phone from Webhooks
```ruby
# CORRECT - wazzup24 webhooks send plain numbers
phone = payload['chatId']  # "79001234567"
phone = phone.gsub(/[\s\-\(\)]/, '')  # Remove formatting
phone = "+#{phone}" unless phone.start_with?('+')  # Add + for E.164
Client.create!(phone: phone)  # "+79001234567"
```

### ✅ Do Remove + Before Sending
```ruby
# CORRECT
phone = client.phone.gsub(/^\+/, '')  # Remove +
send_message(chatId: phone)  # "79001234567"
```

## Verification Checklist

Test these scenarios:

- [x] Incoming webhook sends plain numbers → normalizes to E.164 → stores correctly
- [x] Outgoing message → removes `+` → sends plain numbers
- [x] Phone with spaces `+7 900 123 45 67` → normalizes correctly
- [x] Defensive handling: phone with `@c.us` → removes it (edge case)
- [x] API rejects `+` prefix → we strip it
- [x] API doesn't expect `@c.us` suffix → we don't add it

## Conclusion

The current implementation is **correct**:
- ✅ Incoming webhooks send plain numbers (no `@c.us`)
- ✅ We include defensive `@c.us` stripping (handles edge cases)
- ✅ We never add `@c.us` to outgoing API calls
- ✅ We store E.164 format in database (`+79001234567`)
- ✅ We send API format to wazzup24 (`79001234567`)

The confusion was due to incorrect assumptions about wazzup24's webhook format.

## Quick Reference

```
Incoming:  79001234567 (webhook)
           ↓ add +
Database:  +79001234567 (E.164)
           ↓ strip +
Outgoing:  79001234567 (API)
```

✅ **No @c.us in webhooks or API calls**
✅ **Current implementation is correct (includes defensive @c.us handling)**
✅ **Documentation updated**
