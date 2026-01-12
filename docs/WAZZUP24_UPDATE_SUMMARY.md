# Wazzup24 Integration Update Summary

## Overview

Updated the wazzup24 WhatsApp API integration to align with the official API documentation (`docs/Wazzup24_Intergration.md`). The integration now supports the full range of wazzup24 API v3 features.

## Date
2026-01-11

## Changes Made

### 1. Updated `Wazzup24Client` (`app/clients/wazzup24_client.rb`)

#### New Features Added:

- **Channel Management**
  - Added `get_channels` method to retrieve list of connected WhatsApp channels
  - Returns channel details: `channelId`, `transport`, `plainId`, `state`

- **Enhanced Message Sending**
  - Updated `send_message` to use correct API v3 parameters:
    - `channelId`: UUID of the channel
    - `chatType`: Type of chat (whatsapp, instagram, telegram, etc.)
    - `chatId`: Normalized phone number without @ suffix
    - `text`: Message text (mutually exclusive with contentUri)
    - `contentUri`: URL for media files (mutually exclusive with text)
    - `refMessageId`: ID for message quoting/replying
    - `crmMessageId`: Unique ID for idempotent message sending

- **Message Editing**
  - Added `edit_message(message_id:, text:, content_uri:)` method
  - Supports editing message text or media (not both)
  - Handles editing time expiration errors

- **Message Deletion**
  - Added `delete_message(message_id:)` method
  - Handles deletion time expiration errors

- **Comprehensive Error Handling**
  - Added 40+ error codes from wazzup24 API documentation
  - `ERROR_MESSAGES` constant maps error codes to human-readable messages
  - Improved error response structure with `error_code` and `status`

- **Phone Normalization**
  - Updated to remove `+` prefix (API expects format: `79011112233`)
  - No longer adds `@c.us` suffix

### 2. Updated `Whatsapp::SendMessageService` (`app/services/whatsapp/send_message_service.rb`)

- Added support for `content_uri` parameter for media messages
- Added support for `channel_id` parameter
- Added support for `ref_message_id` for message quoting
- Generates unique `crmMessageId` for idempotent message sending using communication ID
- Added `sent_at` timestamp tracking
- Added `error_message` field for storing API errors

### 3. New Service Classes Created

- **`Whatsapp::EditMessageService`** (`app/services/whatsapp/edit_message_service.rb`)
  - Edits existing WhatsApp messages
  - Updates communication record after successful edit

- **`Whatsapp::DeleteMessageService`** (`app/services/whatsapp/delete_message_service.rb`)
  - Deletes WhatsApp messages
  - Marks communication as deleted with timestamp

- **`Whatsapp::ChannelManagerService`** (`app/services/whatsapp/channel_manager_service.rb`)
  - Manages WhatsApp channels
  - `get_channels`: Returns all channels with state descriptions
  - `get_active_whatsapp_channels`: Filters active WhatsApp channels only
  - `get_default_channel`: Returns first active WhatsApp channel

### 4. Updated Tests

- Created comprehensive RSpec test suite (`spec/clients/wazzup24_client_spec.rb`)
- Added webmock integration to `spec/rails_helper.rb`
- Test coverage includes:
  - Message sending (text and media)
  - Message editing and deletion
  - Channel retrieval
  - Phone normalization
  - Error handling for all error codes
  - Timeout handling
  - Idempotency with crmMessageId

- **All 18 tests passing ✅**

## API Endpoints Used

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/v3/channels` | Get list of connected channels |
| POST | `/v3/message` | Send message (text or media) |
| PATCH | `/v3/message/:messageId` | Edit existing message |
| DELETE | `/v3/message/:messageId` | Delete message |

## Key Improvements

1. **Idempotency**: Messages now include `crmMessageId` to prevent duplicate sends
2. **Media Support**: Can send images, videos, documents via `contentUri`
3. **Message Management**: Can edit and delete sent messages
4. **Channel Awareness**: Can query and select specific WhatsApp channels
5. **Better Error Handling**: 40+ specific error codes with human-readable messages
6. **Quote/Reply Support**: Can reply to specific messages using `refMessageId`

## Breaking Changes

⚠️ **Phone Number Format**:
- Old: `+1234567890@c.us`
- New: `1234567890` (no + prefix, no @c.us suffix)

⚠️ **API Parameter Changes**:
- Old: `phone`, `message`, `media_url`
- New: `phone`, `text`, `content_uri`, `channel_id`, etc.

## Migration Notes

Existing code calling `Wazzup24Client.new.send_message` should update parameters:

**Before:**
```ruby
Wazzup24Client.new.send_message(
  phone: '+1234567890',
  message: 'Hello',
  media_url: 'https://example.com/image.jpg'
)
```

**After:**
```ruby
Wazzup24Client.new.send_message(
  phone: '+1234567890',
  text: 'Hello',  # or content_uri (not both)
  content_uri: 'https://example.com/image.jpg'
)
```

## Configuration

The client now supports default `channel_id` from Rails credentials:

```yaml
# config/credentials.yml.enc
wazzup24:
  api_key: your_api_key_here
  channel_id: d08f693e-9808-469b-92be-3af1c46c7b53
```

## Testing

Run tests:
```bash
bundle exec rspec spec/clients/wazzup24_client_spec.rb
```

## Documentation References

- Official wazzup24 API Documentation: `docs/Wazzup24_Intergration.md`
- wazzup24 API Website: https://wazzup24.com/help/api-en/

## Next Steps

1. Update any controllers/views that call `Wazzup24Client` directly
2. Add UI for editing/deleting messages in the CRM
3. Add UI for selecting different WhatsApp channels
4. Consider adding message templates support (future enhancement)
5. Add webhook handlers for message edit/delete events
6. Update Communication model to include new fields: `sent_at`, `error_message`, `deleted_at`

## Questions or Issues?

Refer to `docs/Wazzup24_Intergration.md` for complete API documentation.
