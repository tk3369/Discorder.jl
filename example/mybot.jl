# NOTE: Make sure that DISCORD_BOT_TOKEN is already set in the environment.

using Revise, Discorder

port = 6000

# Start gateway server
gw = Ref{GatewayTracker}()
server = @async serve(tracker_ref=gw, config_file_path="etc/dev.toml", publisher=ZMQPublisher(port))

# Create bot
bot = Bot()

# Register ,echo command
register!(bot, CommandTrigger(r",echo ")) do client, message
    msg = strip(message.content[6:end])
    @info "message content = $msg"
    create_message(client, message.channel_id; content="ok, you said: $msg")
end

# Register reaction add handler
register!(bot, ReactionAddTrigger()) do client, reaction_add_event
    @info "reaction event " reaction_add_event.emoji.name
end

register!(bot, CommandTrigger(r",bye")) do client, message
    return BotExit()
end

# Run bot event loop
start(bot, port)
