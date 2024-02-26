--[[

    written by Greg
    for epic script, primarily
    plz report any bugs
    
    public version completion date: 2/27/2024 12:32 AM

]]
--[[ Documentation (Bad)

  module:AddPartToQueue() -- adds a part to the drawing queue
  arguments:
  [1]: BasePart -- The part that gets the ESP
  [2?]: {Properties} -- Properties of the ESP Quad object
  [3?]: Drawing -- The text object to add above the rectangle


  module:ClearQueue() -- clears the drawing queue
  arguments: none


  module:RemoveFromQueue()
  arguments:
  [1]: BasePart -- the part to remove from the drawing queue

]]

local function GetCorners(Part: BasePart)
    local Size = Part.Size / 2
    local SizeX, SizeY, SizeZ = Size.X, Size.Y, Size.Z
    local Position = Part.Position
    local PartCFrame = Part.CFrame

    local Corners = {
        (PartCFrame * CFrame.new(-SizeX, SizeY, -SizeZ)).Position,
        (PartCFrame * CFrame.new(-SizeX, SizeY, SizeZ)).Position,
        (PartCFrame * CFrame.new(-Size)).Position,
        (PartCFrame * CFrame.new(SizeX, -SizeY, SizeZ)).Position,
        (PartCFrame * CFrame.new(SizeX, -SizeY, -SizeZ)).Position,
        (PartCFrame * CFrame.new(SizeX, SizeY, -SizeZ)).Position,
        (PartCFrame * CFrame.new(Size)).Position,
        (PartCFrame * CFrame.new(-SizeX, -SizeY, SizeZ)).Position
    }

    return Corners
end

local function Get2DPositions(Positions: {Vector3}): {Vector2}
    local Camera = workspace.CurrentCamera
    local NewPositions = {}
    local OffscreenPoints = {}

    local FacesVisible = 0

    for _, Position in pairs(Positions) do
        local Vector, InViewport = Camera:WorldToViewportPoint(Position)
        local Depth = Vector.Z

        if Depth > 0 then
            FacesVisible += 1
            table.insert(NewPositions, Vector2.new(Vector.X, Vector.Y))
        else
            table.insert(OffscreenPoints, Vector2.new(Vector.X, Vector.Y))
        end
    end

    if FacesVisible > 1 then
        for _, OffscreenPoint in pairs(OffscreenPoints) do
            table.insert(NewPositions, OffscreenPoint)
        end
    end

    return NewPositions
end

local function GetCornerPoints(Part: BasePart): {Vector2}
    local Corners = GetCorners(Part)
    local Points = Get2DPositions(Corners)

    return Points
end

local function Get2DBounds(Points: {Vector2}): {Vector2}
    local Left, Right, Top, Bottom = math.huge, -math.huge, -math.huge, math.huge

    for _, Point in pairs(Points) do
        Left = math.min(Left, Point.x)
        Right = math.max(Right, Point.x)
        Top = math.max(Top, Point.y)
        Bottom = math.min(Bottom, Point.y)
    end

    local TopLeft = Vector2.new(Left, Top)
    local BottomRight = Vector2.new(Right, Bottom)

    return TopLeft, BottomRight
end

local function GetPartBounds(Part: BasePart): {Vector2}
    local Corners = GetCornerPoints(Part)

    if #Corners >= 4 then
        local Bounds = {Get2DBounds(Corners)}
        return Bounds
    end

    return nil
end

local module = {queue = {}}

function module:AddPartToQueue(Part: BasePart, Properties: {}?, Text: any?)
    local NewDrawing = Drawing.new("Quad")
    NewDrawing.Visible = true

    if Properties then
        for Property, Value in pairs(Properties) do
            NewDrawing[Property] = Value
        end
    end

    module.queue[Part] = {NewDrawing, Text or nil}
end

function module:ClearQueue()
    table.clear(module.queue)
end

function module:RemoveFromQueue(Part: BasePart)
    local PartInQueue = module.queue[Part]

    if PartInQueue then
        local Drawing = PartInQueue[1]
        local Text = PartInQueue[2]

        Drawing:Remove()
        if Text then Text:Remove() end
        table.remove(module.queue, table.find(module.queue, Part))
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    for Part, Table in pairs(module.queue) do
        local Drawing = Table[1]
        local Text = Table[2]

        if Part == nil then
            Drawing:Remove()
            if Text then Text:Remove() end
            table.remove(module.queue, table.find(module.queue, Part))
            return
        end

        local Bounds = GetPartBounds(Part)
        
        if Bounds then
            local TopLeft = Bounds[1]
            local BottomRight = Bounds[2]
            local TopRight = Vector2.new(BottomRight.X, TopLeft.Y)
            local BottomLeft = Vector2.new(TopLeft.X, BottomRight.Y)
            
            Drawing.PointA = TopLeft
            Drawing.PointB = TopRight
            Drawing.PointC = BottomRight
            Drawing.PointD = BottomLeft

            if Text then
                Text.Visible = true
                Text.Position = BottomLeft - Vector2.new(0, Text.Size)
            end
        else
            if Text then
                Text.Visible = false
            end
        end
    end
end)

return module
