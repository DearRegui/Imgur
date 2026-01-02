local ImGui = {
	Version = "2.0.0",
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
	Groupboxes = {},
	Tabboxes = {},
	Elements = {},
	Animation = TweenInfo.new(0.1),
	UIAssetId = "rbxassetid://76246418997296",
	IsMobile = false,
	Toggled = false,
	ToggleKeybind = Enum.KeyCode.RightControl,
	Themes = {},
	CurrentTheme = "Dark",
	ShowCustomCursor = true
}

local CloneRef = cloneref or function(_) return _ end
local function GetService(...)
	return CloneRef(game:GetService(...))
end

local TweenService = GetService("TweenService")
local UserInputService = GetService("UserInputService")
local Players = GetService("Players")
local CoreGui = GetService("CoreGui")
local RunService = GetService("RunService")
local TextService = GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local Mouse = LocalPlayer:GetMouse()

local IsStudio = RunService:IsStudio()
ImGui.NoWarnings = not IsStudio

pcall(function()
	ImGui.DevicePlatform = UserInputService:GetPlatform()
end)
ImGui.IsMobile = (ImGui.DevicePlatform == Enum.Platform.Android or ImGui.DevicePlatform == Enum.Platform.IOS) or 
	(UserInputService.TouchEnabled and not UserInputService.MouseEnabled)

ImGui.ThemeManager = {
	Themes = {
		Dark = {
			BackgroundColor = Color3.fromRGB(15, 15, 15),
			MainColor = Color3.fromRGB(25, 25, 25),
			AccentColor = Color3.fromRGB(125, 85, 255),
			OutlineColor = Color3.fromRGB(40, 40, 40),
			FontColor = Color3.new(1, 1, 1),
			Red = Color3.fromRGB(255, 50, 50),
			Green = Color3.fromRGB(50, 255, 50),
			Blue = Color3.fromRGB(50, 50, 255)
		},
		Light = {
			BackgroundColor = Color3.fromRGB(240, 240, 240),
			MainColor = Color3.fromRGB(255, 255, 255),
			AccentColor = Color3.fromRGB(125, 85, 255),
			OutlineColor = Color3.fromRGB(200, 200, 200),
			FontColor = Color3.new(0, 0, 0),
			Red = Color3.fromRGB(255, 50, 50),
			Green = Color3.fromRGB(50, 200, 50),
			Blue = Color3.fromRGB(50, 50, 255)
		},
		Blue = {
			BackgroundColor = Color3.fromRGB(10, 10, 25),
			MainColor = Color3.fromRGB(20, 20, 40),
			AccentColor = Color3.fromRGB(85, 125, 255),
			OutlineColor = Color3.fromRGB(40, 40, 60),
			FontColor = Color3.new(0.9, 0.9, 1),
			Red = Color3.fromRGB(255, 50, 50),
			Green = Color3.fromRGB(50, 255, 50),
			Blue = Color3.fromRGB(100, 150, 255)
		},
		Purple = {
			BackgroundColor = Color3.fromRGB(20, 10, 25),
			MainColor = Color3.fromRGB(35, 25, 45),
			AccentColor = Color3.fromRGB(180, 85, 255),
			OutlineColor = Color3.fromRGB(60, 40, 80),
			FontColor = Color3.new(1, 0.9, 1),
			Red = Color3.fromRGB(255, 50, 50),
			Green = Color3.fromRGB(50, 255, 50),
			Blue = Color3.fromRGB(150, 100, 255)
		},
		Green = {
			BackgroundColor = Color3.fromRGB(10, 20, 10),
			MainColor = Color3.fromRGB(20, 35, 20),
			AccentColor = Color3.fromRGB(85, 255, 125),
			OutlineColor = Color3.fromRGB(40, 60, 40),
			FontColor = Color3.new(0.9, 1, 0.9),
			Red = Color3.fromRGB(255, 50, 50),
			Green = Color3.fromRGB(100, 255, 100),
			Blue = Color3.fromRGB(50, 50, 255)
		}
	},
	ActiveTheme = nil
}

function ImGui.ThemeManager:GetTheme(ThemeName)
	return self.Themes[ThemeName or ImGui.CurrentTheme] or self.Themes.Dark
end

function ImGui.ThemeManager:SetTheme(ThemeName)
	local Theme = self.Themes[ThemeName]
	if not Theme then
		ImGui:Warn("Theme", ThemeName, "not found")
		return
	end
	
	ImGui.CurrentTheme = ThemeName
	self.ActiveTheme = Theme
	
	for Window, WindowConfig in next, ImGui.Windows do
		ImGui:ApplyTheme(Window, WindowConfig)
	end
	
	for _, Groupbox in next, ImGui.Groupboxes do
		ImGui:ApplyThemeToElement(Groupbox.Frame, Theme)
	end
	
	for _, Tabbox in next, ImGui.Tabboxes do
		ImGui:ApplyThemeToElement(Tabbox.Frame, Theme)
	end
	
	return Theme
end

function ImGui.ThemeManager:AddTheme(ThemeName, ThemeData)
	self.Themes[ThemeName] = ThemeData
end

function ImGui:Warn(...)
	if self.NoWarnings then return end
	return warn("[IMGUI]", ...)
end

function ImGui:CreateInstance(Class, Parent, Properties)
	local Instance = Instance.new(Class, Parent)
	for Key, Value in next, Properties or {} do
		Instance[Key] = Value
	end
	return Instance
end

function ImGui:ApplyThemeToElement(Element, Theme)
	Theme = Theme or ImGui.ThemeManager:GetTheme()
	
	if Element:IsA("Frame") or Element:IsA("TextButton") or Element:IsA("TextLabel") or Element:IsA("TextBox") then
		if Element.Name:find("Background") or Element.Name == "Body" then
			Element.BackgroundColor3 = Theme.BackgroundColor
		elseif Element.Name:find("Main") or Element.Name:find("Content") then
			Element.BackgroundColor3 = Theme.MainColor
		end
		
		if Element:IsA("TextLabel") or Element:IsA("TextButton") or Element:IsA("TextBox") then
			Element.TextColor3 = Theme.FontColor
		end
	end
	
	local UIStroke = Element:FindFirstChildOfClass("UIStroke")
	if UIStroke then
		UIStroke.Color = Theme.OutlineColor
	end
	
	for _, Child in next, Element:GetChildren() do
		ImGui:ApplyThemeToElement(Child, Theme)
	end
end

function ImGui:ApplyTheme(Window, WindowConfig)
	local Theme = ImGui.ThemeManager:GetTheme()
	ImGui:ApplyThemeToElement(Window, Theme)
end

function ImGui:Tween(Object, Properties, TweenInfoOverride, NoAnimation)
	if NoAnimation then
		for Key, Value in next, Properties do
			Object[Key] = Value
		end
		return
	end
	
	local TweenInfo = TweenInfoOverride or self.Animation
	local Tween = TweenService:Create(Object, TweenInfo, Properties)
	Tween:Play()
	return Tween
end

function ImGui:GetAnimation(Fast)
	return Fast and TweenInfo.new(0.05) or self.Animation
end

function ImGui:ConnectHover(Config)
	local Parent = Config.Parent
	local OnInput = Config.OnInput or function() end
	local LastState = false
	
	Parent.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement or 
		   Input.UserInputType == Enum.UserInputType.Touch then
			LastState = true
			OnInput(true, Input)
		end
	end)
	
	Parent.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement or 
		   Input.UserInputType == Enum.UserInputType.Touch then
			LastState = false
			OnInput(false, Input)
		end
	end)
	
	return {
		Disconnect = function()
			LastState = false
		end
	}
end

function ImGui:ApplyAnimations(Element, AnimationType)
	local Animations = self.Animations[AnimationType]
	if not Animations then return end
	
	self:ConnectHover({
		Parent = Element,
		OnInput = function(MouseHovering)
			local AnimationData = MouseHovering and Animations.MouseEnter or Animations.MouseLeave
			self:Tween(Element, AnimationData)
		end
	})
end

function ImGui:ApplyDraggable(Window)
	local Dragging = false
	local DragInput, MousePos, FramePos
	
	local function Update(Input)
		local Delta = Input.Position - MousePos
		self:Tween(Window, {
			Position = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
		}, TweenInfo.new(0.05))
	end
	
	Window.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			MousePos = Input.Position
			FramePos = Window.Position
			
			Input.Changed:Connect(function()
				if Input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)
	
	Window.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
			DragInput = Input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(Input)
		if Input == DragInput and Dragging then
			Update(Input)
		end
	end)
end

function ImGui:ApplyResizable(MinSize, Window, ResizeGrab, WindowConfig)
	local Resizing = false
	local ResizeInput, MousePos, StartSize
	
	local function Update(Input)
		local Delta = Input.Position - MousePos
		local NewSize = Vector2.new(
			math.max(MinSize.X, StartSize.X + Delta.X),
			math.max(MinSize.Y, StartSize.Y + Delta.Y)
		)
		WindowConfig:SetSize(NewSize)
	end
	
	ResizeGrab.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Resizing = true
			MousePos = Input.Position
			StartSize = Window.AbsoluteSize
			
			Input.Changed:Connect(function()
				if Input.UserInputState == Enum.UserInputState.End then
					Resizing = false
				end
			end)
		end
	end)
	
	ResizeGrab.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
			ResizeInput = Input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(Input)
		if Input == ResizeInput and Resizing then
			Update(Input)
		end
	end)
end

function ImGui:ContainerClass(Frame, Class, Window)
	local ContainerClass = Class or {}
	local WindowConfig = ImGui.Windows[Window]
	
	function ContainerClass:NewInstance(Instance, Class, Parent)
		Class = Class or {}
		Instance.Parent = Parent or Frame
		Instance.Visible = true
		
		if WindowConfig and WindowConfig.NoGradientAll then
			Class.NoGradient = true
		end
		
		local Theme = ImGui.ThemeManager:GetTheme()
		ImGui:ApplyThemeToElement(Instance, Theme)
		
		if Class.NewInstanceCallback then
			Class.NewInstanceCallback(Instance)
		end
		
		return ImGui:MergeMetatables(Class, Instance)
	end
	
	function ContainerClass:Button(Config)
		Config = Config or {}
		local Button = ImGui:CreateInstance("TextButton", Frame, {
			Size = Config.Size or UDim2.new(1, -10, 0, 30),
			Position = Config.Position or UDim2.new(0, 5, 0, 5),
			BackgroundColor3 = ImGui.ThemeManager:GetTheme().MainColor,
			Text = Config.Text or "Button",
			TextColor3 = ImGui.ThemeManager:GetTheme().FontColor,
			Font = Enum.Font.Code,
			TextSize = 14,
			AutoButtonColor = false
		})
		
		ImGui:CreateInstance("UICorner", Button, { CornerRadius = UDim.new(0, 4) })
		ImGui:CreateInstance("UIStroke", Button, {
			Color = ImGui.ThemeManager:GetTheme().OutlineColor,
			Thickness = 1
		})
		
		ImGui:ApplyAnimations(Button, "Buttons")
		
		Button.MouseButton1Click:Connect(function()
			if Config.Callback then
				Config.Callback()
			end
		end)
		
		Config.Button = Button
		Config.SetText = function(self, Text)
			Button.Text = Text
			return self
		end
		
		return ImGui:MergeMetatables(Config, Button)
	end
	
	function ContainerClass:Toggle(Config)
		Config = Config or {}
		local Theme = ImGui.ThemeManager:GetTheme()
		
		local Container = ImGui:CreateInstance("Frame", Frame, {
			Size = Config.Size or UDim2.new(1, -10, 0, 30),
			Position = Config.Position or UDim2.new(0, 5, 0, 5),
			BackgroundTransparency = 1
		})
		
		local Label = ImGui:CreateInstance("TextLabel", Container, {
			Size = UDim2.new(1, -40, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			Text = Config.Text or "Toggle",
			TextColor3 = Theme.FontColor,
			Font = Enum.Font.Code,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left
		})
		
		local ToggleButton = ImGui:CreateInstance("TextButton", Container, {
			Size = UDim2.new(0, 30, 0, 20),
			Position = UDim2.new(1, -35, 0, 5),
			BackgroundColor3 = Theme.MainColor,
			Text = "",
			AutoButtonColor = false
		})
		
		ImGui:CreateInstance("UICorner", ToggleButton, { CornerRadius = UDim.new(0, 4) })
		ImGui:CreateInstance("UIStroke", ToggleButton, {
			Color = Theme.OutlineColor,
			Thickness = 1
		})
		
		local Indicator = ImGui:CreateInstance("Frame", ToggleButton, {
			Size = UDim2.new(0, 12, 0, 12),
			Position = UDim2.new(0, 4, 0, 4),
			BackgroundColor3 = Theme.OutlineColor
		})
		
		ImGui:CreateInstance("UICorner", Indicator, { CornerRadius = UDim.new(0, 2) })
		
		Config.Value = Config.Default or false
		
		local function UpdateToggle()
			ImGui:Tween(Indicator, {
				BackgroundColor3 = Config.Value and Theme.AccentColor or Theme.OutlineColor,
				Position = Config.Value and UDim2.new(0, 14, 0, 4) or UDim2.new(0, 4, 0, 4)
			})
			
			if Config.Callback then
				Config.Callback(Config.Value)
			end
		end
		
		UpdateToggle()
		
		ToggleButton.MouseButton1Click:Connect(function()
			Config.Value = not Config.Value
			UpdateToggle()
		end)
		
		Config.Container = Container
		Config.SetValue = function(self, Value)
			Config.Value = Value
			UpdateToggle()
			return self
		end
		
		Config.GetValue = function(self)
			return Config.Value
		end
		
		return ImGui:MergeMetatables(Config, Container)
	end
	
	function ContainerClass:Slider(Config)
		Config = Config or {}
		local Theme = ImGui.ThemeManager:GetTheme()
		
		local Container = ImGui:CreateInstance("Frame", Frame, {
			Size = Config.Size or UDim2.new(1, -10, 0, 50),
			Position = Config.Position or UDim2.new(0, 5, 0, 5),
			BackgroundTransparency = 1
		})
		
		local Label = ImGui:CreateInstance("TextLabel", Container, {
			Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			Text = Config.Text or "Slider",
			TextColor3 = Theme.FontColor,
			Font = Enum.Font.Code,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left
		})
		
		local SliderBackground = ImGui:CreateInstance("Frame", Container, {
			Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.new(0, 0, 0, 25),
			BackgroundColor3 = Theme.MainColor
		})
		
		ImGui:CreateInstance("UICorner", SliderBackground, { CornerRadius = UDim.new(0, 4) })
		ImGui:CreateInstance("UIStroke", SliderBackground, {
			Color = Theme.OutlineColor,
			Thickness = 1
		})
		
		local SliderFill = ImGui:CreateInstance("Frame", SliderBackground, {
			Size = UDim2.new(0, 0, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundColor3 = Theme.AccentColor,
			BorderSizePixel = 0
		})
		
		ImGui:CreateInstance("UICorner", SliderFill, { CornerRadius = UDim.new(0, 4) })
		
		local ValueLabel = ImGui:CreateInstance("TextLabel", SliderBackground, {
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			Text = "0",
			TextColor3 = Theme.FontColor,
			Font = Enum.Font.Code,
			TextSize = 12
		})
		
		Config.Min = Config.Min or 0
		Config.Max = Config.Max or 100
		Config.Value = Config.Default or Config.Min
		Config.Increment = Config.Increment or 1
		
		local Dragging = false
		
		local function UpdateSlider(Input)
			local MouseX = Input.Position.X
			local RelativeX = math.clamp(MouseX - SliderBackground.AbsolutePosition.X, 0, SliderBackground.AbsoluteSize.X)
			local Percentage = RelativeX / SliderBackground.AbsoluteSize.X
			
			local RawValue = Config.Min + (Config.Max - Config.Min) * Percentage
			Config.Value = math.floor(RawValue / Config.Increment + 0.5) * Config.Increment
			Config.Value = math.clamp(Config.Value, Config.Min, Config.Max)
			
			ImGui:Tween(SliderFill, {
				Size = UDim2.new(Percentage, 0, 1, 0)
			}, TweenInfo.new(0.05))
			
			ValueLabel.Text = tostring(Config.Value)
			
			if Config.Callback then
				Config.Callback(Config.Value)
			end
		end
		
		SliderBackground.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				Dragging = true
				UpdateSlider(Input)
			end
		end)
		
		SliderBackground.InputEnded:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				Dragging = false
			end
		end)
		
		UserInputService.InputChanged:Connect(function(Input)
			if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
				UpdateSlider(Input)
			end
		end)
		
		local Percentage = (Config.Value - Config.Min) / (Config.Max - Config.Min)
		SliderFill.Size = UDim2.new(Percentage, 0, 1, 0)
		ValueLabel.Text = tostring(Config.Value)
		
		Config.Container = Container
		Config.SetValue = function(self, Value)
			Config.Value = math.clamp(Value, Config.Min, Config.Max)
			local Percentage = (Config.Value - Config.Min) / (Config.Max - Config.Min)
			ImGui:Tween(SliderFill, {
				Size = UDim2.new(Percentage, 0, 1, 0)
			})
			ValueLabel.Text = tostring(Config.Value)
			return self
		end
		
		Config.GetValue = function(self)
			return Config.Value
		end
		
		return ImGui:MergeMetatables(Config, Container)
	end
	
	function ContainerClass:Input(Config)
		Config = Config or {}
		local Theme = ImGui.ThemeManager:GetTheme()
		
		local Container = ImGui:CreateInstance("Frame", Frame, {
			Size = Config.Size or UDim2.new(1, -10, 0, 50),
			Position = Config.Position or UDim2.new(0, 5, 0, 5),
			BackgroundTransparency = 1
		})
		
		local Label = ImGui:CreateInstance("TextLabel", Container, {
			Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			Text = Config.Text or "Input",
			TextColor3 = Theme.FontColor,
			Font = Enum.Font.Code,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left
		})
		
		local InputBox = ImGui:CreateInstance("TextBox", Container, {
			Size = UDim2.new(1, 0, 0, 25),
			Position = UDim2.new(0, 0, 0, 25),
			BackgroundColor3 = Theme.MainColor,
			Text = Config.Default or "",
			TextColor3 = Theme.FontColor,
			PlaceholderText = Config.Placeholder or "Enter text...",
			PlaceholderColor3 = Color3.fromHSV(Theme.FontColor:ToHSV(), 0.5, 0.5),
			Font = Enum.Font.Code,
			TextSize = 14,
			ClearTextOnFocus = false
		})
		
		ImGui:CreateInstance("UICorner", InputBox, { CornerRadius = UDim.new(0, 4) })
		ImGui:CreateInstance("UIStroke", InputBox, {
			Color = Theme.OutlineColor,
			Thickness = 1
		})
		ImGui:CreateInstance("UIPadding", InputBox, {
			PaddingLeft = UDim.new(0, 5),
			PaddingRight = UDim.new(0, 5)
		})
		
		ImGui:ApplyAnimations(InputBox, "Inputs")
		
		Config.Value = InputBox.Text
		
		InputBox.FocusLost:Connect(function(EnterPressed)
			Config.Value = InputBox.Text
			if Config.Callback then
				Config.Callback(InputBox.Text, EnterPressed)
			end
		end)
		
		Config.Container = Container
		Config.SetValue = function(self, Value)
			InputBox.Text = tostring(Value)
			Config.Value = InputBox.Text
			return self
		end
		
		Config.GetValue = function(self)
			return InputBox.Text
		end
		
		return ImGui:MergeMetatables(Config, Container)
	end
	
	function ContainerClass:Dropdown(Config)
		Config = Config or {}
		local Theme = ImGui.ThemeManager:GetTheme()
		
		local Container = ImGui:CreateInstance("Frame", Frame, {
			Size = Config.Size or UDim2.new(1, -10, 0, 50),
			Position = Config.Position or UDim2.new(0, 5, 0, 5),
			BackgroundTransparency = 1,
			ZIndex = 2
		})
		
		local Label = ImGui:CreateInstance("TextLabel", Container, {
			Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			Text = Config.Text or "Dropdown",
			TextColor3 = Theme.FontColor,
			Font = Enum.Font.Code,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 2
		})
		
		local DropdownButton = ImGui:CreateInstance("TextButton", Container, {
			Size = UDim2.new(1, 0, 0, 25),
			Position = UDim2.new(0, 0, 0, 25),
			BackgroundColor3 = Theme.MainColor,
			Text = Config.Default or "Select...",
			TextColor3 = Theme.FontColor,
			Font = Enum.Font.Code,
			TextSize = 14,
			AutoButtonColor = false,
			ZIndex = 2
		})
		
		ImGui:CreateInstance("UICorner", DropdownButton, { CornerRadius = UDim.new(0, 4) })
		ImGui:CreateInstance("UIStroke", DropdownButton, {
			Color = Theme.OutlineColor,
			Thickness = 1
		})
		
		local Arrow = ImGui:CreateInstance("TextLabel", DropdownButton, {
			Size = UDim2.new(0, 20, 1, 0),
			Position = UDim2.new(1, -25, 0, 0),
			BackgroundTransparency = 1,
			Text = "▼",
			TextColor3 = Theme.FontColor,
			Font = Enum.Font.Code,
			TextSize = 12,
			ZIndex = 2
		})
		
		local DropdownList = ImGui:CreateInstance("ScrollingFrame", Container, {
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(0, 0, 0, 50),
			BackgroundColor3 = Theme.MainColor,
			BorderSizePixel = 0,
			Visible = false,
			ScrollBarThickness = 4,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ZIndex = 3
		})
		
		ImGui:CreateInstance("UICorner", DropdownList, { CornerRadius = UDim.new(0, 4) })
		ImGui:CreateInstance("UIStroke", DropdownList, {
			Color = Theme.OutlineColor,
			Thickness = 1
		})
		ImGui:CreateInstance("UIListLayout", DropdownList, {
			Padding = UDim.new(0, 2)
		})
		
		Config.Value = Config.Default
		Config.Options = Config.Options or {}
		Config.Open = false
		
		local function CloseDropdown()
			Config.Open = false
			ImGui:Tween(DropdownList, {
				Size = UDim2.new(1, 0, 0, 0),
				Visible = false
			})
			ImGui:Tween(Arrow, { Rotation = 0 })
		end
		
		local function OpenDropdown()
			Config.Open = true
			local MaxHeight = math.min(#Config.Options * 27, 150)
			ImGui:Tween(DropdownList, {
				Size = UDim2.new(1, 0, 0, MaxHeight),
				Visible = true
			})
			ImGui:Tween(Arrow, { Rotation = 180 })
		end
		
		DropdownButton.MouseButton1Click:Connect(function()
			if Config.Open then
				CloseDropdown()
			else
				OpenDropdown()
			end
		end)
		
		function Config:SetOptions(Options)
			Config.Options = Options
			DropdownList:ClearAllChildren()
			ImGui:CreateInstance("UIListLayout", DropdownList, {
				Padding = UDim.new(0, 2)
			})
			
			local CanvasHeight = 0
			for _, Option in ipairs(Options) do
				local OptionButton = ImGui:CreateInstance("TextButton", DropdownList, {
					Size = UDim2.new(1, -5, 0, 25),
					BackgroundColor3 = Theme.MainColor,
					Text = tostring(Option),
					TextColor3 = Theme.FontColor,
					Font = Enum.Font.Code,
					TextSize = 14,
					AutoButtonColor = false,
					ZIndex = 3
				})
				
				ImGui:CreateInstance("UICorner", OptionButton, { CornerRadius = UDim.new(0, 4) })
				ImGui:ApplyAnimations(OptionButton, "Buttons")
				
				OptionButton.MouseButton1Click:Connect(function()
					Config.Value = Option
					DropdownButton.Text = tostring(Option)
					CloseDropdown()
					if Config.Callback then
						Config.Callback(Option)
					end
				end)
				
				CanvasHeight = CanvasHeight + 27
			end
			
			DropdownList.CanvasSize = UDim2.new(0, 0, 0, CanvasHeight)
			return self
		end
		
		Config:SetOptions(Config.Options)
		
		Config.Container = Container
		Config.GetValue = function(self)
			return Config.Value
		end
		
		Config.SetValue = function(self, Value)
			Config.Value = Value
			DropdownButton.Text = tostring(Value)
			return self
		end
		
		return ImGui:MergeMetatables(Config, Container)
	end
	
	function ContainerClass:ColorPicker(Config)
		Config = Config or {}
		local Theme = ImGui.ThemeManager:GetTheme()
		
		local Container = ImGui:CreateInstance("Frame", Frame, {
			Size = Config.Size or UDim2.new(1, -10, 0, 30),
			Position = Config.Position or UDim2.new(0, 5, 0, 5),
			BackgroundTransparency = 1
		})
		
		local Label = ImGui:CreateInstance("TextLabel", Container, {
			Size = UDim2.new(1, -40, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			Text = Config.Text or "Color Picker",
			TextColor3 = Theme.FontColor,
			Font = Enum.Font.Code,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left
		})
		
		Config.Value = Config.Default or Color3.new(1, 1, 1)
		
		local ColorButton = ImGui:CreateInstance("TextButton", Container, {
			Size = UDim2.new(0, 30, 0, 25),
			Position = UDim2.new(1, -35, 0, 2),
			BackgroundColor3 = Config.Value,
			Text = "",
			AutoButtonColor = false
		})
		
		ImGui:CreateInstance("UICorner", ColorButton, { CornerRadius = UDim.new(0, 4) })
		ImGui:CreateInstance("UIStroke", ColorButton, {
			Color = Theme.OutlineColor,
			Thickness = 1
		})
		
		ColorButton.MouseButton1Click:Connect(function()
			if Config.Callback then
				Config.Callback(Config.Value)
			end
		end)
		
		Config.Container = Container
		Config.SetValue = function(self, Value)
			Config.Value = Value
			ColorButton.BackgroundColor3 = Value
			return self
		end
		
		Config.GetValue = function(self)
			return Config.Value
		end
		
		return ImGui:MergeMetatables(Config, Container)
	end
	
	function ContainerClass:Label(Config)
		Config = Config or {}
		local Theme = ImGui.ThemeManager:GetTheme()
		
		local Label = ImGui:CreateInstance("TextLabel", Frame, {
			Size = Config.Size or UDim2.new(1, -10, 0, 20),
			Position = Config.Position or UDim2.new(0, 5, 0, 5),
			BackgroundTransparency = 1,
			Text = Config.Text or "Label",
			TextColor3 = Theme.FontColor,
			Font = Enum.Font.Code,
			TextSize = 14,
			TextXAlignment = Config.TextXAlignment or Enum.TextXAlignment.Left,
			TextWrapped = true
		})
		
		Config.Label = Label
		Config.SetText = function(self, Text)
			Label.Text = Text
			return self
		end
		
		return ImGui:MergeMetatables(Config, Label)
	end
	
	function ContainerClass:Divider(Config)
		Config = Config or {}
		local Theme = ImGui.ThemeManager:GetTheme()
		
		local Divider = ImGui:CreateInstance("Frame", Frame, {
			Size = Config.Size or UDim2.new(1, -10, 0, 1),
			Position = Config.Position or UDim2.new(0, 5, 0, 5),
			BackgroundColor3 = Theme.OutlineColor,
			BorderSizePixel = 0
		})
		
		Config.Divider = Divider
		return ImGui:MergeMetatables(Config, Divider)
	end
	
	function ContainerClass:Groupbox(Config)
		Config = Config or {}
		local Theme = ImGui.ThemeManager:GetTheme()
		
		local GroupboxFrame = ImGui:CreateInstance("Frame", Frame, {
			Size = Config.Size or UDim2.new(0.48, 0, 1, 0),
			Position = Config.Position or UDim2.new(0, 5, 0, 5),
			BackgroundColor3 = Theme.MainColor,
			BorderSizePixel = 0
		})
		
		ImGui:CreateInstance("UICorner", GroupboxFrame, { CornerRadius = UDim.new(0, 6) })
		ImGui:CreateInstance("UIStroke", GroupboxFrame, {
			Color = Theme.OutlineColor,
			Thickness = 1
		})
		
		local Header = ImGui:CreateInstance("Frame", GroupboxFrame, {
			Size = UDim2.new(1, 0, 0, 30),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundColor3 = Theme.BackgroundColor,
			BorderSizePixel = 0
		})
		
		ImGui:CreateInstance("UICorner", Header, { CornerRadius = UDim.new(0, 6) })
		
		local Title = ImGui:CreateInstance("TextLabel", Header, {
			Size = UDim2.new(1, -10, 1, 0),
			Position = UDim2.new(0, 10, 0, 0),
			BackgroundTransparency = 1,
			Text = Config.Title or "Groupbox",
			TextColor3 = Theme.FontColor,
			Font = Enum.Font.CodeBold,
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Left
		})
		
		local ContentFrame = ImGui:CreateInstance("ScrollingFrame", GroupboxFrame, {
			Size = UDim2.new(1, -10, 1, -40),
			Position = UDim2.new(0, 5, 0, 35),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 4,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y
		})
		
		ImGui:CreateInstance("UIListLayout", ContentFrame, {
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder
		})
		
		Config.Frame = GroupboxFrame
		Config.Content = ContentFrame
		Config.Header = Header
		Config.Title = Title
		
		local GroupboxClass = ImGui:ContainerClass(ContentFrame, {}, Window)
		
		for Key, Value in next, GroupboxClass do
			Config[Key] = Value
		end
		
		table.insert(ImGui.Groupboxes, Config)
		
		return ImGui:MergeMetatables(Config, GroupboxFrame)
	end
	
	function ContainerClass:Tabbox(Config)
		Config = Config or {}
		local Theme = ImGui.ThemeManager:GetTheme()
		
		local TabboxFrame = ImGui:CreateInstance("Frame", Frame, {
			Size = Config.Size or UDim2.new(0.48, 0, 1, 0),
			Position = Config.Position or UDim2.new(0.51, 0, 0, 5),
			BackgroundColor3 = Theme.MainColor,
			BorderSizePixel = 0
		})
		
		ImGui:CreateInstance("UICorner", TabboxFrame, { CornerRadius = UDim.new(0, 6) })
		ImGui:CreateInstance("UIStroke", TabboxFrame, {
			Color = Theme.OutlineColor,
			Thickness = 1
		})
		
		local TabBar = ImGui:CreateInstance("Frame", TabboxFrame, {
			Size = UDim2.new(1, 0, 0, 30),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundColor3 = Theme.BackgroundColor,
			BorderSizePixel = 0
		})
		
		ImGui:CreateInstance("UICorner", TabBar, { CornerRadius = UDim.new(0, 6) })
		ImGui:CreateInstance("UIListLayout", TabBar, {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder
		})
		
		local ContentHolder = ImGui:CreateInstance("Frame", TabboxFrame, {
			Size = UDim2.new(1, 0, 1, -30),
			Position = UDim2.new(0, 0, 0, 30),
			BackgroundTransparency = 1,
			BorderSizePixel = 0
		})
		
		Config.Frame = TabboxFrame
		Config.TabBar = TabBar
		Config.ContentHolder = ContentHolder
		Config.Tabs = {}
		Config.ActiveTab = nil
		
		function Config:AddTab(TabConfig)
			TabConfig = TabConfig or {}
			
			local TabButton = ImGui:CreateInstance("TextButton", TabBar, {
				Size = UDim2.new(0, 100, 1, 0),
				BackgroundColor3 = Theme.MainColor,
				Text = TabConfig.Title or "Tab",
				TextColor3 = Theme.FontColor,
				Font = Enum.Font.Code,
				TextSize = 14,
				AutoButtonColor = false
			})
			
			ImGui:CreateInstance("UICorner", TabButton, { CornerRadius = UDim.new(0, 4) })
			ImGui:ApplyAnimations(TabButton, "Tabs")
			
			local TabContent = ImGui:CreateInstance("ScrollingFrame", ContentHolder, {
				Size = UDim2.new(1, -10, 1, -10),
				Position = UDim2.new(0, 5, 0, 5),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ScrollBarThickness = 4,
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				Visible = false
			})
			
			ImGui:CreateInstance("UIListLayout", TabContent, {
				Padding = UDim.new(0, 5),
				SortOrder = Enum.SortOrder.LayoutOrder
			})
			
			TabConfig.Button = TabButton
			TabConfig.Content = TabContent
			TabConfig.Parent = Config
			
			local TabClass = ImGui:ContainerClass(TabContent, {}, Window)
			
			for Key, Value in next, TabClass do
				TabConfig[Key] = Value
			end
			
			TabButton.MouseButton1Click:Connect(function()
				Config:SelectTab(TabConfig)
			end)
			
			table.insert(Config.Tabs, TabConfig)
			
			if not Config.ActiveTab then
				Config:SelectTab(TabConfig)
			end
			
			return ImGui:MergeMetatables(TabConfig, TabContent)
		end
		
		function Config:SelectTab(TabConfig)
			for _, Tab in ipairs(Config.Tabs) do
				Tab.Content.Visible = false
				ImGui:Tween(Tab.Button, {
					BackgroundColor3 = Theme.MainColor,
					BackgroundTransparency = 0
				})
			end
			
			TabConfig.Content.Visible = true
			ImGui:Tween(TabConfig.Button, {
				BackgroundColor3 = Theme.AccentColor,
				BackgroundTransparency = 0
			})
			
			Config.ActiveTab = TabConfig
		end
		
		table.insert(ImGui.Tabboxes, Config)
		
		return ImGui:MergeMetatables(Config, TabboxFrame)
	end
	
	return ContainerClass
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

function ImGui:CreateWindow(WindowConfig)
	WindowConfig = WindowConfig or {}
	
	local Theme = ImGui.ThemeManager:GetTheme()
	
	local Window = ImGui:CreateInstance("Frame", ImGui.ScreenGui, {
		Size = WindowConfig.Size or UDim2.new(0, 500, 0, 400),
		Position = WindowConfig.Position or UDim2.new(0.5, -250, 0.5, -200),
		BackgroundColor3 = Theme.BackgroundColor,
		BorderSizePixel = 0,
		Active = true
	})
	
	ImGui:CreateInstance("UICorner", Window, { CornerRadius = UDim.new(0, 8) })
	local UIStroke = ImGui:CreateInstance("UIStroke", Window, {
		Color = Theme.OutlineColor,
		Thickness = 1
	})
	
	local Content = ImGui:CreateInstance("Frame", Window, {
		Name = "Content",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1
	})
	
	local TitleBar = ImGui:CreateInstance("Frame", Content, {
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = Theme.MainColor,
		BorderSizePixel = 0
	})
	
	ImGui:CreateInstance("UICorner", TitleBar, { CornerRadius = UDim.new(0, 8) })
	
	local TitleLabel = ImGui:CreateInstance("TextLabel", TitleBar, {
		Name = "Title",
		Size = UDim2.new(1, -100, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Text = WindowConfig.Title or "ImGui Window",
		TextColor3 = Theme.FontColor,
		Font = Enum.Font.CodeBold,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	local CloseButton = ImGui:CreateInstance("TextButton", TitleBar, {
		Name = "Close",
		Size = UDim2.new(0, 25, 0, 25),
		Position = UDim2.new(1, -30, 0, 2),
		BackgroundColor3 = Theme.Red,
		Text = "×",
		TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.CodeBold,
		TextSize = 18,
		AutoButtonColor = false
	})
	
	ImGui:CreateInstance("UICorner", CloseButton, { CornerRadius = UDim.new(0, 4) })
	ImGui:ApplyAnimations(CloseButton, "Buttons")
	
	local MinimizeButton = ImGui:CreateInstance("TextButton", TitleBar, {
		Name = "Minimize",
		Size = UDim2.new(0, 25, 0, 25),
		Position = UDim2.new(1, -60, 0, 2),
		BackgroundColor3 = Theme.AccentColor,
		Text = "−",
		TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.CodeBold,
		TextSize = 18,
		AutoButtonColor = false
	})
	
	ImGui:CreateInstance("UICorner", MinimizeButton, { CornerRadius = UDim.new(0, 4) })
	ImGui:ApplyAnimations(MinimizeButton, "Buttons")
	
	local ToolBar = ImGui:CreateInstance("Frame", Content, {
		Name = "ToolBar",
		Size = UDim2.new(1, 0, 0, 35),
		Position = UDim2.new(0, 0, 0, 30),
		BackgroundColor3 = Theme.BackgroundColor,
		BorderSizePixel = 0
	})
	
	ImGui:CreateInstance("UIListLayout", ToolBar, {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	ImGui:CreateInstance("UIPadding", ToolBar, {
		PaddingLeft = UDim.new(0, 5),
		PaddingTop = UDim.new(0, 5)
	})
	
	local Body = ImGui:CreateInstance("Frame", Content, {
		Name = "Body",
		Size = UDim2.new(1, 0, 1, -75),
		Position = UDim2.new(0, 0, 0, 65),
		BackgroundTransparency = 1
	})
	
	local ResizeGrab = ImGui:CreateInstance("TextLabel", Window, {
		Name = "ResizeGrab",
		Size = UDim2.new(0, 20, 0, 20),
		Position = UDim2.new(1, -20, 1, -20),
		BackgroundTransparency = 1,
		Text = "⋰",
		TextColor3 = Theme.FontColor,
		TextTransparency = 0.6,
		Font = Enum.Font.Code,
		TextSize = 14
	})
	
	WindowConfig.Window = Window
	WindowConfig.Content = Content
	WindowConfig.TitleBar = TitleBar
	WindowConfig.ToolBar = ToolBar
	WindowConfig.Body = Body
	WindowConfig.ResizeGrab = ResizeGrab
	WindowConfig.Size = Window.Size
	WindowConfig.Open = true
	
	if not WindowConfig.NoDrag then
		ImGui:ApplyDraggable(Window)
	end
	
	if not WindowConfig.NoResize then
		ImGui:ApplyResizable(
			WindowConfig.MinSize or Vector2.new(300, 200),
			Window,
			ResizeGrab,
			WindowConfig
		)
	else
		ResizeGrab.Visible = false
	end
	
	function WindowConfig:Close()
		Window.Visible = false
		if WindowConfig.CloseCallback then
			WindowConfig.CloseCallback(WindowConfig)
		end
		return WindowConfig
	end
	
	CloseButton.MouseButton1Click:Connect(WindowConfig.Close)
	
	local Minimized = false
	MinimizeButton.MouseButton1Click:Connect(function()
		Minimized = not Minimized
		ImGui:Tween(Window, {
			Size = Minimized and UDim2.new(Window.Size.X.Scale, Window.Size.X.Offset, 0, 30) or WindowConfig.Size
		})
		Body.Visible = not Minimized
		ToolBar.Visible = not Minimized
		ResizeGrab.Visible = not Minimized
	end)
	
	function WindowConfig:SetTitle(Text)
		TitleLabel.Text = tostring(Text)
		return self
	end
	
	function WindowConfig:SetSize(Size)
		if typeof(Size) == "Vector2" then
			Size = UDim2.fromOffset(Size.X, Size.Y)
		end
		WindowConfig.Size = Size
		Window.Size = Size
		return self
	end
	
	function WindowConfig:SetPosition(Position)
		Window.Position = Position
		return self
	end
	
	function WindowConfig:SetVisible(Visible)
		Window.Visible = Visible
		return self
	end
	
	function WindowConfig:Center()
		local Size = Window.AbsoluteSize
		local Position = UDim2.new(0.5, -Size.X/2, 0.5, -Size.Y/2)
		self:SetPosition(Position)
		return self
	end
	
	function WindowConfig:CreateTab(Config)
		Config = Config or {}
		
		local TabButton = ImGui:CreateInstance("TextButton", ToolBar, {
			Name = Config.Name or "Tab",
			Size = UDim2.new(0, 100, 1, -5),
			BackgroundColor3 = Theme.MainColor,
			Text = Config.Name or "Tab",
			TextColor3 = Theme.FontColor,
			Font = Enum.Font.Code,
			TextSize = 14,
			AutoButtonColor = false
		})
		
		ImGui:CreateInstance("UICorner", TabButton, { CornerRadius = UDim.new(0, 4) })
		ImGui:ApplyAnimations(TabButton, "Tabs")
		
		local TabContent = ImGui:CreateInstance("ScrollingFrame", Body, {
			Name = Config.Name or "Tab",
			Size = UDim2.new(1, -10, 1, -10),
			Position = UDim2.new(0, 5, 0, 5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 4,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = Config.Visible or false
		})
		
		ImGui:CreateInstance("UIListLayout", TabContent, {
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder
		})
		
		Config.Button = TabButton
		Config.Content = TabContent
		Config.Window = WindowConfig
		
		TabButton.MouseButton1Click:Connect(function()
			WindowConfig:ShowTab(Config)
		end)
		
		local TabClass = ImGui:ContainerClass(TabContent, Config, Window)
		
		return ImGui:MergeMetatables(Config, TabContent)
	end
	
	function WindowConfig:ShowTab(TabConfig)
		for _, Child in next, Body:GetChildren() do
			if Child:IsA("ScrollingFrame") then
				Child.Visible = false
			end
		end
		
		for _, Child in next, ToolBar:GetChildren() do
			if Child:IsA("TextButton") then
				ImGui:Tween(Child, {
					BackgroundColor3 = Theme.MainColor,
					BackgroundTransparency = 0
				})
			end
		end
		
		TabConfig.Content.Visible = true
		ImGui:Tween(TabConfig.Button, {
			BackgroundColor3 = Theme.AccentColor,
			BackgroundTransparency = 0
		})
		
		return self
	end
	
	ImGui.Windows[Window] = WindowConfig
	ImGui:ApplyTheme(Window, WindowConfig)
	
	return ImGui:MergeMetatables(WindowConfig, Window)
end

function ImGui:Toggle(Value)
	if typeof(Value) == "boolean" then
		ImGui.Toggled = Value
	else
		ImGui.Toggled = not ImGui.Toggled
	end
	
	if ImGui.ScreenGui then
		ImGui.ScreenGui.Enabled = ImGui.Toggled
	end
	
	if ImGui.MobileToggleButton then
		ImGui.MobileToggleButton.Visible = not ImGui.Toggled
	end
end

function ImGui:AddMobileToggleButton()
	if not ImGui.IsMobile then return end
	
	local Theme = ImGui.ThemeManager:GetTheme()
	
	local ToggleButton = ImGui:CreateInstance("TextButton", ImGui.MobileGui, {
		Size = UDim2.new(0, 60, 0, 60),
		Position = UDim2.new(0, 10, 0, 10),
		BackgroundColor3 = Theme.AccentColor,
		Text = "☰",
		TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.CodeBold,
		TextSize = 24,
		AutoButtonColor = false,
		ZIndex = 10
	})
	
	ImGui:CreateInstance("UICorner", ToggleButton, { CornerRadius = UDim.new(0, 8) })
	ImGui:CreateInstance("UIStroke", ToggleButton, {
		Color = Theme.OutlineColor,
		Thickness = 2
	})
	
	ImGui:ApplyDraggable(ToggleButton)
	
	ToggleButton.MouseButton1Click:Connect(function()
		ImGui:Toggle()
	end)
	
	ImGui.MobileToggleButton = ToggleButton
end

local GuiParent = IsStudio and PlayerGui or CoreGui
ImGui.ScreenGui = ImGui:CreateInstance("ScreenGui", GuiParent, {
	DisplayOrder = 9999,
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

ImGui.MobileGui = ImGui:CreateInstance("ScreenGui", GuiParent, {
	DisplayOrder = 10000,
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

if ImGui.IsMobile then
	ImGui:AddMobileToggleButton()
	ImGui.ScreenGui.Enabled = false
end

UserInputService.InputBegan:Connect(function(Input)
	if UserInputService:GetFocusedTextBox() then return end
	
	if Input.KeyCode == ImGui.ToggleKeybind then
		ImGui:Toggle()
	end
end)

local Cursor = ImGui:CreateInstance("Frame", ImGui.ScreenGui, {
	Size = UDim2.new(0, 20, 0, 20),
	BackgroundTransparency = 1,
	Visible = false,
	ZIndex = 10000
})

local CursorImage = ImGui:CreateInstance("ImageLabel", Cursor, {
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	Image = "rbxasset://textures/Cursors/KeyboardMouse/ArrowCursor.png"
})

if not ImGui.IsMobile and ImGui.ShowCustomCursor then
	RunService.RenderStepped:Connect(function()
		if ImGui.Toggled then
			UserInputService.MouseIconEnabled = false
			Cursor.Visible = true
			Cursor.Position = UDim2.fromOffset(Mouse.X, Mouse.Y)
		else
			UserInputService.MouseIconEnabled = true
			Cursor.Visible = false
		end
	end)
end

ImGui.ThemeManager:SetTheme("Dark")

return ImGui
