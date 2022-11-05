# NOTE: Make sure that DISCORD_BOT_TOKEN is already set in the environment.

using Discorder

port = 6000

bot = Bot()

# Returing `BotExit()` from a handler would exit out of the event loop
# gracefully.
register!(bot, CommandTrigger(r",bye")) do client, message
    create_message(
        client,
        message.channel_id;
        content="ok, admin bot is exiting...",
        message_reference=MessageReference(; message_id=message.id),
    )
    return BotExit()
end

start(bot, port)
