local root = BalatroCanvas
root:EnableMouse(true)
root:EnableMouseWheel(true)
root:SetScript("OnMouseDown", function(_, button)
    if love.mousepressed then
        love.mousepressed(love.mouse.getX(), love.mouse.getY(), button == "LeftButton" and 1 or 2)
    end
end)
root:SetScript("OnMouseUp", function(_, button)
    if love.mousereleased then
        love.mousereleased(love.mouse.getX(), love.mouse.getY(), button == "LeftButton" and 1 or 2)
    end
end)
root:SetScript("OnMouseWheel", function(_, delta)
    if love.wheelmoved then
        love.wheelmoved(0, delta)
    end
end)
