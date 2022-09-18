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
    application_id::Snowflake
    message_reference::MessageReference
    message_flags::Int
    flgas::Int
    # referenced_message    # currently not supported due to self-referencing structure
    interaction::MessageInteraction
    thread::DiscordChannel
    # components::Vect{Component}  # currently not supported due to self-referencing structure
    sticker_items::Vector{StickerItem}
    stickers::Vector{Sticker}
end
