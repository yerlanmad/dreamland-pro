# Wazzup24 Intergration

# **Working with channels**

A channel is an account in a messenger or social network that is connected to Wazzup in order to communicate with customers.

Channel type and channel are different things:

- channel — a specific account in the messenger from which they correspond. For example, a WhatsApp account with a specific number, a specific bot in Telegram.
- channel type — different types of channels for one messenger: WhatsApp, WABA, Instagram, Telegram, Telegram Bot.

So you can have multiple channels for each "channel type". For example, two WhatsApp numbers are connected. Then there will be two channels (two different numbers), and only one channel type (WhatsApp).

## **Getting the channel list**

In order to get a list of channels that are added to work in Wazzup, you must call:

```
 GET https://api.wazzup24.com/v3/channels
```

### **Request example**

```
 curl --location --request GET 'https://api.wazzup24.com/v3/channels' \

--header 'Authorization: Bearer c8cf90444023482f909520d454368d27'

```

### **Response example**

**HTTP/1.1 200 OK**

```
[
  {
    "channelId": string,
    "transport": "whatsapp",
    "plainId": "79865784457",
    "state": "active"
  }
]

```

### **Response parameters**

| **Parameter** | **Type** | **Description** |
| --- | --- | --- |
| channelId | String | Channel Id (uuidv4) |
| transport | String | Channel type. Available values:
• whatsapp — WhatsApp channel,
• wapi — WABA channel,
• instagram — Instagram channel,
• tgapi — Telegram channel,
• telegram — Telegram Bot channel,
• vk — VK channel,
• avito — Avito channel. |
| plainId | String | Phone number, username or ID in the messenger |
| state | String | Channel status:
• active— channel is active,
• init — channel is starting,
• disabled — the channel is turned off: it was removed from subscription or deleted with messages saved,
• phoneUnavailable — no connection to the phone,
• qr — QR code must be scanned,
• openElsewhere — the channel is authorized in another Wazzup account,
• notEnoughMoney — the channel is not paid,
• foreignphone — channel QR was scanned by another phone number,
• unauthorized — not authorized,
• waitForPassword — channel is waiting for a password for two-factor authentication,
• onModeration — the WABA channel is in moderation,
• rejected — the WABA channel is rejected. |

# **Sending messages**

In this article, we will thoroughly examine the process of sending, editing, and deleting messages via the Wazzup API.

## **Sending Messages**

To send messages it is necessary to call:

```
 POST https://api.wazzup24.com/v3/message
```

In the message body you should pass the parameters of the message with the authorization data in the header.

## **Request Parameters**

### **Request Parameters**

| **Parameter

Required parameters are marked with an asterisk** | **Type** | **Description** |
| --- | --- | --- |
| channelId* | String | Id of the channel (uuidv4) through which to send the message |
| chatType* | String | Available values:
• WhatsApp: "whatsapp",
• Viber: "viber"
• WhatsApp group chat: "whatsgroup",
• Instagram: "instagram",
• Telegram: "telegram". |
| chatId | String | Chat ID (contact's account in messenger):
• for "whatsapp" and "viber" — only numbers, without spaces and special characters in the format 79011112233,
• for "instagram" — an account without "@" in the beginning,
• for "whatsgroup" — comes in webhooks of incoming messages,
• for "telegram" — comes in webhooks of incoming messages and in response to a request when sending an outgoing one with phone or username parameters. |
| text | String | Message text. Obligatory if contentUri is not specified. Both text and contentUri cannot be sent at the same time. Restrictions:
• for WhatsApp up to 10 000 characters,
• for Instagram up to 1000 characters,
• for WABA up to 550 characters in a template message, and 1024 characters in a regular message,
• for Telegram up to 4096 characters.
Whatsapp, WABA, Viber, Telegram Bot messages can be formatted using the following symbols: 
• *bold* 
• _italic_ 
• ```Monospaced``` 
• ~strikethrough~ 
Telegram Bot messages can also be formatted using the following tags: 
• — for bold text 
• — italic 
• — underlined 
• — strikethrough 
Telegram Personal, Instagram messages cannot be formatted. |
| contentUri | String | A link to the file to send. Required if text is not specified.
The content must be downloaded via a link without redirects.
An attempt to download content will be made as soon as the request is received, i.e. short-lived links can be made. There may be restrictions on the type and size of content, specific to each messenger.
Both text and contentUri cannot be transmitted at the same time. |
| refMessageId | String | Id of the message to cite. |
| crmUserId | String | CRM user id specified with CRUD users. If specified, and if such a user already exists, we will save his id and name as when sending via iframe
Does not work when connecting via Sidecar API |
| crmMessageId | String | Message identifier on the CRM side. Needed to make the routing idempotent. |
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |

Route is not idempotent! Repeated requests with the same content will result in sending several identical messages. To protect against possible duplicate messages, you can add the crmMessageId property unique to the message.

If it was sent, then if another request with the same **crmMessageId** is received, the message will not be sent, the error *400 Bad Request, { error: 'repeatedCrmMessageId', description: 'You have already sent message with the same crmMessageId' }* will be returned.

## **Request examples**

**Regular message**

```
fetch("https://api.wazzup24.com/v3/message", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    "Authorization": "Bearer {apiKey|sidecarApiKey}",
  },
  body: {
    channelId: "e0629e11-0f67-4567-92a9-2237e91ec1b9",
    refMessageId: "61e5a375-1760-452f-ad73-5318844ffc4f",
    crmUserId: "string-user-id",
    crmMessageId: "string-crm-message-id",
    chatId: "string-chat-id",
    chatType: "whatsapp",
    text: "message text"
  },
});
```

## **Response**

If you send a template without a payload via the API, we will send the text of the corresponding button in the response message webhook.If you send an interactive message without a payload, we will send the button’s serial number, starting from 0.

| **Parameter** | **Type** | **Description** |
| --- | --- | --- |
| messageId | String | Message identifier.
Specified only when code=OK |
| chatId | String | Chat Id.
Specified only when code=OK |

## **Response example**

```
HTTP/1.1 201 OK
{
    "messageId": "f66c53a6-957a-46b2-b41b-5a2ef4844bcb",
    "chatId": "79999999999"
}

```

## **Errors when sending messages**

If the request contains incorrect data or parameters, the system will return one of the following errors:

**1. Invalid Parameter Values**

If a parameter value does not meet the requirements (for example, channelId is not in UUID format, chatId is not a string, or chatType does not match the allowed values), the API will return the following error:

```
{
    "status":400,
    "requestId":"7ca68797d127735e72b066b0080e2cc0",
    "error":"INVALID_MESSAGE_DATA",
    "description":"Message data is invalid",
    "data": {
        "fields": [
"channelId"
        ]
    }
}
```

**Solution:** Check the validity of the parameter values being passed. The data.fields array will indicate the parameter that contains the error.

**2. Mismatch Between Transport Type and Channel**

If the request specifies a channelId with one transport type, but the chatType belongs to another transport, the API will return the following error:

```
{
    "status":400,
    "requestId":"21a9be7692d378b0270e7fc1d993381a",
    "error":"WRONG_TRANSPORT",
    "description":"You can't send message to vk chat from whatsapp transport",
    "data": {
        "channelId":"dffa1c7b-6db8-4b8f-b559-91166aba879e",
        "transport":"whatsapp",
        "chatType":"vk"
    }
}
```

Solution: Ensure that chatType matches the transport type specified in channelId.

**3. Reusing crmMessageId**

If the request includes a crmMessageId that was already used within the last 60 seconds, the API will return the following error:

```
{
    "status":400,
    "requestId":"c1005276e8a2b5aa23fcc94407d39f49",
    "error":"REPEATED_CRM_MESSAGE_ID",
    "description":"You have already sent message with same crmMessageId",
    "data": {
        "crmMessageId":"1"
    }
}
```

**Solution:** Use unique crmMessageId values for each message. The system checks for duplicates within a 60-second window.

## **Message Management**

Once a message is sent, it can be edited or deleted, provided the channel supports these actions.

### **Editing Messages**

Wazzup supports editing sent messages. You can change either the text or the attachment, but not both at the same time.

```
PATCH https://api.wazzup24.com/v3/message/:messageId
```

Include the API key in the request header:

```
"Authorization": "Bearer {apiKey|sidecarApiKey}"
```

How to edit a message:

- Specify the new message text in the text field.
- If you need to replace the attachment, use contentUri.
- You cannot change both the text and the attachment simultaneously.

| **Parameter** | **Type** | **Description** |
| --- | --- | --- |
| messageId | String | Path parameter for message identification |
| crmUserId | String | CRM user ID, specified using CRUD users |
| text | String | Message text. Required if contentUri is not specified. text and contentUri cannot be used simultaneously |
| contentUri | String | URL of the file to be sent. Required if text is not specified |

**Example usage for text messages:**

```
curl
--location
--request PATCH 'https://api.wazzup24.com/v3/message/6f1b3c67-3008-488b-9abc-12fcac6de134' \
--header 'Authorization: Bearer {apiKey|sidecarApiKey}' \
--header 'Content-Type: application/json' \
--data '{
"text": "Updated message text",
"crmUserId": "2e0df379-0e3c-470f-9b36-06b9e34c3bdb"
}'
```

**Example usage for messages with attachments:**

```
curl
--location
--request PATCH 'https://api.wazzup24.com/v3/message/6f1b3c67-3008-488b-9abc-12fcac6de134' \
--header 'Authorization: Bearer {apiKey|sidecarApiKey}' \
--header 'Content-Type: application/json' \
--data '{
"contentUri": "https://example.com/image.png",
"crmUserId": "2e0df379-0e3c-470f-9b36-06b9e34c3bdb"
}'
```

### **Deleting Messages**

To delete a message, use the following method:

```
DELETE https://api.wazzup24.com/v3/message/:messageId
```

Include the API key in the request header:

```
"Authorization": "Bearer {apiKey|sidecarApiKey}"
```

**Example of message deletion:**

```
curl
--location
--request DELETE 'https://api.wazzup24.com/v3/message/6f1b3c67-3008-488b-9abc-12fcac6de134' \
--header 'Authorization: Bearer {apiKey|sidecarApiKey}'
```

### **Errors when sending, editing, and deleting messages**

| **Error code** | **Description** |
| --- | --- |
| BALANCE_IS_EMPTY | The WABA subscription balance has run out of funds. |
| MESSAGE_WRONG_CONTENT_TYPE | Invalid content type. Appears if the content type could not be detected or is not supported. |
| MESSAGE_ONLY_TEXT_OR_CONTENT | The message can contain text or content. You can't send text and content to WhatsApp and Instagram at the same time. |
| MESSAGE_NOTHING_TO_SEND | No message text was found. |
| MESSAGE_TEXT_TOO_LONG | The length of the text message exceeds 10 000 characters. |
| MESSAGES_TOO_LONG_INSTAGRAM | The Instagram message text exceeds 10,000 characters. |
| MESSAGES_TOO_LONG_TELEGRAM | The Telegram message text exceeds 4096 characters. |
| MESSAGES_TOO_LONG_WABA | The WABA message text is too long. The maximum is 1024 characters for the title and 4096 characters for the main text. |
| MESSAGES_CONTENT_CAN_NOT_BE_BLANK | A file with content cannot be empty.
Occurs when sending a non-text message to which no content has been attached. |
| MESSAGES_CONTENT_SIZE_EXCEEDED | Content exceeds the allowable size of 10 MB. |
| MESSAGES_TEXT_CAN_NOT_BE_BLANK | The text message cannot be empty. |
| CHANNEL_NOT_FOUND | The channel through which the message is sent is not found in the integration. |
| CHANNEL_BLOCKED | The channel through which the message is sent is off. |
| CHANNEL_WAPI_REJECTED | The WABA channel is blocked. |
| MESSAGE_DOWNLOAD_CONTENT_ERROR | Failed to download content from the specified link. |
| MESSAGES_NOT_TEXT_FIRST | On the ["Inbox" tariff](https://wazzup24.com/help/payment-en/price-plans-en/?_gl=1*19ri4lc*_gcl_au*MTI4NTEzMzEyNi4xNzQ0NjMyNjY1*_ga*MjIyNjYzODg0LjE3NDQ2MzI2NjU.*_ga_7X6RZSKPXF*MTc0NDY5MzcxOC4zLjEuMTc0NDY5MzgwOC42MC4wLjkxMTQwMjYyMg..#:~:text=Start-,Inbox,-Pro), you cannot write first. |
| MESSAGES_IS_SPAM | Wazzup rated this message as spam. |
| VALIDATION_ERROR | Validation error of the parameter passed to the query. |
| CHANNEL_NO_MONEY | The channel is not paid and has the status of "Not Paid". |
| MESSAGE_CHANNEL_UNAVAILABLE | The channel from which the message is sent is not available.
The channel has the status "Phone Unavailable" or "Wait a Minute". |
| MESSAGES_ABNORMAL_SEND | The chat type does not match the source of the contact.
For example, this error can occur if you try to send a message from the WhatsApp channel to the Instagram channel. |
| MESSAGES_INVALID_CONTACT_TYPE | The chat type does not match the Instagram contact source.
For example, this error can occur if you are trying to send a message from an Instagram channel to a WhatsApp channel. |
| MESSAGES_CAN_NOT_ADD | The message has not been sent. An unexpected server error occurred. |
| MESSAGES_CONTENT_SIZE_EXCEEDED_WABA | The content exceeds the allowed size. For Telegram, the maximum photo size is 5 MB, and for other content, it's 16 MB. |
| MESSAGES_CONTENT_SIZE_EXCEEDED_TELEGRAM | The content exceeds the allowed size. For Telegram, the maximum photo size is 5 MB, and for other content, it's 20 MB. |
| MESSAGES_TOO_LONG_VIBER | The Viber message text exceeds 6999 characters. |
| MESSAGES_TOO_LONG_WABA_HEADER | The WABA template title text exceeds 60 characters. |
| MESSAGES_TOO_LONG_WABA_TEMPLATE | The WABA template text exceeds 1024 characters. |
| REFERENCE_MESSAGE_NOT_FOUND | An error occurs when quoting if the message to which the quote is attached cannot be found.
Check that the message identifier received from Wazzup is passed as the refId. |
| UNKNOWN_ERROR | Unknown error.
[Contact support.](https://wazzup24.com/contact-en/) |
| UNKNOWN_ERROR_WITH_TRACE_ID | Unknown error. Please contact us for assistance with the error trace ID. |
| MESSAGES_EDITING_TIME_EXPIRED | The message editing time has expired. The message can only be edited within a set period after sending. |
| MESSAGES_CONTAIN_BUTTONS | The message contains buttons and cannot be edited. |
| MESSAGES_ONLY_TEXT_OR_CONTENT | A message can contain only text or an attachment. Both cannot be sent simultaneously. |
| CHANNEL_INVALID_TRANSPORT_FOR_EDITING | The channel does not support message editing. |
| CHANNEL_INVALID_TRANSPORT_FOR_CONTENT_EDITING | The channel does not support editing message content (e.g., attachments). |
| CHAT_NO_ACCESS | No access to the specified chat. Check access settings. |
| MESSAGES_NOT_FOUND | The message was not found or does not contain any content. |
| CHANNEL_LIMIT_EXCEEDED | The limit of active dialogues for the channel has been exceeded. |
| MESSAGES_DELETION_TIME_EXPIRED | The deletion time for the message has expired. The message can only be deleted within a set period after sending. |
| CHANNEL_INVALID_TRANSPORT_FOR_DELETION | The channel does not support message deletion. |
| TEMPLATE_REJECTED | Meta has restricted the template. Try another one or wait for an incoming message. |
| BAD_CONTACT | Message not sent. Number may not be on WhatsApp or uses an old version. Try later. |