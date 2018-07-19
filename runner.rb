require 'dotenv/load'
require 'aws-sdk-lambda'
require 'byebug'
require "base64"
require 'pp'

CLIENT = Aws::Lambda::Client.new

def send_message_to_facebook(message = "Hello.", user_id = ENV["WORKPLACE_USER_ID"])
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
            conversation: "workplace_operations"
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

send_message_to_facebook
