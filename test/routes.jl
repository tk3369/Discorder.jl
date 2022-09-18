const UP = "👍"
const DOWN = "👎"
const client = D.BotClient()

@testset "A bunch of HTTP interactions" begin
    playback("responses.bson") do
        # Create a guild to play around in.
        guild = D.create_guild(client; name="MyGuild")
        user = D.get_current_user(client)
        try
            # Check that we can use either the object or the ID.
            @test D.get_guild(client, guild.id).id == guild.id
            @test D.get_guild(client, guild).id == guild.id

            # Loading channels.
            channels = D.get_guild_channels(client, guild)

            # By default, 4 channels are created automatically
            @test length(channels) == 4
            @test map(ch -> (ch.type, ch.name), channels) == [
                (D.ChannelType.GUILD_CATEGORY, "Text Channels"),
                (D.ChannelType.GUILD_CATEGORY, "Voice Channels"),
                (D.ChannelType.GUILD_TEXT, "general"),
                (D.ChannelType.GUILD_VOICE, "General"),
            ]

            # Reordering channels (a good test for ArrayBody).
            text_general = channels[3]
            channel = D.create_guild_channel(client, guild; name="test")
            D.modify_guild_channel_positions(
                client,
                guild;
                positions=[
                    (; id=text_general.id, position=5), (; id=channel.id, position=3)
                ],
            )
            @test D.get_channel(client, text_general.id).position == 5
            @test D.get_channel(client, channel.id).position == 3

            # Update + delete channel.
            channel = D.modify_channel(client, channel; name="test2")
            @test channel.name == "test2"
            D.delete_channel(client, channel)
            @test length(D.get_guild_channels(client, guild)) == 4

            # Create + get messages.
            channel = text_general
            message = D.create_message(client, channel; content="hello")
            @test message.content == "hello"
            @test D.get_channel_message(client, channel, message).id == message.id
            messages = D.get_channel_messages(client, channel)
            @test length(messages) == 1 && messages[1].id == message.id
            @test length(messages) == 1 && messages[1].id == message.id

            # Creating, listing, deleting individual reactions.
            D.create_reaction(client, channel, message, UP)
            users = D.get_reactions(client, channel, message, UP)
            @test length(users) == 1 && users[1].id == user.id
            @test length(D.get_reactions(client, channel, message, UP)) == 1
            D.delete_own_reaction(client, channel, message, UP)
            @test isempty(D.get_reactions(client, channel, message, UP))

            # Delete all reactions
            D.create_reaction(client, channel, message, UP)
            D.create_reaction(client, channel, message, DOWN)
            D.delete_all_reactions(client, channel, message)
            @test isempty(D.get_reactions(client, channel, message, DOWN))

            # Updating + deleting messages.
            @test D.edit_message(client, channel, message; content="a").content == "a"
            D.delete_message(client, channel, message)
            @test isempty(D.get_channel_messages(client, channel))

            # Create and delete multiple messages
            ids = map(i -> D.create_message(client, channel; content="hi").id, 1:5)
            @test length(D.get_channel_messages(client, channel)) == 5
            D.bulk_delete_messages(client, channel; messages=ids)
            sleep(1) # give it a little time to really delete the messages
            @test isempty(D.get_channel_messages(client, channel))

            # Listing, creating, deleting invites.
            @test isempty(D.get_channel_invites(client, channel))
            @test isempty(D.get_guild_invites(client, guild))
            invite = D.create_channel_invite(client, channel)
            invites = D.get_channel_invites(client, channel)
            @test length(invites) == 1 && invites[1].code == invite.code
            invites = D.get_guild_invites(client, guild)
            @test length(invites) == 1 && invites[1].code == invite.code
            @test D.get_invite(client, invite).code == invite.code
            @test D.delete_invite(client, invite).code == invite.code
            @test isempty(D.get_channel_invites(client, channel))
            @test isempty(D.get_guild_invites(client, guild))

            # Pins + typing.
            D.trigger_typing_indicator(client, channel)
            @test isempty(D.get_pinned_messages(client, channel))
            message = D.create_message(client, channel; content="pin")
            D.pin_message(client, channel, message)
            pins = D.get_pinned_messages(client, channel)
            @test length(pins) == 1 && pins[1].id == message.id
            D.unpin_message(client, channel, message)
            @test isempty(D.get_pinned_messages(client, channel))
            D.delete_message(client, channel, message)

            # Emojis.
            @test isempty(D.list_guild_emojis(client, guild))
            # TODO: Figure out how to properly send the payload.
            image_data = base64encode(read(joinpath(@__DIR__, "emoji.png")))
            image_encoded = "data:image/jpeg;base64,$image_data"
            emoji = D.create_guild_emoji(client, guild; name="test", image=image_encoded)
            emojis = D.list_guild_emojis(client, guild)
            @test length(emojis) == 1 && emojis[1].id == emoji.id
            # @test D.modify_guild_emoji(client, guild, emoji; name="test2").name == "test2"
            # @test D.get_guild_emoji(client, guild, emoji).name == "test2"
            D.delete_guild_emoji(client, guild, emoji)
            @test isempty(D.list_guild_emojis(client, guild))

            # Guilds/members.
            @test D.get_guild(client, guild).id == guild.id
            @test D.modify_guild(client, guild; name="test2").name == "test2"
            @test D.get_guild_member(client, guild, user).user.id == user.id
            members = D.list_guild_members(client, guild)
            @test length(members) == 1 && members[1].user.id == user.id
            @test D.modify_current_user_nick(client, guild; nick="test3").nick == "test3"
            @test D.get_guild_member(client, guild, user).nick == "test3"

            # Roles.
            roles = D.get_guild_roles(client, guild)
            @test length(roles) == 1 && roles[1].name == "@everyone"
            role = D.create_guild_role(client, guild; name="test")
            @test role.name == "test"
            roles = D.get_guild_roles(client, guild)
            @test length(roles) == 2 && roles[2].id == role.id
            @test D.modify_guild_role(client, guild, role; name="test2").name == "test2"
            D.add_guild_member_role(client, guild, user, role)
            role_ids = D.get_guild_member(client, guild, user).roles
            @test length(role_ids) == 1 && role_ids[1] == role.id
            D.remove_guild_member_role(client, guild, user, role)
            @test isempty(D.get_guild_member(client, guild, user).roles)
            D.delete_guild_role(client, guild, role)
            roles = D.get_guild_roles(client, guild)
            @test length(roles) == 1 && roles[1].name == "@everyone"

            # Webhooks.
            @test isempty(D.get_channel_webhooks(client, channel))
            @test isempty(D.get_guild_webhooks(client, guild))
            webhook = D.create_webhook(client, channel; name="test")
            @test webhook.name == "test"
            @test D.get_webhook(client, webhook).id == webhook.id
            webhooks = D.get_channel_webhooks(client, channel)
            @test length(webhooks) == 1 && webhooks[1].id == webhook.id
            webhooks = D.get_guild_webhooks(client, guild)
            @test length(webhooks) == 1 && webhooks[1].id == webhook.id
        @test D.modify_webhook(client, webhook; name="test2").name == "test2"
            message = D.execute_webhook(client, webhook, webhook.token; content="hi")
            @test message.content == "hi"
            D.delete_webhook(client, webhook)
            @test isempty(D.get_channel_webhooks(client, channel))
            @test isempty(D.get_guild_webhooks(client, guild))

            # This may return some integrations even for the test guild because some bots
            # may be already attached to the Discord server.
            @test_nowarn D.get_guild_integrations(client, guild)

            # Misc.
            @test eltype(D.get_guild_voice_regions(client, guild)) === D.VoiceRegion
            @test eltype(D.list_voice_regions(client)) === D.VoiceRegion
            @test isempty(D.get_guild_bans(client, guild))
            @test D.get_guild_prune_count(client, guild).pruned == 0
        finally
            D.delete_guild(client, guild)
        end
    end
end

@testset "Sending files" begin
    playback("files.bson") do
        guild = D.create_guild(client; name="MyGuild")
        try
            channel = D.create_guild_channel(client, guild; name="test")
            msg = mktempdir() do dir
                file = joinpath(dir, "foo.json")
                write(file, "{}")
                open(file) do f
                    D.create_message(client, channel; file=f, __boundary__="abcdef")
                end
            end
            attachments = msg.attachments
            @test length(attachments) == 1
            attachment = attachments[1]
            @test attachment.filename == "foo.json"
            @test attachment.size == 2
        finally
            D.delete_guild(client, guild)
        end
    end
end
