local ImGui = {
	Animations = {
		Buttons = {
			MouseEnter = { BackgroundTransparency = 0.5 },
			MouseLeave = { BackgroundTransparency = 0.7 }
		},
		Tabs = {
			MouseEnter = { BackgroundTransparency = 0.5 },
			MouseLeave = { BackgroundTransparency = 1 }
		},
		Inputs = {
			MouseEnter = { BackgroundTransparency = 0 },
			MouseLeave = { BackgroundTransparency = 0.5 }
		},
		WindowBorder = {
			Selected = { Transparency = 0, Thickness = 1 },
			Deselected = { Transparency = 0.7, Thickness = 1 }
		}
	},
	Windows = {},
	Animation = TweenInfo.new(0.1),
	UIAssetId = "rbxassetid://76246418997296",
	ThemeManager = {},
	SaveManager = {}
}

local NullFunction = function() end
local CloneRef = cloneref or function(_) return _ end
local function GetService(...) return CloneRef(game:GetService(...)) end

function ImGui:Warn(...)
	if self.NoWarnings then return end
	return warn("[IMGUI]", ...)
end

local TweenService = GetService("TweenService")
local UserInputService = GetService("UserInputService")
local Players = GetService("Players")
local CoreGui = GetService("CoreGui")
local RunService = GetService("RunService")
local HttpService = GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local Mouse = LocalPlayer:GetMouse()

local IsStudio = RunService:IsStudio()
ImGui.NoWarnings = not IsStudio

function ImGui:FetchUI()
	local CacheName = "DepsoImGui"
	if _G[CacheName] then
		self:Warn("Prefabs loaded from Cache")
		return _G[CacheName]
	end
	local UI = nil
	if not IsStudio then
		local UIAssetId = ImGui.UIAssetId
		UI = game:GetObjects(UIAssetId)[1]
	else
		local UIName = "DepsoImGui"
		UI = PlayerGui:FindFirstChild(UIName) or script.DepsoImGui
	end
	_G[CacheName] = UI
	return UI
end

local UI = ImGui:FetchUI()
local Prefabs = UI.Prefabs
ImGui.Prefabs = Prefabs
Prefabs.Visible = false

local AddionalStyles = {
	[{ Name="Border" }] = function(GuiObject, Value, Class)
		local Outline = GuiObject:FindFirstChildOfClass("UIStroke")
		if not Outline then return end
		local BorderThickness = Class.BorderThickness
		if BorderThickness then Outline.Thickness = BorderThickness end
		Outline.Enabled = Value
	end,
	[{ Name="Ratio" }] = function(GuiObject, Value, Class)
		local RatioAxis = Class.RatioAxis or "Height"
		local AspectRatio = Class.Ratio or 4/3
		local AspectType = Class.AspectType or Enum.AspectType.ScaleWithParentSize
		local Ratio = GuiObject:FindFirstChildOfClass("UIAspectRatioConstraint")
		if not Ratio then Ratio = ImGui:CreateInstance("UIAspectRatioConstraint", GuiObject) end
		Ratio.DominantAxis = Enum.DominantAxis[RatioAxis]
		Ratio.AspectType = AspectType
		Ratio.AspectRatio = AspectRatio
	end,
	[{ Name="CornerRadius", Recursive=true }] = function(GuiObject, Value, Class)
		local UICorner = GuiObject:FindFirstChildOfClass("UICorner")
		if not UICorner then UICorner = ImGui:CreateInstance("UICorner", GuiObject) end
		UICorner.CornerRadius = Class.CornerRadius
	end,
	[{ Name="Label" }] = function(GuiObject, Value, Class)
		local Label = GuiObject:FindFirstChild("Label")
		if not Label then return end
		Label.Text = Class.Label
		function Class:SetLabel(Text)
			Label.Text = Text
			return Class
		end
	end,
	[{ Name="NoGradient", Aliases = {"NoGradientAll"}, Recursive=true }] = function(GuiObject, Value, Class)
		local UIGradient = GuiObject:FindFirstChildOfClass("UIGradient")
		if not UIGradient then return end
		UIGradient.Enabled = not Value
	end,
	[{ Name="Callback" }] = function(GuiObject, Value, Class)
		function Class:SetCallback(NewCallback)
			Class.Callback = NewCallback
			return Class
		end
		function Class:FireCallback(NewCallback)
			return Class.Callback(GuiObject)
		end
	end,
	[{ Name="Value" }] = function(GuiObject, Value, Class)
		function Class:GetValue()
			return Class.Value
		end
	end
}

function ImGui:GetName(Name)
	return string.format("%s_", Name)
end

function ImGui:CreateInstance(Class, Parent, Properties)
	local Instance = Instance.new(Class, Parent)
	for Key, Value in next, Properties or {} do
		Instance[Key] = Value
	end
	return Instance
end

function ImGui:ApplyColors(ColorOverwrites, GuiObject, ElementType)
	for Info, Value in next, ColorOverwrites do
		local Key = Info
		local Recursive = false
		if typeof(Info) == "table" then
			Key = Info.Name or ""
			Recursive = Info.Recursive or false
		end
		if typeof(Value) == "table" then
			local Element = GuiObject:FindFirstChild(Key, Recursive)
			if not Element then
				if ElementType == "Window" then
					Element = GuiObject.Content:FindFirstChild(Key, Recursive)
					if not Element then continue end
				else
					warn(Key, "was not found in", GuiObject)
					warn("Table:", Value)
					continue
				end
			end
			ImGui:ApplyColors(Value, Element)
			continue
		end
		GuiObject[Key] = Value
	end
end

function ImGui:CheckStyles(GuiObject, Class, Colors)
	for Info, Callback in next, AddionalStyles do
		local Value = Class[Info.Name]
		local Aliases = Info.Aliases
		if Aliases and not Value then
			for _, Alias in Info.Aliases do
				Value = Class[Alias]
				if Value then break end
			end
		end
		if Value == nil then continue end
		Callback(GuiObject, Value, Class)
		if Info.Recursive then
			for _, Child in next, GuiObject:GetChildren() do
				Callback(Child, Value, Class)
			end
		end
	end
	local ElementType = GuiObject.Name
	GuiObject.Name = self:GetName(ElementType)
	local Colors = Colors or {}
	local ColorOverwrites = Colors[ElementType]
	if ColorOverwrites then
		ImGui:ApplyColors(ColorOverwrites, GuiObject, ElementType)
	end
	for Key, Value in next, Class do
		pcall(function()
			GuiObject[Key] = Value
		end)
	end
end

function ImGui:MergeMetatables(Class, Instance)
	local Metadata = {}
	Metadata.__index = function(self, Key)
		local suc, Value = pcall(function()
			local Value = Instance[Key]
			if typeof(Value) == "function" then
				return function(...)
					return Value(Instance, ...)
				end
			end
			return Value
		end)
		return suc and Value or Class[Key]
	end
	Metadata.__newindex = function(self, Key, Value)
		local Key2 = Class[Key]
		if Key2 ~= nil or typeof(Value) == "function" then
			Class[Key] = Value
		else
			Instance[Key] = Value
		end
	end
	return setmetatable({}, Metadata)
end

function ImGui:Concat(Table, Separator)
	Separator = Separator or " "
	local Concatenated = ""
	for Index, String in next, Table do
		Concatenated ..= tostring(String) .. (Index ~= #Table and Separator or "")
	end
	return Concatenated
end

function ImGui:Tween(Instance, Properties, TweenInfoOverride, NoAnimation)
	local TweenInfo = TweenInfoOverride or self.Animation
	if NoAnimation then TweenInfo = TweenInfo.new(0) end
	local Tween = TweenService:Create(Instance, TweenInfo, Properties)
	Tween:Play()
	return Tween
end

function ImGui:GetAnimation(Fast)
	return Fast and TweenInfo.new(0.05) or self.Animation
end

function ImGui:ConnectHover(Config)
	local Parent = Config.Parent
	local OnInput = Config.OnInput or NullFunction
	Parent.MouseEnter:Connect(function()
		OnInput(true, {UserInputType = {Name = "MouseMovement"}})
	end)
	Parent.MouseLeave:Connect(function()
		OnInput(false, {UserInputType = {Name = "MouseMovement"}})
	end)
end

function ImGui:ApplyAnimations(GuiObject, AnimationType)
	local Animations = self.Animations[AnimationType]
	if not Animations then return end
	self:ConnectHover({
		Parent = GuiObject,
		OnInput = function(MouseHovering)
			local Type = MouseHovering and "MouseEnter" or "MouseLeave"
			self:Tween(GuiObject, Animations[Type])
		end
	})
end

function ImGui:ApplyDraggable(Frame)
	local Dragging = false
	local DragInput, MousePos, FramePos
	Frame.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging = true
			MousePos = Input.Position
			FramePos = Frame.Position
			Input.Changed:Connect(function()
				if Input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)
	Frame.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement then
			DragInput = Input
		end
	end)
	UserInputService.InputChanged:Connect(function(Input)
		if Input == DragInput and Dragging then
			local Delta = Input.Position - MousePos
			Frame.Position = UDim2.new(
				FramePos.X.Scale,
				FramePos.X.Offset + Delta.X,
				FramePos.Y.Scale,
				FramePos.Y.Offset + Delta.Y
			)
		end
	end)
end

function ImGui:ApplyResizable(MinSize, Window, ResizeGrab, WindowConfig)
	local Resizing = false
	local ResizeStart, WindowStart
	ResizeGrab.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			Resizing = true
			ResizeStart = Input.Position
			WindowStart = Window.AbsoluteSize
			Input.Changed:Connect(function()
				if Input.UserInputState == Enum.UserInputState.End then
					Resizing = false
				end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(Input)
		if Resizing and Input.UserInputType == Enum.UserInputType.MouseMovement then
			local Delta = Input.Position - ResizeStart
			local NewSize = Vector2.new(
				math.max(MinSize.X, WindowStart.X + Delta.X),
				math.max(MinSize.Y, WindowStart.Y + Delta.Y)
			)
			WindowConfig:SetSize(NewSize)
		end
	end)
end

function ImGui:HeaderAnimate(Header, Visible, Open, TitleBar, ToggleButton)
	local Arrow = ToggleButton:FindFirstChild("Arrow")
	if Arrow then
		self:Tween(Arrow, {
			Rotation = Open and 180 or 0
		})
	end
	self:Tween(Header, {
		Visible = Visible
	})
end

function ImGui:AddTooltip(GuiObject, TooltipText)
	if not TooltipText or TooltipText == "" then return end
	
	local Tooltip = Instance.new("TextLabel")
	Tooltip.Name = "Tooltip"
	Tooltip.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	Tooltip.BorderColor3 = Color3.fromRGB(40, 40, 40)
	Tooltip.BorderSizePixel = 1
	Tooltip.Font = Enum.Font.Code
	Tooltip.TextColor3 = Color3.fromRGB(255, 255, 255)
	Tooltip.TextSize = 13
	Tooltip.Text = TooltipText
	Tooltip.TextWrapped = true
	Tooltip.AutomaticSize = Enum.AutomaticSize.XY
	Tooltip.Visible = false
	Tooltip.ZIndex = 10000
	Tooltip.Parent = ImGui.ScreenGui
	
	local Padding = Instance.new("UIPadding", Tooltip)
	Padding.PaddingLeft = UDim.new(0, 6)
	Padding.PaddingRight = UDim.new(0, 6)
	Padding.PaddingTop = UDim.new(0, 4)
	Padding.PaddingBottom = UDim.new(0, 4)
	
	GuiObject.MouseEnter:Connect(function()
		Tooltip.Visible = true
		local MousePos = UserInputService:GetMouseLocation()
		Tooltip.Position = UDim2.fromOffset(MousePos.X + 10, MousePos.Y + 10)
	end)
	
	GuiObject.MouseLeave:Connect(function()
		Tooltip.Visible = false
	end)
	
	GuiObject.MouseMoved:Connect(function()
		if Tooltip.Visible then
			local MousePos = UserInputService:GetMouseLocation()
			Tooltip.Position = UDim2.fromOffset(MousePos.X + 10, MousePos.Y + 10)
		end
	end)
	
	return Tooltip
end

function ImGui:ContainerClass(Frame, Class, Window)
	local ContainerClass = Class or {}
	local WindowConfig = ImGui.Windows[Window]
	
	function ContainerClass:NewInstance(Instance, Class, Parent)
		Class = Class or {}
		Instance.Parent = Parent or Frame
		Instance.Visible = true
		if WindowConfig.NoGradientAll then
			Class.NoGradient = true
		end
		local Colors = WindowConfig.Colors
		ImGui:CheckStyles(Instance, Class, Colors)
		if Class.NewInstanceCallback then
			Class.NewInstanceCallback(Instance)
		end
		return ImGui:MergeMetatables(Class, Instance)
	end
	
	function ContainerClass:AddLabel(Config)
		Config = Config or {}
		local Label = Prefabs.Label:Clone()
		local TextLabel = Label.TextLabel or Label
		TextLabel.Text = Config.Text or "Label"
		TextLabel.TextSize = Config.Size or 14
		TextLabel.TextWrapped = Config.DoesWrap or false
		TextLabel.TextColor3 = Config.TextColor or Color3.fromRGB(255, 255, 255)
		
		if Config.DoesWrap then
			TextLabel.AutomaticSize = Enum.AutomaticSize.Y
			TextLabel.Size = UDim2.new(1, 0, 0, 0)
		end
		
		function Config:SetText(Text)
			TextLabel.Text = Text
			return Config
		end
		
		function Config:SetColor(Color)
			TextLabel.TextColor3 = Color
			return Config
		end
		
		return self:NewInstance(Label, Config)
	end
	
	function ContainerClass:AddParagraph(Config)
		Config = Config or {}
		Config.DoesWrap = true
		Config.Size = Config.Size or 13
		Config.Text = Config.Text or "Paragraph text here..."
		return self:AddLabel(Config)
	end
	
	function ContainerClass:AddSubtitle(Config)
		Config = Config or {}
		Config.Size = Config.Size or 16
		Config.Text = Config.Text or "Subtitle"
		local Label = self:AddLabel(Config)
		if Label.TextLabel then
			Label.TextLabel.Font = Enum.Font.GothamBold
		end
		return Label
	end
	
	function ContainerClass:AddButton(Config)
		Config = Config or {}
		local Button = Prefabs.Button:Clone()
		local ButtonObj = Button.Button
		ButtonObj.Text = Config.Text or "Button"
		Config.Callback = Config.Callback or NullFunction
		Config.Disabled = Config.Disabled or false
		Config.Risky = Config.Risky or false
		Config.DoubleClick = Config.DoubleClick or false
		Config.Locked = false
		
		local function UpdateButtonState()
			ButtonObj.Active = not Config.Disabled
			ButtonObj.BackgroundColor3 = Config.Disabled and Color3.fromRGB(15, 15, 15) or Color3.fromRGB(35, 35, 35)
			ButtonObj.TextTransparency = Config.Disabled and 0.8 or 0.4
			if Config.Risky then
				ButtonObj.TextColor3 = Color3.fromRGB(255, 50, 50)
			end
		end
		
		ButtonObj.Activated:Connect(function()
			if Config.Disabled or Config.Locked then return end
			
			if Config.DoubleClick then
				Config.Locked = true
				local OriginalText = ButtonObj.Text
				ButtonObj.Text = "Are you sure?"
				ButtonObj.TextColor3 = Color3.fromRGB(125, 85, 255)
				
				task.delay(0.5, function()
					if Config.Locked then
						ButtonObj.Text = OriginalText
						ButtonObj.TextColor3 = Config.Risky and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(255, 255, 255)
						Config.Locked = false
					end
				end)
				
				local Clicked = false
				local Connection
				Connection = ButtonObj.Activated:Connect(function()
					Clicked = true
					ButtonObj.Text = OriginalText
					ButtonObj.TextColor3 = Config.Risky and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(255, 255, 255)
					Connection:Disconnect()
					Config.Locked = false
					Config.Callback()
				end)
				
				return
			end
			
			Config.Callback()
		end)
		
		function Config:SetText(Text)
			ButtonObj.Text = Text
			return Config
		end
		
		function Config:SetDisabled(Disabled)
			Config.Disabled = Disabled
			UpdateButtonState()
			return Config
		end
		
		function Config:AddButton(SubConfig)
			SubConfig = SubConfig or {}
			local SubButton = Prefabs.Button:Clone()
			local SubButtonObj = SubButton.Button
			SubButtonObj.Text = SubConfig.Text or "Sub-Button"
			SubButtonObj.Size = UDim2.fromScale(0.48, 1)
			SubConfig.Callback = SubConfig.Callback or NullFunction
			SubConfig.Disabled = SubConfig.Disabled or false
			SubConfig.Risky = SubConfig.Risky or false
			SubConfig.DoubleClick = SubConfig.DoubleClick or false
			SubConfig.Locked = false
			
			ButtonObj.Size = UDim2.fromScale(0.48, 1)
			local Holder = Button:FindFirstChild("Holder") or Instance.new("Frame", Button)
			Holder.BackgroundTransparency = 1
			Holder.Size = UDim2.fromScale(1, 1)
			
			local Layout = Holder:FindFirstChildOfClass("UIListLayout")
			if not Layout then
				Layout = Instance.new("UIListLayout", Holder)
				Layout.FillDirection = Enum.FillDirection.Horizontal
				Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
				Layout.Padding = UDim.new(0, 8)
			end
			
			ButtonObj.Parent = Holder
			SubButtonObj.Parent = Holder
			
			local function UpdateSubButtonState()
				SubButtonObj.Active = not SubConfig.Disabled
				SubButtonObj.BackgroundColor3 = SubConfig.Disabled and Color3.fromRGB(15, 15, 15) or Color3.fromRGB(35, 35, 35)
				SubButtonObj.TextTransparency = SubConfig.Disabled and 0.8 or 0.4
				if SubConfig.Risky then
					SubButtonObj.TextColor3 = Color3.fromRGB(255, 50, 50)
				end
			end
			
			SubButtonObj.Activated:Connect(function()
				if SubConfig.Disabled or SubConfig.Locked then return end
				
				if SubConfig.DoubleClick then
					SubConfig.Locked = true
					local OriginalText = SubButtonObj.Text
					SubButtonObj.Text = "Sure?"
					SubButtonObj.TextColor3 = Color3.fromRGB(125, 85, 255)
					
					task.delay(0.5, function()
						if SubConfig.Locked then
							SubButtonObj.Text = OriginalText
							SubButtonObj.TextColor3 = SubConfig.Risky and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(255, 255, 255)
							SubConfig.Locked = false
						end
					end)
					
					local Connection
					Connection = SubButtonObj.Activated:Connect(function()
						SubButtonObj.Text = OriginalText
						SubButtonObj.TextColor3 = SubConfig.Risky and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(255, 255, 255)
						Connection:Disconnect()
						SubConfig.Locked = false
						SubConfig.Callback()
					end)
					
					return
				end
				
				SubConfig.Callback()
			end)
			
			function SubConfig:SetText(Text)
				SubButtonObj.Text = Text
				return SubConfig
			end
			
			function SubConfig:SetDisabled(Disabled)
				SubConfig.Disabled = Disabled
				UpdateSubButtonState()
				return SubConfig
			end
			
			UpdateSubButtonState()
			ImGui:ApplyAnimations(SubButtonObj, "Buttons")
			Config.SubButton = SubConfig
			return SubConfig
		end
		
		UpdateButtonState()
		ImGui:ApplyAnimations(ButtonObj, "Buttons")
		return self:NewInstance(Button, Config)
	end
	
	function ContainerClass:AddToggle(Config)
		Config = Config or {}
		local Toggle = Prefabs.Toggle:Clone()
		local ToggleButton = Toggle.ToggleButton
		local Indicator = ToggleButton.Indicator
		Config.Value = Config.Default or false
		Config.Callback = Config.Callback or NullFunction
		Config.Disabled = Config.Disabled or false
		Config.Risky = Config.Risky or false
		Config.Tooltip = Config.Tooltip
		
		local function UpdateToggle(Value)
			Config.Value = Value
			ImGui:Tween(Indicator, {
				BackgroundTransparency = Value and 0 or 1
			})
			if not Config.Disabled then
				Config.Callback(Value)
			end
		end
		
		local function UpdateToggleState()
			ToggleButton.Active = not Config.Disabled
			ToggleButton.BackgroundTransparency = Config.Disabled and 0.5 or 0.7
			Indicator.BackgroundTransparency = Config.Disabled and 0.8 or (Config.Value and 0 or 1)
			if Toggle.Label then
				Toggle.Label.TextTransparency = Config.Disabled and 0.8 or (Config.Value and 0 or 0.4)
				if Config.Risky then
					Toggle.Label.TextColor3 = Color3.fromRGB(255, 50, 50)
				end
			end
		end
		
		ToggleButton.Activated:Connect(function()
			if Config.Disabled then return end
			UpdateToggle(not Config.Value)
		end)
		
		function Config:SetValue(Value)
			UpdateToggle(Value)
			UpdateToggleState()
			return Config
		end
		
		function Config:SetDisabled(Disabled)
			Config.Disabled = Disabled
			UpdateToggleState()
			return Config
		end
		
		Toggle.Label.Text = Config.Text or "Toggle"
		UpdateToggle(Config.Value)
		UpdateToggleState()
		ImGui:ApplyAnimations(ToggleButton, "Buttons")
		
		if Config.Tooltip then
			ImGui:AddTooltip(Toggle, Config.Tooltip)
		end
		
		return self:NewInstance(Toggle, Config)
	end
	
	function ContainerClass:AddCheckbox(Config)
		Config = Config or {}
		local Checkbox = Prefabs.Checkbox:Clone()
		local CheckButton = Checkbox.CheckButton
		local Check = CheckButton.Check
		Config.Value = Config.Default or false
		Config.Callback = Config.Callback or NullFunction
		
		local function UpdateCheckbox(Value)
			Config.Value = Value
			Check.Visible = Value
			Config.Callback(Value)
		end
		
		CheckButton.Activated:Connect(function()
			UpdateCheckbox(not Config.Value)
		end)
		
		function Config:SetValue(Value)
			UpdateCheckbox(Value)
			return Config
		end
		
		Checkbox.Label.Text = Config.Text or "Checkbox"
		UpdateCheckbox(Config.Value)
		ImGui:ApplyAnimations(CheckButton, "Buttons")
		return self:NewInstance(Checkbox, Config)
	end
	
	function ContainerClass:AddSlider(Config)
		Config = Config or {}
		local Slider = Prefabs.Slider:Clone()
		local SliderBar = Slider.SliderBar
		local SliderButton = SliderBar.SliderButton
		local Fill = SliderBar.Fill
		Config.Min = Config.Min or 0
		Config.Max = Config.Max or 100
		Config.Default = Config.Default or Config.Min
		Config.Value = Config.Default
		Config.Callback = Config.Callback or NullFunction
		Config.Increment = Config.Increment or 1
		Config.Rounding = Config.Rounding or 0
		Config.Prefix = Config.Prefix or ""
		Config.Suffix = Config.Suffix or ""
		Config.Disabled = Config.Disabled or false
		Config.Tooltip = Config.Tooltip
		
		local ValueLabel = Slider:FindFirstChild("ValueLabel")
		if not ValueLabel then
			ValueLabel = Instance.new("TextLabel")
			ValueLabel.Name = "ValueLabel"
			ValueLabel.BackgroundTransparency = 1
			ValueLabel.Font = Enum.Font.Code
			ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			ValueLabel.TextSize = 13
			ValueLabel.Size = UDim2.new(0, 60, 1, 0)
			ValueLabel.Position = UDim2.new(1, -65, 0, 0)
			ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
			ValueLabel.Parent = Slider
		end
		
		local function FormatValue(Value)
			local Rounded = Config.Rounding == 0 and math.floor(Value) or tonumber(string.format("%." .. Config.Rounding .. "f", Value))
			return Config.Prefix .. tostring(Rounded) .. Config.Suffix
		end
		
		local function UpdateSlider(Value)
			Value = math.clamp(Value, Config.Min, Config.Max)
			Value = math.floor(Value / Config.Increment + 0.5) * Config.Increment
			if Config.Rounding > 0 then
				Value = tonumber(string.format("%." .. Config.Rounding .. "f", Value))
			end
			Config.Value = Value
			local Percent = (Value - Config.Min) / (Config.Max - Config.Min)
			Fill.Size = UDim2.fromScale(Percent, 1)
			SliderButton.Position = UDim2.fromScale(Percent, 0.5)
			ValueLabel.Text = FormatValue(Value)
			if not Config.Disabled then
				Config.Callback(Value)
			end
		end
		
		local function UpdateSliderState()
			SliderBar.Active = not Config.Disabled
			SliderButton.Active = not Config.Disabled
			SliderBar.BackgroundTransparency = Config.Disabled and 0.8 or 0.5
			Fill.BackgroundTransparency = Config.Disabled and 0.8 or 0
			ValueLabel.TextTransparency = Config.Disabled and 0.8 or 0
		end
		
		local Dragging = false
		SliderButton.InputBegan:Connect(function(Input)
			if Config.Disabled then return end
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				Dragging = true
			end
		end)
		
		UserInputService.InputEnded:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				Dragging = false
			end
		end)
		
		UserInputService.InputChanged:Connect(function(Input)
			if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
				local RelativeX = math.clamp((Mouse.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
				local Value = Config.Min + (Config.Max - Config.Min) * RelativeX
				UpdateSlider(Value)
			end
		end)
		
		SliderBar.InputBegan:Connect(function(Input)
			if Config.Disabled then return end
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				local RelativeX = math.clamp((Input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
				local Value = Config.Min + (Config.Max - Config.Min) * RelativeX
				UpdateSlider(Value)
			end
		end)
		
		function Config:SetValue(Value)
			UpdateSlider(Value)
			return Config
		end
		
		function Config:SetDisabled(Disabled)
			Config.Disabled = Disabled
			UpdateSliderState()
			return Config
		end
		
		function Config:SetMin(Min)
			Config.Min = Min
			UpdateSlider(Config.Value)
			return Config
		end
		
		function Config:SetMax(Max)
			Config.Max = Max
			UpdateSlider(Config.Value)
			return Config
		end
		
		Slider.Label.Text = Config.Text or "Slider"
		UpdateSlider(Config.Value)
		UpdateSliderState()
		
		if Config.Tooltip then
			ImGui:AddTooltip(Slider, Config.Tooltip)
		end
		
		return self:NewInstance(Slider, Config)
	end
	
	function ContainerClass:AddInput(Config)
		Config = Config or {}
		local Input = Prefabs.Input:Clone()
		local InputBox = Input.InputBox
		Config.Value = Config.Default or ""
		Config.Callback = Config.Callback or NullFunction
		Config.Numeric = Config.Numeric or false
		Config.Finished = Config.Finished or false
		Config.ClearTextOnFocus = Config.ClearTextOnFocus ~= false
		Config.Disabled = Config.Disabled or false
		Config.Tooltip = Config.Tooltip
		
		InputBox.Text = Config.Value
		InputBox.PlaceholderText = Config.Placeholder or "Input"
		InputBox.ClearTextOnFocus = Config.ClearTextOnFocus
		
		local function UpdateInput(Value, EnterPressed)
			if Config.Numeric then
				Value = tonumber(Value) or Config.Value
				InputBox.Text = tostring(Value)
			end
			Config.Value = Value
			if not Config.Finished or EnterPressed then
				Config.Callback(Value, EnterPressed)
			end
		end
		
		local function UpdateInputState()
			InputBox.Active = not Config.Disabled
			InputBox.TextEditable = not Config.Disabled
			InputBox.BackgroundTransparency = Config.Disabled and 0.8 or 0.5
			InputBox.TextTransparency = Config.Disabled and 0.8 or 0
		end
		
		InputBox.FocusLost:Connect(function(EnterPressed)
			UpdateInput(InputBox.Text, EnterPressed)
		end)
		
		if not Config.Finished then
			InputBox:GetPropertyChangedSignal("Text"):Connect(function()
				UpdateInput(InputBox.Text, false)
			end)
		end
		
		function Config:SetValue(Value)
			InputBox.Text = tostring(Value)
			Config.Value = Value
			return Config
		end
		
		function Config:SetDisabled(Disabled)
			Config.Disabled = Disabled
			UpdateInputState()
			return Config
		end
		
		Input.Label.Text = Config.Text or "Input"
		UpdateInputState()
		ImGui:ApplyAnimations(InputBox, "Inputs")
		
		if Config.Tooltip then
			ImGui:AddTooltip(Input, Config.Tooltip)
		end
		
		return self:NewInstance(Input, Config)
	end
	
	function ContainerClass:AddDropdown(Config)
		Config = Config or {}
		local Dropdown = Prefabs.Dropdown:Clone()
		local DropdownButton = Dropdown.DropdownButton
		local DropdownLabel = DropdownButton.Label
		local DropdownList = Dropdown.DropdownList
		Config.Values = Config.Values or {}
		Config.DisabledValues = Config.DisabledValues or {}
		Config.Value = Config.Default or ""
		Config.Callback = Config.Callback or NullFunction
		Config.Multi = Config.Multi or false
		Config.SelectedValues = {}
		Config.MaxVisibleItems = Config.MaxVisibleItems or 8
		Config.Disabled = Config.Disabled or false
		Config.Tooltip = Config.Tooltip
		
		local ScrollingFrame = Instance.new("ScrollingFrame")
		ScrollingFrame.BackgroundTransparency = 1
		ScrollingFrame.BorderSizePixel = 0
		ScrollingFrame.Size = UDim2.fromScale(1, 1)
		ScrollingFrame.CanvasSize = UDim2.fromScale(1, 0)
		ScrollingFrame.ScrollBarThickness = 4
		ScrollingFrame.Parent = DropdownList
		
		local ListLayout = Instance.new("UIListLayout", ScrollingFrame)
		ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		
		local function UpdateDropdown()
			if Config.Multi then
				local Selected = {}
				for Value, _ in pairs(Config.SelectedValues) do
					table.insert(Selected, Value)
				end
				DropdownLabel.Text = #Selected > 0 and table.concat(Selected, ", ") or "Select..."
			else
				DropdownLabel.Text = Config.Value ~= "" and Config.Value or "Select..."
			end
		end
		
		local function UpdateDropdownState()
			DropdownButton.Active = not Config.Disabled
			DropdownButton.BackgroundTransparency = Config.Disabled and 0.8 or 0.7
			DropdownLabel.TextTransparency = Config.Disabled and 0.8 or 0
		end
		
		local function CreateOption(Value)
			local IsDisabled = table.find(Config.DisabledValues, Value) ~= nil
			
			local Option = Instance.new("TextButton")
			Option.Size = UDim2.new(1, 0, 0, 25)
			Option.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
			Option.BorderSizePixel = 0
			Option.Text = Value
			Option.TextColor3 = IsDisabled and Color3.fromRGB(128, 128, 128) or Color3.fromRGB(255, 255, 255)
			Option.Font = Enum.Font.Code
			Option.TextSize = 14
			Option.Active = not IsDisabled
			Option.Parent = ScrollingFrame
			
			if not IsDisabled then
				Option.Activated:Connect(function()
					if Config.Multi then
						Config.SelectedValues[Value] = not Config.SelectedValues[Value] or nil
						Option.BackgroundColor3 = Config.SelectedValues[Value] and Color3.fromRGB(55, 55, 55) or Color3.fromRGB(35, 35, 35)
					else
						Config.Value = Value
						DropdownList.Visible = false
					end
					UpdateDropdown()
					Config.Callback(Config.Multi and Config.SelectedValues or Config.Value)
				end)
				
				ImGui:ApplyAnimations(Option, "Buttons")
			end
			
			return Option
		end
		
		DropdownButton.Activated:Connect(function()
			if Config.Disabled then return end
			DropdownList.Visible = not DropdownList.Visible
		end)
		
		function Config:SetValues(Values)
			Config.Values = Values
			for _, Child in ipairs(ScrollingFrame:GetChildren()) do
				if Child:IsA("TextButton") then
					Child:Destroy()
				end
			end
			for _, Value in ipairs(Values) do
				CreateOption(Value)
			end
			ScrollingFrame.CanvasSize = UDim2.fromOffset(0, ListLayout.AbsoluteContentSize.Y)
			return Config
		end
		
		function Config:SetValue(Value)
			Config.Value = Value
			UpdateDropdown()
			return Config
		end
		
		function Config:SetDisabled(Disabled)
			Config.Disabled = Disabled
			UpdateDropdownState()
			return Config
		end
		
		function Config:SetDisabledValues(DisabledValues)
			Config.DisabledValues = DisabledValues
			Config:SetValues(Config.Values)
			return Config
		end
		
		ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			ScrollingFrame.CanvasSize = UDim2.fromOffset(0, ListLayout.AbsoluteContentSize.Y)
			DropdownList.Size = UDim2.fromOffset(
				DropdownList.AbsoluteSize.X,
				math.min(Config.MaxVisibleItems * 25, ListLayout.AbsoluteContentSize.Y)
			)
		end)
		
		Dropdown.Label.Text = Config.Text or "Dropdown"
		Config:SetValues(Config.Values)
		UpdateDropdown()
		UpdateDropdownState()
		ImGui:ApplyAnimations(DropdownButton, "Buttons")
		
		if Config.Tooltip then
			ImGui:AddTooltip(Dropdown, Config.Tooltip)
		end
		
		return self:NewInstance(Dropdown, Config)
	end
	
	function ContainerClass:AddKeybind(Config)
		Config = Config or {}
		local Keybind = Prefabs.Keybind:Clone()
		local KeybindButton = Keybind.KeybindButton
		Config.Value = Config.Default or Enum.KeyCode.Unknown
		Config.Callback = Config.Callback or NullFunction
		Config.Mode = Config.Mode or "Toggle"
		Config.Modes = Config.Modes or {"Always", "Toggle", "Hold"}
		Config.SyncToggleState = Config.SyncToggleState or false
		Config.Toggled = false
		Config.Disabled = Config.Disabled or false
		Config.Tooltip = Config.Tooltip
		
		local Listening = false
		local Holding = false
		
		local function UpdateKeybind()
			KeybindButton.Text = Config.Value.Name
		end
		
		local function UpdateKeybindState()
			KeybindButton.Active = not Config.Disabled
			KeybindButton.BackgroundTransparency = Config.Disabled and 0.8 or 0.7
			KeybindButton.TextTransparency = Config.Disabled and 0.8 or 0
		end
		
		KeybindButton.Activated:Connect(function()
			if Config.Disabled then return end
			Listening = true
			KeybindButton.Text = "..."
		end)
		
		KeybindButton.MouseButton2Click:Connect(function()
			if Config.Disabled then return end
			local CurrentIndex = table.find(Config.Modes, Config.Mode)
			if CurrentIndex then
				local NextIndex = CurrentIndex % #Config.Modes + 1
				Config.Mode = Config.Modes[NextIndex]
				if Config.Tooltip then
					ImGui:AddTooltip(Keybind, Config.Tooltip .. " [" .. Config.Mode .. "]")
				end
			end
		end)
		
		UserInputService.InputBegan:Connect(function(Input)
			if Config.Disabled then return end
			
			if Listening then
				if Input.KeyCode ~= Enum.KeyCode.Unknown then
					Config.Value = Input.KeyCode
					Listening = false
					UpdateKeybind()
				end
				return
			end
			
			if Input.KeyCode == Config.Value then
				if Config.Mode == "Always" then
					Config.Callback(true)
				elseif Config.Mode == "Toggle" then
					Config.Toggled = not Config.Toggled
					Config.Callback(Config.Toggled)
				elseif Config.Mode == "Hold" then
					Holding = true
					Config.Callback(true)
				end
			end
		end)
		
		UserInputService.InputEnded:Connect(function(Input)
			if Config.Disabled then return end
			
			if Input.KeyCode == Config.Value then
				if Config.Mode == "Hold" and Holding then
					Holding = false
					Config.Callback(false)
				end
			end
		end)
		
		function Config:SetValue(Value)
			Config.Value = Value
			UpdateKeybind()
			return Config
		end
		
		function Config:SetDisabled(Disabled)
			Config.Disabled = Disabled
			UpdateKeybindState()
			return Config
		end
		
		function Config:SetMode(Mode)
			if table.find(Config.Modes, Mode) then
				Config.Mode = Mode
			end
			return Config
		end
		
		Keybind.Label.Text = Config.Text or "Keybind"
		UpdateKeybind()
		UpdateKeybindState()
		ImGui:ApplyAnimations(KeybindButton, "Buttons")
		
		if Config.Tooltip then
			ImGui:AddTooltip(Keybind, Config.Tooltip .. " [" .. Config.Mode .. "]")
		end
		
		return self:NewInstance(Keybind, Config)
	end
	
	function ContainerClass:AddColorPicker(Config)
		Config = Config or {}
		local ColorPicker = Prefabs.ColorPicker:Clone()
		local ColorButton = ColorPicker.ColorButton
		local ColorDisplay = ColorButton.ColorDisplay
		Config.Value = Config.Default or Color3.fromRGB(255, 255, 255)
		Config.Callback = Config.Callback or NullFunction
		
		local function UpdateColor()
			ColorDisplay.BackgroundColor3 = Config.Value
			Config.Callback(Config.Value)
		end
		
		ColorButton.Activated:Connect(function()
		end)
		
		function Config:SetValue(Value)
			Config.Value = Value
			UpdateColor()
			return Config
		end
		
		ColorPicker.Label.Text = Config.Text or "Color"
		UpdateColor()
		ImGui:ApplyAnimations(ColorButton, "Buttons")
		return self:NewInstance(ColorPicker, Config)
	end
	
	function ContainerClass:AddDivider(Config)
		Config = Config or {}
		local Divider = Prefabs.Divider:Clone()
		Divider.Label.Text = Config.Text or ""
		return self:NewInstance(Divider, Config)
	end
	
	function ContainerClass:AddGroupbox(Config)
		Config = Config or {}
		local Groupbox = Prefabs.Groupbox:Clone()
		local Header = Groupbox.Header
		local Container = Groupbox.Container
		local ToggleButton = Header.ToggleButton
		Config.Open = Config.Open ~= false
		
		Header.Title.Text = Config.Title or "Groupbox"
		
		ToggleButton.Activated:Connect(function()
			Config.Open = not Config.Open
			Container.Visible = Config.Open
			ImGui:HeaderAnimate(Container, Config.Open, Config.Open, Header, ToggleButton)
		end)
		
		local GroupboxClass = ImGui:ContainerClass(Container, Config, Window)
		ImGui:ApplyAnimations(ToggleButton, "Tabs")
		return self:NewInstance(Groupbox, GroupboxClass)
	end
	
	function ContainerClass:AddTabbox(Config)
		Config = Config or {}
		local Tabbox = Prefabs.Tabbox:Clone()
		local TabButtons = Tabbox.TabButtons
		local TabContainer = Tabbox.TabContainer
		Config.Tabs = {}
		
		function Config:AddTab(TabConfig)
			TabConfig = TabConfig or {}
			local TabButton = Instance.new("TextButton")
			TabButton.Size = UDim2.new(0, 100, 1, 0)
			TabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
			TabButton.BorderSizePixel = 0
			TabButton.Text = TabConfig.Name or "Tab"
			TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			TabButton.Font = Enum.Font.Code
			TabButton.TextSize = 14
			TabButton.Parent = TabButtons
			
			local TabContent = Instance.new("Frame")
			TabContent.Size = UDim2.fromScale(1, 1)
			TabContent.BackgroundTransparency = 1
			TabContent.Visible = false
			TabContent.Parent = TabContainer
			
			local TabClass = ImGui:ContainerClass(TabContent, TabConfig, Window)
			
			TabButton.Activated:Connect(function()
				for _, Tab in pairs(Config.Tabs) do
					Tab.Content.Visible = false
					Tab.Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
				end
				TabContent.Visible = true
				TabButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
			end)
			
			table.insert(Config.Tabs, {
				Button = TabButton,
				Content = TabContent,
				Class = TabClass
			})
			
			if #Config.Tabs == 1 then
				TabButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
				TabContent.Visible = true
			end
			
			ImGui:ApplyAnimations(TabButton, "Tabs")
			return TabClass
		end
		
		return self:NewInstance(Tabbox, Config)
	end
	
	function ContainerClass:AddViewport(Config)
		Config = Config or {}
		local Viewport = Prefabs.Viewport:Clone()
		local ViewportFrame = Viewport.ViewportFrame
		Config.Callback = Config.Callback or NullFunction
		
		Viewport.Label.Text = Config.Text or "Viewport"
		return self:NewInstance(Viewport, Config)
	end
	
	function ContainerClass:AddImage(Config)
		Config = Config or {}
		local Image = Prefabs.Image:Clone()
		local ImageLabel = Image.ImageLabel
		ImageLabel.Image = Config.Image or ""
		
		Image.Label.Text = Config.Text or "Image"
		return self:NewInstance(Image, Config)
	end
	
	function ContainerClass:AddVideo(Config)
		Config = Config or {}
		local Video = Prefabs.Video:Clone()
		local VideoFrame = Video.VideoFrame
		VideoFrame.Video = Config.Video or ""
		
		Video.Label.Text = Config.Text or "Video"
		return self:NewInstance(Video, Config)
	end
	
	return ContainerClass
end

function ImGui:ApplyWindowSelectEffect(Window, TitleBar)
	local UIStroke = Window:FindFirstChildOfClass("UIStroke")
	local Colors = {
		Selected = {
			BackgroundTransparency = 0,
			BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		},
		Deselected = {
			BackgroundTransparency = 0.3,
			BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		}
	}
	local function SetSelected(Selected)
		local Animations = ImGui.Animations
		local Type = Selected and "Selected" or "Deselected"
		local TweenInfo = ImGui:GetAnimation(true)
		ImGui:Tween(TitleBar, Colors[Type])
		ImGui:Tween(UIStroke, Animations.WindowBorder[Type])
	end
	self:ConnectHover({
		Parent = Window,
		OnInput = function(MouseHovering, Input)
			if Input.UserInputType.Name:find("Mouse") then
				SetSelected(MouseHovering)
			end
		end
	})
end

function ImGui:SetWindowProps(Properties, IgnoreWindows)
	local Module = { OldProperties = {} }
	for Window in next, ImGui.Windows do
		if table.find(IgnoreWindows, Window) then continue end
		local OldValues = {}
		Module.OldProperties[Window] = OldValues
		for Key, Value in next, Properties do
			OldValues[Key] = Window[Key]
			Window[Key] = Value
		end
	end
	function Module:Revert()
		for Window in next, ImGui.Windows do
			local OldValues = Module.OldProperties[Window]
			if not OldValues then continue end
			for Key, Value in next, OldValues do
				Window[Key] = Value
			end
		end
	end
	return Module
end

function ImGui:CreateWindow(WindowConfig)
	local Window = Prefabs.Window:Clone()
	Window.Parent = ImGui.ScreenGui
	Window.Visible = true
	WindowConfig.Window = Window
	
	local Content = Window.Content
	local Body = Content.Body
	
	local Resize = Window.ResizeGrab
	Resize.Visible = WindowConfig.NoResize ~= true
	
	local MinSize = WindowConfig.MinSize or Vector2.new(160, 90)
	ImGui:ApplyResizable(MinSize, Window, Resize, WindowConfig)
	
	local TitleBar = Content.TitleBar
	TitleBar.Visible = WindowConfig.NoTitleBar ~= true
	
	local Toggle = TitleBar.Left.Toggle
	Toggle.Visible = WindowConfig.NoCollapse ~= true
	ImGui:ApplyAnimations(Toggle.ToggleButton, "Tabs")
	
	local ToolBar = Content.ToolBar
	ToolBar.Visible = WindowConfig.TabsBar ~= false
	
	if not WindowConfig.NoDrag then
		ImGui:ApplyDraggable(Window)
	end
	
	local CloseButton = TitleBar.Close
	CloseButton.Visible = WindowConfig.NoClose ~= true
	
	function WindowConfig:Close()
		local Callback = WindowConfig.CloseCallback
		WindowConfig:SetVisible(false)
		if Callback then
			Callback(WindowConfig)
		end
		return WindowConfig
	end
	CloseButton.Activated:Connect(WindowConfig.Close)
	
	function WindowConfig:GetHeaderSizeY()
		local ToolbarY = ToolBar.Visible and ToolBar.AbsoluteSize.Y or 0
		local TitlebarY = TitleBar.Visible and TitleBar.AbsoluteSize.Y or 0
		return ToolbarY + TitlebarY
	end
	
	function WindowConfig:UpdateBody()
		local HeaderSizeY = self:GetHeaderSizeY()
		Body.Size = UDim2.new(1, 0, 1, -HeaderSizeY)
	end
	WindowConfig:UpdateBody()
	
	WindowConfig.Open = true
	function WindowConfig:SetOpen(Open, NoAnimation)
		local WindowAbSize = Window.AbsoluteSize
		local TitleBarSize = TitleBar.AbsoluteSize
		self.Open = Open
		ImGui:HeaderAnimate(TitleBar, true, Open, TitleBar, Toggle.ToggleButton)
		ImGui:Tween(Resize, {
			TextTransparency = Open and 0.6 or 1,
			Interactable = Open
		}, nil, NoAnimation)
		ImGui:Tween(Window, {
			Size = Open and self.Size or UDim2.fromOffset(WindowAbSize.X, TitleBarSize.Y)
		}, nil, NoAnimation)
		ImGui:Tween(Body, {
			Visible = Open
		}, nil, NoAnimation)
		return self
	end
	
	function WindowConfig:SetVisible(Visible)
		Window.Visible = Visible
		return self
	end
	
	function WindowConfig:SetTitle(Text)
		TitleBar.Left.Title.Text = tostring(Text)
		return self
	end
	
	function WindowConfig:Remove()
		Window:Remove()
		return self
	end
	
	Toggle.ToggleButton.Activated:Connect(function()
		local Open = not WindowConfig.Open
		WindowConfig.Open = Open
		return WindowConfig:SetOpen(Open)
	end)
	
	function WindowConfig:CreateTab(Config)
		local Name = Config.Name or ""
		local TabButton = ToolBar.TabButton:Clone()
		TabButton.Name = Name
		TabButton.Text = Name
		TabButton.Visible = true
		TabButton.Parent = ToolBar
		Config.Button = TabButton
		
		local AutoSizeAxis = WindowConfig.AutoSize or "Y"
		local Content = Body.Template:Clone()
		Content.AutomaticSize = Enum.AutomaticSize[AutoSizeAxis]
		Content.Visible = Config.Visible or false
		Content.Name = Name
		Content.Parent = Body
		Config.Content = Content
		
		if AutoSizeAxis == "Y" then
			Content.Size = UDim2.fromScale(1, 0)
		elseif AutoSizeAxis == "X" then
			Content.Size = UDim2.fromScale(0, 1)
		end
		
		TabButton.Activated:Connect(function()
			WindowConfig:ShowTab(Config)
		end)
		
		function Config:GetContentSize()
			return Content.AbsoluteSize
		end
		
		Config = ImGui:ContainerClass(Content, Config, Window)
		ImGui:ApplyAnimations(TabButton, "Tabs")
		
		self:UpdateBody()
		if WindowConfig.AutoSize then
			Content:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				local Size = Config:GetContentSize()
				self:SetSize(Size)
			end)
		end
		
		return Config
	end
	
	function WindowConfig:SetPosition(Position)
		Window.Position = Position
		return self
	end
	
	function WindowConfig:SetSize(Size)
		local HeaderSizeY = self:GetHeaderSizeY()
		if typeof(Size) == "Vector2" then
			Size = UDim2.fromOffset(Size.X, Size.Y)
		end
		local NewSize = UDim2.new(
			Size.X.Scale,
			Size.X.Offset,
			Size.Y.Scale,
			Size.Y.Offset + HeaderSizeY
		)
		self.Size = NewSize
		Window.Size = NewSize
		return self
	end
	
	function WindowConfig:ShowTab(TabClass)
		local TargetPage = TabClass.Content
		if not TargetPage.Visible and not TabClass.NoAnimation then
			TargetPage.Position = UDim2.fromOffset(0, 5)
		end
		for _, Page in next, Body:GetChildren() do
			Page.Visible = Page == TargetPage
		end
		ImGui:Tween(TargetPage, {
			Position = UDim2.fromOffset(0, 0)
		})
		return self
	end
	
	function WindowConfig:Center()
		local Size = Window.AbsoluteSize
		local Position = UDim2.new(0.5, -Size.X/2, 0.5, -Size.Y/2)
		self:SetPosition(Position)
		return self
	end
	
	WindowConfig:SetTitle(WindowConfig.Title or "Depso UI")
	
	if not WindowConfig.Open then
		WindowConfig:SetOpen(WindowConfig.Open or true, true)
	end
	
	ImGui.Windows[Window] = WindowConfig
	ImGui:CheckStyles(Window, WindowConfig, WindowConfig.Colors)
	
	if not WindowConfig.NoSelectEffect then
		ImGui:ApplyWindowSelectEffect(Window, TitleBar)
	end
	
	return ImGui:MergeMetatables(WindowConfig, Window)
end

function ImGui:CreateModal(Config)
	local ModalEffect = Prefabs.ModalEffect:Clone()
	ModalEffect.BackgroundTransparency = 1
	ModalEffect.Parent = ImGui.FullScreenGui
	ModalEffect.Visible = true
	
	ImGui:Tween(ModalEffect, {
		BackgroundTransparency = 0.6
	})
	
	Config = Config or {}
	Config.TabsBar = Config.TabsBar ~= nil and Config.TabsBar or false
	Config.NoCollapse = true
	Config.NoResize = true
	Config.NoClose = true
	Config.NoSelectEffect = true
	Config.Parent = ModalEffect
	
	Config.AnchorPoint = Vector2.new(0.5, 0.5)
	Config.Position = UDim2.fromScale(0.5, 0.5)
	
	local Window = self:CreateWindow(Config)
	Config = Window:CreateTab({
		Visible = true
	})
	
	local WindowManger = ImGui:SetWindowProps({
		Interactable = false
	}, {Window.Window})
	
	local WindowClose = Window.Close
	function Config:Close()
		local Tween = ImGui:Tween(ModalEffect, {
			BackgroundTransparency = 1
		})
		Tween.Completed:Connect(function()
			ModalEffect:Remove()
		end)
		WindowManger:Revert()
		WindowClose()
	end
	
	return Config
end

ImGui.ThemeManager = {
	Themes = {},
	CurrentTheme = "Default",
	DefaultTheme = {
		Name = "Default",
		BackgroundColor = Color3.fromRGB(15, 15, 15),
		MainColor = Color3.fromRGB(25, 25, 25),
		AccentColor = Color3.fromRGB(125, 85, 255),
		OutlineColor = Color3.fromRGB(40, 40, 40),
		FontColor = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.Code
	}
}

function ImGui.ThemeManager:CreateTheme(ThemeData)
	ThemeData = ThemeData or {}
	local Theme = {
		Name = ThemeData.Name or "Custom Theme",
		BackgroundColor = ThemeData.BackgroundColor or self.DefaultTheme.BackgroundColor,
		MainColor = ThemeData.MainColor or self.DefaultTheme.MainColor,
		AccentColor = ThemeData.AccentColor or self.DefaultTheme.AccentColor,
		OutlineColor = ThemeData.OutlineColor or self.DefaultTheme.OutlineColor,
		FontColor = ThemeData.FontColor or self.DefaultTheme.FontColor,
		Font = ThemeData.Font or self.DefaultTheme.Font
	}
	self.Themes[Theme.Name] = Theme
	return Theme
end

function ImGui.ThemeManager:ApplyTheme(ThemeName)
	local Theme = self.Themes[ThemeName] or self.DefaultTheme
	self.CurrentTheme = Theme.Name
	
	for Window, Config in pairs(ImGui.Windows) do
		Config.Colors = {
			BackgroundColor = Theme.BackgroundColor,
			MainColor = Theme.MainColor,
			AccentColor = Theme.AccentColor,
			OutlineColor = Theme.OutlineColor,
			FontColor = Theme.FontColor
		}
		ImGui:CheckStyles(Window, Config, Config.Colors)
	end
	
	return Theme
end

function ImGui.ThemeManager:GetTheme(ThemeName)
	return self.Themes[ThemeName]
end

function ImGui.ThemeManager:GetCurrentTheme()
	return self.Themes[self.CurrentTheme] or self.DefaultTheme
end

function ImGui.ThemeManager:GetThemeList()
	local ThemeList = {}
	for Name, _ in pairs(self.Themes) do
		table.insert(ThemeList, Name)
	end
	return ThemeList
end

ImGui.ThemeManager:CreateTheme(ImGui.ThemeManager.DefaultTheme)

ImGui.ThemeManager:CreateTheme({
	Name = "Dark",
	BackgroundColor = Color3.fromRGB(10, 10, 10),
	MainColor = Color3.fromRGB(20, 20, 20),
	AccentColor = Color3.fromRGB(100, 100, 255),
	OutlineColor = Color3.fromRGB(30, 30, 30),
	FontColor = Color3.fromRGB(255, 255, 255)
})

ImGui.ThemeManager:CreateTheme({
	Name = "Light",
	BackgroundColor = Color3.fromRGB(240, 240, 240),
	MainColor = Color3.fromRGB(255, 255, 255),
	AccentColor = Color3.fromRGB(100, 150, 255),
	OutlineColor = Color3.fromRGB(200, 200, 200),
	FontColor = Color3.fromRGB(0, 0, 0)
})

ImGui.ThemeManager:CreateTheme({
	Name = "Nord",
	BackgroundColor = Color3.fromRGB(46, 52, 64),
	MainColor = Color3.fromRGB(59, 66, 82),
	AccentColor = Color3.fromRGB(136, 192, 208),
	OutlineColor = Color3.fromRGB(76, 86, 106),
	FontColor = Color3.fromRGB(236, 239, 244)
})

ImGui.ThemeManager:CreateTheme({
	Name = "Dracula",
	BackgroundColor = Color3.fromRGB(40, 42, 54),
	MainColor = Color3.fromRGB(68, 71, 90),
	AccentColor = Color3.fromRGB(189, 147, 249),
	OutlineColor = Color3.fromRGB(98, 114, 164),
	FontColor = Color3.fromRGB(248, 248, 242)
})

ImGui.SaveManager = {
	SaveFolder = "ImGuiSaves",
	SaveFile = "config.json"
}

function ImGui.SaveManager:SetFolder(Folder)
	self.SaveFolder = Folder
	return self
end

function ImGui.SaveManager:SetFile(File)
	self.SaveFile = File
	return self
end

function ImGui.SaveManager:GetPath()
	return self.SaveFolder .. "/" .. self.SaveFile
end

function ImGui.SaveManager:Save(Data)
	if not writefile then
		warn("[ImGui] writefile is not available")
		return false
	end
	
	if not isfolder(self.SaveFolder) then
		makefolder(self.SaveFolder)
	end
	
	local Success, Error = pcall(function()
		local Json = HttpService:JSONEncode(Data)
		writefile(self:GetPath(), Json)
	end)
	
	if not Success then
		warn("[ImGui] Failed to save:", Error)
		return false
	end
	
	return true
end

function ImGui.SaveManager:Load()
	if not readfile then
		warn("[ImGui] readfile is not available")
		return nil
	end
	
	if not isfile(self:GetPath()) then
		return nil
	end
	
	local Success, Result = pcall(function()
		local Json = readfile(self:GetPath())
		return HttpService:JSONDecode(Json)
	end)
	
	if not Success then
		warn("[ImGui] Failed to load:", Result)
		return nil
	end
	
	return Result
end

function ImGui.SaveManager:Delete()
	if not delfile then
		warn("[ImGui] delfile is not available")
		return false
	end
	
	if not isfile(self:GetPath()) then
		return true
	end
	
	local Success, Error = pcall(function()
		delfile(self:GetPath())
	end)
	
	if not Success then
		warn("[ImGui] Failed to delete:", Error)
		return false
	end
	
	return true
end

function ImGui.SaveManager:SaveOptions(Options)
	local Data = {}
	for Name, Option in pairs(Options) do
		if Option.Value ~= nil then
			Data[Name] = Option.Value
		end
	end
	return self:Save(Data)
end

function ImGui.SaveManager:LoadOptions(Options)
	local Data = self:Load()
	if not Data then return false end
	
	for Name, Value in pairs(Data) do
		local Option = Options[Name]
		if Option and Option.SetValue then
			Option:SetValue(Value)
		end
	end
	
	return true
end

local GuiParent = IsStudio and PlayerGui or CoreGui
ImGui.ScreenGui = ImGui:CreateInstance("ScreenGui", GuiParent, {
	DisplayOrder = 9999,
	ResetOnSpawn = false
})
ImGui.FullScreenGui = ImGui:CreateInstance("ScreenGui", GuiParent, {
	DisplayOrder = 99999,
	ResetOnSpawn = false,
	ScreenInsets = Enum.ScreenInsets.None
})

return ImGui
