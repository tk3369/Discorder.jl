# https://discord.com/developers/docs/resources/guild#ban-object-ban-structure
@discord_object struct Ban
    reason::String
    user::User
end
