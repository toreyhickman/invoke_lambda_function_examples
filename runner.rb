require 'dotenv/load'
require 'aws-sdk-lambda'
require 'byebug'
require "base64"
require 'pp'

CLIENT = Aws::Lambda::Client.new

def send_message_to_facebook(message: "Hello.", user_id: ENV["WORKPLACE_USER_ID"])
  CLIENT.invoke({
    client_context: Base64.encode64({}.to_json),
    invocation_type: "RequestResponse",
    function_name: ENV["SEND_MESSAGE_TO_FACEBOOK_LAMBDA"],
    payload: {
      inputText: "",
      intents: [],
      requestContext: {},
      responseContext: {
        facebook: {
          user: {
            id: user_id,
            conversation: ENV["WATSON_WORKSPACE_NAME"]
          }
        }
      },
      entities: [],
      outputText: [],
      session: {},
      actionParameters:[{
        name: "message",
        value: message
      },
      {
        name: "message-type",
        value: "quick-reply"
      },
      {
        name: "replies",
        value: [
          {
            title: "whitelabel",
            payload: "whitelabel"
          }
        ]
      }
    ]
    }.to_json
  })
end

def schedule_message(time: (Time.now.utc + 120), message: "Hello.", user_id: ENV["WORKPLACE_USER_ID"])
  CLIENT.invoke({
    client_context: Base64.encode64({}.to_json),
    invocation_type: "RequestResponse",
    function_name: ENV["SCHEDULED_ACTIONS_LAMBDA"],
    payload: {
      inputText: "",
      intents: [],
      requestContext: {},
      responseContext: {
        facebook: {
          user: {
            id: user_id,
            conversation: ENV["WATSON_WORKSPACE_NAME"]
          }
        }
      },
      entities: [],
      outputText: [],
      session: {
        conversation: "Outside of Workplace/Watson",
        user: "Some process"
      },
      actionParameters:[
        {
          "name": "action",
          "value": "save"
        },
        {
          "name": "cronExpression",
          "value": to_cron_expression(time)
        },
        {
          "name": "actions",
          "value": [
            {
              "function": "Skill-SendMessageToFacebook",
              "parameters": [
                {
                  "name": "message",
                  "value": message
                },
                {
                  name: "message-type",
                  value: "quick-reply"
                },
                {
                  name: "replies",
                  value: [
                    {
                      title: "whitelabel",
                      payload: "whitelabel"
                    }
                  ]
                }
              ],
              "responseContext": {
                "facebook": {
                  "user": {
                    "id": user_id,
                    "conversation": ENV["WATSON_WORKSPACE_NAME"]
                  }
                }
              }
            }
          ]
        }
      ]
    }.to_json
  })
end

def to_cron_expression(time)
  time.strftime("0 %-M %k %e %-m * %Y")
end

send_message_to_facebook(message: "Sending this now.")
schedule_message(message: "Scheduling this to be sent later.")
