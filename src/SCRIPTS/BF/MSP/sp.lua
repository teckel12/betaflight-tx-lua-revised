
LOCAL_SENSOR_ID  = 0x0D
REMOTE_SENSOR_ID = 0x1B
REQUEST_FRAME_ID = 0x30
REPLY_FRAME_ID   = 0x32

protocol.mspSend = function(payload)
    local dataId = 0
    dataId = payload[1] + bit32.lshift(payload[2],8)
    local value = 0
    value = payload[3] + bit32.lshift(payload[4],8)
        + bit32.lshift(payload[5],16) + bit32.lshift(payload[6],24)
    return sportTelemetryPush(LOCAL_SENSOR_ID, REQUEST_FRAME_ID, dataId, value)
end

protocol.mspRead = function(cmd)
    return mspSendRequest(cmd, {})
end

protocol.mspWrite = function(cmd, payload)
    return mspSendRequest(cmd, payload)
end

protocol.mspPoll = function()
    local sensorId, frameId, dataId, value = sportTelemetryPop()
    if sensorId == REMOTE_SENSOR_ID and frameId == REPLY_FRAME_ID then
        local payload = {}
        payload[1] = bit32.band(dataId,0xFF)
        dataId = bit32.rshift(dataId,8)
        payload[2] = bit32.band(dataId,0xFF)
        payload[3] = bit32.band(value,0xFF)
        value = bit32.rshift(value,8)
        payload[4] = bit32.band(value,0xFF)
        value = bit32.rshift(value,8)
        payload[5] = bit32.band(value,0xFF)
        value = bit32.rshift(value,8)
        payload[6] = bit32.band(value,0xFF)
        return mspReceivedReply(payload)
    end
    return nil
end
