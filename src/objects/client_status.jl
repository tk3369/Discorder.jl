# https://discord.com/developers/docs/topics/gateway#client-status-object
@discord_object struct ClientStatus
    desktop::String
    mobile::String
    web::String
end
