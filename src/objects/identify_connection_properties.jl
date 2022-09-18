@discord_object struct IdentifyConnectionProperties
    os_::String
    browser_::String
    device_::String
end

StructTypes.names(::Type{IdentifyConnectionProperties}) = (
    (:os_, Symbol("\$os")),
    (:browser_, Symbol("\$browser")),
    (:device_, Symbol("\$device")),
)
