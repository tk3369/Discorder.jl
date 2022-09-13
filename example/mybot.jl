# NOTE: Make sure that DISCORD_BOT_TOKEN is already set in the environment.

using Discorder

port = 6000

# Start gateway server
@async serve(config_file_path="etc/dev.toml", publisher=ZMQPublisher(port))

# Create bot
bot = SimpleBot()

# Register ,echo command
register!(bot, CommandTrigger(',', r"echo ")) do client, message
    msg = strip(message.content[6:end])
    @info "message content = $msg"
    create_message(client, message.channel_id; content="$msg")
end

# Register reaction add handler
register!(bot, ReactionAddTrigger()) do client, reaction_add_event
    @info "reaction event " reaction_add_event.emoji.name
end

# Run bot event loop
start(bot, port)
