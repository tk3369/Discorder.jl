# https://discord.com/developers/docs/resources/channel#message-object-message-structure
@discord_object struct Message
    id::Snowflake
    channel_id::Snowflake
    guild_id::Snowflake
    author::User
    member::GuildMember # partial
    content::String
    timestamp::Timestamp
    edited_timestamp::Timestamp
    tts::Bool
    mention_everyone::Bool
    mentions::Vector{User}
    mention_roles::Vector{Snowflake}  # id's are mapped to Role objects
    mention_channels::Vector{ChannelMention}
    attachments::Vector{Attachment}
    embeds::Vector{Embed}
    reactions::Vector{Reaction}
    nonce::Union{Int, String}
    pinned::Bool
    webhook_id::Snowflake
    type::MessageType.T
    activity::MessageActivity
    application::Application
    message_reference::MessageReference
    message_flags::Int
end
