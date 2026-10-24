local M = {}
function M.formatTime(seconds)
    local s = math.max(0, math.floor(seconds))
    return string.format("%02d:%02d", math.floor(s / 60), s % 60)
end
function M.insideBox(part, worldPoint, extra)
    local localPoint = part.CFrame:PointToObjectSpace(worldPoint)
    local half = part.Size * 0.5
    extra = extra or 0
    return math.abs(localPoint.X) <= half.X + extra and math.abs(localPoint.Z) <= half.Z + extra
end
return M
