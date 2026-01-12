# Wazzup24 webhooks

# **Webhooks**

In this article, we tell you how to connect webhooks, in what form we send them, and what we expect in response.

# **How we send webhooks and what we expect in return**

We send webhooks using the POST method to the specified URI. It may include a query "string".

If we have your crmKey, we add the Authorization: Bearer ${crmKey} header. If not, we don't add the Authorization header at all.

Webhooks contain JSON in the body and the corresponding header Content-Type: application/json; charset-utf-8. An object is encoded in JSON with properties that correspond to webhook types.

One webhook can contain messages and statuses types at the same time. The webhooks of the createContact and createDeal types always contain only one type.

In response, we expect the code 200 OK. In some cases, we wait for certain information in the body of the response. Timeout — 30 s.

# **How to enable webhooks**

To subscribe to webhooks, you must invoke:

```
 PATCH https://api.wazzup24.com/v3/webhooks
```

The body must contain JSON with parameters:

| **Parameter** | **Type** | **Description** |
| --- | --- | --- |
| webhooksUri | String | Address to receive webhooks. No more than 200 characters |
| subscriptions | Object | Webhook settings |
| subscriptions.messagesAndStatuses | Boolean | Webhook on new messages and webhook on outgoing status changes.
If the webhook is required, specify "true". If not, specify "false". |
| subscriptions.contactsAndDealsCreation | Boolean | Webhook about creating a new contact or deal.
If the webhook is required, specify "true". If not, specify "false". |
| subscriptions.channelsUpdates | Boolean | Webhook about changing the status of the channel.
If the webhook is required, specify "true". If not, specify "false". |
| subscriptions.templateStatus | Boolean | Webhook about the change in moderation status of the WABA template.
If the webhook is required, specify "true". If not, specify "false". |

When connecting to the specified url, a POST test request {test: true } will be sent, in reply to which the server should return 200 if webhooks are successfully connected, otherwise a :"Webhooks request not valid. Response status must be 200″.

### **Request example**

```
 curl --location --request PATCH 'https://api.wazzup24.com/v3/webhooks' \
--header 'Authorization: Bearer w11cf3444405648267f900520d454368d27' \
--header 'Content-Type: application/json' \
--data-raw '{
"webhooksUri": "https://example.com/webhooks",
"subscriptions": {
"messagesAndStatuses": true,
"contactsAndDealsCreation": true
}
}'

```

### **Response example**

```
 {
ok
}

```

### **Errors**

In addition [to common errors for all routes](https://wazzup24.com/help/api-en/common-errors/), there can be:

| **Error** | **Description** |
| --- | --- |
| 400 Bad Request, { error: ‘uriNotValid’, description: ‘Provided URI is not valid URI’ } | If the URI is incorrect according to the formal characteristics |
| 400 Bad Request, { error: ‘testPostNotPassed’, description: ‘URI does not return 200 OK on test request’, data: { ‘${код ответа}’ } } | If there was an error when sending a test request to the specified URL |

# **Checking the address for receiving webhooks**

To check the currently set callback URL, call

```
 GET https://api.wazzup24.com/v3/webhooks
```

### **Response example**

```
 HTTP/1.1 200 OK
``json
{
"webhooksUri": "https://example.com/webhooks",
{ "subscriptions": {
{ "messagesAndStatuses": { "true",
{ "contactsAndDealsCreation": "true"
}
}
``

```

# **Webhook for new messages, editing and deleting messages**

The webhook will send a JSON object with the **messages** key, the value of which is an array of objects with the following parameters:

| **Parameter** | **Type** | **Description** |
| --- | --- | --- |
| messageId | String (uuid4) | guid Wazzup messages |
| channelId | String (uuid4) | Channel id |
| chatType | String | Available values:
• WhatsApp: "whatsapp",
• Viber: "viber",
• WhatsApp group chat: "whatsgroup",
• Instagram: "instagram",
• Telegram: "telegram". |
| chatId | String | Chat Id (contact's account in messenger):
• for whatsapp and viber — only numbers, without spaces and special characters in the format 79011112233;
• for instagram — an account without @ at the beginning;
• for WhatsApp group chat ('whatsgroup') — it comes in webhooks of incoming messages;
• for Telegram — Telegram GUID. Username and phone number, if any, are sent to contact.phone and contact.username. |
| dateTime | String | The message sending time specified by the messenger in the format yyyy-mm-ddThh:mm:ss.ms |
| type | String | Message type:
• ‘text‘— text,
• ‘image‘ — image,
• ‘audio‘ — audio,
• ‘video‘ — video,
• ‘document‘ — document,
• ‘vcard’ — contact card,
• ‘geo‘ — geolocation,
• ‘wapi_template’ — WABA template,
• ‘unsupported’ — unsupported type,
• ‘missing_call‘ — missed call,
• ‘unknown‘ — unknown error. |
| status | String | Contains only value from ENUM of webhook “statuses”:
• 'sent' — sent (same as one grey check mark),
• 'delivered' — delivered (same as two grey check marks),
• 'read' — read (same as two blue check mark),
• 'error',
• 'inbound' — incoming message. |
| error | Object | Comes if 'status: error' |
| error.error | String | Error types:
• 'BAD_CONTACT' — for WhatsApp and Telegram: the account with this chatId does not exist;
• 'CHATID_IGSID_MISMATCH' — for Instagram: the Instagram account with this chatId does not exist. The client may have changed the profile name;
• 'TOO_LONG_TEXT' — message text is too long;
• 'BAD_LINK' — Instagram filters don't let a post through because of a link;
• 'TOO_BIG_CONTENT' — file size should not exceed 50 Mb;
• 'SPAM' — the message was not sent due to a suspicion of spam;
• 'TOO_MANY_EXT_REQS' — sending was interrupted. Too many messages from the account;
• 'WRONG_CONTENT' — the content of the file does not fit the Instagram parameters;
• 'MESSAGE_CANCELLED' — message sending stopped;
• '24_HOURS_EXCEEDED' — the 24-hour WABA dialogue is closed;
• 'COMMENT_DELETED' — the comment on Instagram was deleted;
• 'MENTION_FORBIDDEN' — the tagged user (mentioned) in the message cannot be tagged
• 'CONTENT_CONVERSION_ERROR' — content could not be converted;
• 'MESSAGE_DELETED' — the message was deleted by the sender;
• 'CHATID_IGSID_MISMATCH' — for Instagram: failed to match ChatId with IGSID;
• '7_DAYS_EXCEEDED' — the 7-day dialogue on Instagram was closed;
• 'COMMENT_ALREADY_PRIVATE_REPLIED' — this comment on Instagram has already been answered in direct;
• 'COMMENT_INVALID_FOR_PRIVATE_REPLY' — it is impossible to reply to this comment on Instagram in direct;
• 'COMMENT_CAN_BE_TEXT_ONLY' — you can only reply to comments on Instagram by comments only in text format;
• 'CANNOT_REPLY_TO_DELETED' — you can't reply to a message because the user deleted it;
• 'GENERAL_ERROR' — there was an error. Information has already been sent to the Wazzup developers;
• 'UNKNOWN_ERROR' — an unknown error has occurred. Please try again later;
• 'CHANNEL_REJECTED' — the message was not sent, because the channel is rejected. |
| error.description | String | Error description |
| text | String | Message text. May not be present if the message has content |
| contentUri | String | Link to message content (may not exist if the message does not contain content) |
| authorName | String | The sender's name, if there is one. Only present in messages isEcho = true |
| authorId | String | User ID in your CRM |
| isEcho | Boolean | If the message is incoming — false, if it is outgoing, sent not from this API (from a phone or iFrame) — true |
| instPost | Object | Information about the post from Instagram. Applied when the post is an Instagram comment |
| contact | Object | Information about contact |
| contact.name | String | Contact name |
| contact.avatarUri | String | The URI of the contact's avatar. Applied if an avatar is in Wazzup |
| contact.username | String | For Telegram only.Username of a Telegram contact, with no @ at the beginning |
| contact.phone | String | Telegram only.Contact phone number in international format |
| interactive | Interactive | Array of objects with Salesbot amoCRM buttons attached to the message |
| quotedMessage | Object | Contains an object with the parameters of the quoted message |
| sentFromApp | Boolean | If the message was sent from Wazzup’s native chat, the parameter is set to `true`; otherwise, it is `false`. |
| isEdited | Boolean | Shows that the message has been edited: if `true`, the message has been changed.

If the outgoing message is changed not via Wazzup, but directly from the messenger, then a webhook about updating the status will be sent statuses |
| isDeleted | Boolean | Indicates that the message has been deleted: if `true`, the message has been deleted |
| oldInfo | Object | Contains information about a modified or deleted message |
| oldInfo.oldText | String | Message text before editing or deleting |
| oldInfo.oldAuthorId | String | id of the author who sent the original message.
May differ from authorId if the message was changed or deleted by another employee, not the author |
| oldInfo.oldAuthorName | String | The name of the author who sent the original message.
May differ from authorName if the message was changed or deleted by another employee than the author |

### **Examples**

**Sticker from WhatsApp**

We send stickers received from the WhatsApp channel in the webhook "type": "image" and a link to the file in .was format:

```
{
  "messages": [
    {
      "messageId": "6a2087e8-e0f4-9999-b968-9d9999933c81",
      "dateTime": "2025-05-06T14:16:00.002Z",
      "channelId": "b96a353b-9999-4cac-8413-ba99999f981",
      "chatType": "whatsapp",
      "chatId": "79999999999",
      "type": "image",
      "isEcho": false,
      "contact": {
        "name": "79999999999",
        "avatarUri": "https://store.wazzup24.com/0e999997ae07d2083c687253b8baed9999a26fa";
      },
      "contentUri": "https://store.wazzup24.com/e51159999e0046d628b3924161d411e5812d2546/?filename=f9ebe1b1-3ed5-4ec2-97fb-03f0c25e413f.was";,
      "status": "inbound"
    }
  ]
}
```

**WhatsApp poll**

We send the survey received from the WhatsApp channel in the webhook "type": "text" and send the survey in text message format:

```
{
  "messages": [
    {
      "messageId": "caa9999-cce3-424c-86cd-05f99995073",
      "dateTime": "2025-05-06T14:18:00.001Z",
      "channelId": "b96a999e-06f5-4cac-8413-ba999993f981",
      "chatType": "whatsapp",
      "chatId": "79999999999",
      "type": "text",
      "isEcho": false,
      "contact": {
        "name": "79999999999",
        "avatarUri": "https://store.wazzup24.com/0e82ead97ae07d9999c687253b8baed2365a26fa";
      },
      "text": "Тестовый\n• Вариант1\n• Вариант2",
      "status": "inbound"
    }
  ]
}
```

# **Webhook about updating the status of outgoing messages**

The webhook will send a JSON object with the **statuses** key, the value of which will contain an array of objects with the following parameters:

| **Parameter** | **Type** | **Description** |
| --- | --- | --- |
| messageId | String | guid Wazzup messages |
| timestamp | String | The time of receiving status update information |
| status | String | the status of the message that was updated:
• sent
• delivered
• read
• error
• edited: a webhook with this status only comes if the message is edited via messenger, not Wazzup chat. Otherwise, a webhook `messages` will come |
| error | Object | Optional, comes only when 'status’: 'error' |
| error.error | String | Error code |
| error.description | String | Error description |
| error.[data] | String | More information about the error |

```
{
"statuses": [
{
"messageId": "be3dc577-60c4-4fc8-83a5-8c358e0bfe15", // guid of the message whose status update we are notifying
"timestamp": "2025-02-05T06:01:07.499Z", // is the time of receiving status update information
"status": "delivered"
}
]
}

```

# **Webhooks about creating a new contact, deal**

Send when you need to create a contact or transaction in CRM. This happens in 3 cases:

**Case 1**: in item 3 of the integration settings "Every new client is assigned to the first respondent" is selected.

A new client writes. An employee replies to them. Wazzup sends a webhook about new contact and deal creation if funnels with stages are loaded from CRM.

We send the webhook only if we have received the id of the employee who replied to the new customer's message.

.

**Case 2**: "Sales reps are assigned new clients in turn" is selected in item 3 of the integration settings.

A new client writes. Wazzup sends a webhook about creating a new contact and deal if funnels with stages are loaded from CRM.

In order for webhooks to come in these two cases, you need to add employees to the personal account and enable one of them in the integration settings to turn on the "Gets new clients" slider.

**Case 3:** When clicking the "+" button in the "Deals" list to create a new deal inside the Wazzup chats:

We first check if the contact already exists in our database.

If the contact already exists, we send a webhook to initiate deal creation:

```
 {
createDeal: {
responsibleUserId: '1', // the id of the user who was selected in turn or was the first to respond
contacts: ['1'] // link of the deal with a newly created contact
source: 'auto'|'byUser', // auto - on incoming or outgoing message, byUser - by the button in the "Deals" dropdown
},
}
```

If the contact does not exist, we first send a webhook to initiate contact creation:

```
 {
createContact: {
responsibleUserId: '1', // id of the user who was selected in turn or was the first to respond
name: 'contacts.name', // contact name from the contacts table
contactData: [{ chatType, chatId }],
source: 'auto'|'byUser', // auto - on incoming or outgoing message, byUser - by button
},
}

```

After that, the CRM should create the contact and respond with 200 OK along with a JSON object of the new entity, matching the CRUD route signature for contacts.

Then, we will send a webhook to initiate deal creation.

Subsequently, the CRM should create the deal and similarly respond with 200 OK and a JSON object of the new entity, matching the CRUD route signature for deals.

If the contact, the deal are already created, then Wazzup will not resend the webhook even if the deal is closed: "close": "true"