# https://discord.com/developers/docs/resources/channel#message-object-message-activity-structure
@discord_object struct MessageActivity
    type::MessageActivityType.T
    party_id::String
end
