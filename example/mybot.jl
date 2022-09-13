# NOTE: Make sure that DISCORD_BOT_TOKEN is already set in the environment.

using Revise, Discorder

port = 6000

# Start gateway server
gw = Ref{GatewayTracker}()
server = @async serve(tracker_ref=gw, config_file_path="etc/dev.toml", publisher=ZMQPublisher(port))

# Create bot
bot = Bot()

# Register ,echo command
register!(bot, CommandTrigger(r",echo (.*)")) do client, message, str
    @info "message content = $str"
    create_message(client, message.channel_id; content="ok, you said: $str")
end

# Register reaction add handler
register!(bot, ReactionAddTrigger()) do client, reaction_add_event, emoji_name
    @info "reaction event " emoji_name
end

register!(bot, CommandTrigger(r",bye")) do client, message
    create_message(client, message.channel_id; content="ok, bot is exiting...")
    return BotExit()
end

# Run bot event loop
start(bot, port)
