local cloneref = cloneref or function(obj) return obj end
local UserInputService = cloneref(game:GetService("UserInputService"))
local TweenService = cloneref(game:GetService("TweenService"))
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local TextService = cloneref(game:GetService("TextService"))

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local ReGui = {
	Version = "2.0.0",
	Windows = {},
	ActiveWindow = nil,
	IsMobile = false,
	DevicePlatform = nil,
	Registry = {},
	Themes = {},
	CurrentTheme = "Dark",
	DefaultTheme = "Dark",
	Signals = {},
	TweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	FastTweenInfo = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	ToggleKeybind = Enum.KeyCode.RightControl,
	ScreenGui = nil,
	Toggled = true
}

if RunService:IsStudio() then
	ReGui.IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
else
	pcall(function()
		ReGui.DevicePlatform = UserInputService:GetPlatform()
	end)
	ReGui.IsMobile = (ReGui.DevicePlatform == Enum.Platform.Android or ReGui.DevicePlatform == Enum.Platform.IOS)
end

ReGui.Themes = {
	Dark = {
		Background = Color3.fromRGB(15, 15, 15),
		Main = Color3.fromRGB(25, 25, 25),
		Secondary = Color3.fromRGB(35, 35, 35),
		Accent = Color3.fromRGB(125, 85, 255),
		AccentHover = Color3.fromRGB(145, 105, 255),
		Outline = Color3.fromRGB(40, 40, 40),
		Text = Color3.fromRGB(255, 255, 255),
		TextDark = Color3.fromRGB(200, 200, 200),
		TextDim = Color3.fromRGB(150, 150, 150),
		Success = Color3.fromRGB(85, 255, 125),
		Warning = Color3.fromRGB(255, 195, 85),
		Error = Color3.fromRGB(255, 85, 85),
		Disabled = Color3.fromRGB(60, 60, 60)
	},
	Light = {
		Background = Color3.fromRGB(240, 240, 240),
		Main = Color3.fromRGB(255, 255, 255),
		Secondary = Color3.fromRGB(245, 245, 245),
		Accent = Color3.fromRGB(125, 85, 255),
		AccentHover = Color3.fromRGB(145, 105, 255),
		Outline = Color3.fromRGB(220, 220, 220),
		Text = Color3.fromRGB(0, 0, 0),
		TextDark = Color3.fromRGB(40, 40, 40),
		TextDim = Color3.fromRGB(100, 100, 100),
		Success = Color3.fromRGB(40, 200, 70),
		Warning = Color3.fromRGB(255, 170, 50),
		Error = Color3.fromRGB(220, 50, 50),
		Disabled = Color3.fromRGB(200, 200, 200)
	},
	Blue = {
		Background = Color3.fromRGB(10, 20, 35),
		Main = Color3.fromRGB(20, 35, 55),
		Secondary = Color3.fromRGB(30, 45, 65),
		Accent = Color3.fromRGB(60, 150, 255),
		AccentHover = Color3.fromRGB(80, 170, 255),
		Outline = Color3.fromRGB(40, 60, 90),
		Text = Color3.fromRGB(255, 255, 255),
		TextDark = Color3.fromRGB(200, 210, 230),
		TextDim = Color3.fromRGB(150, 170, 200),
		Success = Color3.fromRGB(85, 255, 125),
		Warning = Color3.fromRGB(255, 195, 85),
		Error = Color3.fromRGB(255, 85, 85),
		Disabled = Color3.fromRGB(50, 65, 85)
	},
	Purple = {
		Background = Color3.fromRGB(20, 10, 30),
		Main = Color3.fromRGB(35, 20, 50),
		Secondary = Color3.fromRGB(50, 30, 70),
		Accent = Color3.fromRGB(180, 100, 255),
		AccentHover = Color3.fromRGB(200, 120, 255),
		Outline = Color3.fromRGB(60, 40, 80),
		Text = Color3.fromRGB(255, 255, 255),
		TextDark = Color3.fromRGB(220, 200, 240),
		TextDim = Color3.fromRGB(180, 150, 210),
		Success = Color3.fromRGB(150, 255, 180),
		Warning = Color3.fromRGB(255, 200, 120),
		Error = Color3.fromRGB(255, 100, 120),
		Disabled = Color3.fromRGB(60, 50, 70)
	}
}

local function New(class, props)
	local obj = Instance.new(class)
	for prop, val in pairs(props) do
		obj[prop] = val
	end
	return obj
end

local function Tween(obj, props, info)
	info = info or ReGui.TweenInfo
	local tween = TweenService:Create(obj, info, props)
	tween:Play()
	return tween
end

local function GetTheme()
	return ReGui.Themes[ReGui.CurrentTheme] or ReGui.Themes[ReGui.DefaultTheme]
end

function ReGui:UpdateTheme(themeName)
	if not self.Themes[themeName] then
		warn("Theme '" .. tostring(themeName) .. "' does not exist")
		return
	end
	
	self.CurrentTheme = themeName
	
	for _, element in pairs(self.Registry) do
		if element.UpdateColors then
			element:UpdateColors()
		end
	end
end

function ReGui:AddTheme(name, themeData)
	if self.Themes[name] then
		warn("Theme '" .. name .. "' already exists, overwriting")
	end
	
	self.Themes[name] = themeData
end

function ReGui:CreateSignal()
	local signal = {}
	signal.Connections = {}
	
	function signal:Connect(callback)
		local connection = {
			Callback = callback,
			Connected = true
		}
		
		table.insert(self.Connections, connection)
		
		return {
			Disconnect = function()
				connection.Connected = false
				local index = table.find(self.Connections, connection)
				if index then
					table.remove(self.Connections, index)
				end
			end
		}
	end
	
	function signal:Fire(...)
		for _, connection in pairs(self.Connections) do
			if connection.Connected then
				coroutine.wrap(connection.Callback)(...)
			end
		end
	end
	
	return signal
end

function ReGui:GiveSignal(signal)
	table.insert(self.Signals, signal)
	return signal
end

function ReGui:Init()
	self.ScreenGui = New("ScreenGui", {
		Name = "ReGuiEnhanced",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true
	})
	
	if gethui then
		self.ScreenGui.Parent = gethui()
	elseif syn and syn.protect_gui then
		syn.protect_gui(self.ScreenGui)
		self.ScreenGui.Parent = CoreGui
	else
		self.ScreenGui.Parent = CoreGui
	end
	
	if self.IsMobile then
		self:CreateMobileToggleButton()
	end
	
	self:GiveSignal(UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == self.ToggleKeybind and not UserInputService:GetFocusedTextBox() then
			self:Toggle()
		end
	end))
	
	return self
end

function ReGui:CreateMobileToggleButton()
	local button = New("TextButton", {
		Name = "MobileToggle",
		Size = UDim2.fromOffset(60, 60),
		Position = UDim2.new(1, -70, 0, 10),
		BackgroundColor3 = GetTheme().Accent,
		BorderSizePixel = 0,
		Text = "☰",
		TextSize = 28,
		TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.GothamBold,
		Parent = self.ScreenGui
	})
	
	New("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = button
	})
	
	New("UIStroke", {
		Color = GetTheme().Outline,
		Thickness = 2,
		Parent = button
	})
	
	local dragging = false
	local dragStart, startPos
	
	button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = button.Position
		end
	end)
	
	button.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
			local delta = (input.Position - dragStart).Magnitude
			if delta < 5 then
				self:Toggle()
			end
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
			local delta = input.Position - dragStart
			button.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
	
	self.MobileToggleButton = button
end

function ReGui:Toggle(state)
	if state ~= nil then
		self.Toggled = state
	else
		self.Toggled = not self.Toggled
	end
	
	for _, window in pairs(self.Windows) do
		if window.Frame then
			window.Frame.Visible = self.Toggled
		end
	end
end

function ReGui:CreateWindow(config)
	config = config or {}
	local window = {
		Title = config.Title or "ReGui Window",
		Size = config.Size or UDim2.fromOffset(500, 400),
		Position = config.Position or UDim2.fromScale(0.5, 0.5),
		MinSize = config.MinSize or Vector2.new(300, 200),
		Resizable = config.Resizable ~= false,
		Draggable = config.Draggable ~= false,
		Tabs = {},
		ActiveTab = nil,
		Elements = {},
		Sections = {}
	}
	
	local theme = GetTheme()
	
	local mainFrame = New("Frame", {
		Name = "Window_" .. window.Title,
		Size = window.Size,
		Position = window.Position,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Visible = self.Toggled,
		Parent = self.ScreenGui
	})
	
	New("UICorner", {
		CornerRadius = UDim.new(0, 6),
		Parent = mainFrame
	})
	
	New("UIStroke", {
		Color = theme.Outline,
		Thickness = 1,
		Parent = mainFrame
	})
	
	local titleBar = New("Frame", {
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, 35),
		BackgroundColor3 = theme.Main,
		BorderSizePixel = 0,
		Parent = mainFrame
	})
	
	New("UICorner", {
		CornerRadius = UDim.new(0, 6),
		Parent = titleBar
	})
	
	local titleLabel = New("TextLabel", {
		Name = "Title",
		Size = UDim2.new(1, -80, 1, 0),
		Position = UDim2.fromOffset(10, 0),
		BackgroundTransparency = 1,
		Text = window.Title,
		TextColor3 = theme.Text,
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = titleBar
	})
	
	local closeBtn = New("TextButton", {
		Name = "Close",
		Size = UDim2.fromOffset(30, 30),
		Position = UDim2.new(1, -35, 0, 2.5),
		BackgroundColor3 = theme.Error,
		BorderSizePixel = 0,
		Text = "×",
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 20,
		Font = Enum.Font.GothamBold,
		Parent = titleBar
	})
	
	New("UICorner", {
		CornerRadius = UDim.new(0, 4),
		Parent = closeBtn
	})
	
	closeBtn.MouseButton1Click:Connect(function()
		mainFrame:Destroy()
		local index = table.find(self.Windows, window)
		if index then
			table.remove(self.Windows, index)
		end
	end)
	
	closeBtn.MouseEnter:Connect(function()
		Tween(closeBtn, {BackgroundColor3 = theme.Error:Lerp(Color3.new(1, 1, 1), 0.2)}, self.FastTweenInfo)
	end)
	
	closeBtn.MouseLeave:Connect(function()
		Tween(closeBtn, {BackgroundColor3 = theme.Error}, self.FastTweenInfo)
	end)
	
	local tabBar = New("Frame", {
		Name = "TabBar",
		Size = UDim2.new(1, 0, 0, 40),
		Position = UDim2.fromOffset(0, 35),
		BackgroundColor3 = theme.Secondary,
		BorderSizePixel = 0,
		Parent = mainFrame
	})
	
	New("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = tabBar
	})
	
	New("UIPadding", {
		PaddingLeft = UDim.new(0, 5),
		PaddingTop = UDim.new(0, 5),
		Parent = tabBar
	})
	
	local contentFrame = New("Frame", {
		Name = "Content",
		Size = UDim2.new(1, 0, 1, -75),
		Position = UDim2.fromOffset(0, 75),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = mainFrame
	})
	
	if window.Draggable then
		local dragging = false
		local dragStart, startPos
		
		titleBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = mainFrame.Position
			end
		end)
		
		titleBar.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		
		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - dragStart
				mainFrame.Position = UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset + delta.X,
					startPos.Y.Scale,
					startPos.Y.Offset + delta.Y
				)
			end
		end)
	end
	
	if window.Resizable and not self.IsMobile then
		local resizeBtn = New("TextButton", {
			Name = "ResizeHandle",
			Size = UDim2.fromOffset(20, 20),
			Position = UDim2.new(1, 0, 1, 0),
			AnchorPoint = Vector2.new(1, 1),
			BackgroundColor3 = theme.Accent,
			BorderSizePixel = 0,
			Text = "⌟",
			TextColor3 = theme.Text,
			TextSize = 16,
			Font = Enum.Font.GothamBold,
			Parent = mainFrame
		})
		
		New("UICorner", {
			CornerRadius = UDim.new(0, 4),
			Parent = resizeBtn
		})
		
		local resizing = false
		local resizeStart, startSize
		
		resizeBtn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				resizing = true
				resizeStart = Vector2.new(Mouse.X, Mouse.Y)
				startSize = mainFrame.Size
			end
		end)
		
		resizeBtn.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				resizing = false
			end
		end)
		
		UserInputService.InputChanged:Connect(function(input)
			if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
				local delta = Vector2.new(Mouse.X, Mouse.Y) - resizeStart
				local newSize = Vector2.new(
					math.max(window.MinSize.X, startSize.X.Offset + delta.X),
					math.max(window.MinSize.Y, startSize.Y.Offset + delta.Y)
				)
				mainFrame.Size = UDim2.fromOffset(newSize.X, newSize.Y)
			end
		end)
	end
	
	window.Frame = mainFrame
	window.TitleBar = titleBar
	window.TabBar = tabBar
	window.Content = contentFrame
	
	function window:UpdateColors()
		local theme = GetTheme()
		mainFrame.BackgroundColor3 = theme.Background
		titleBar.BackgroundColor3 = theme.Main
		titleLabel.TextColor3 = theme.Text
		closeBtn.BackgroundColor3 = theme.Error
		tabBar.BackgroundColor3 = theme.Secondary
		
		for _, element in pairs(self.Elements) do
			if element.UpdateColors then
				element:UpdateColors()
			end
		end
	end
	
	function window:SetTitle(title)
		self.Title = title
		titleLabel.Text = title
	end
	
	function window:AddTab(name, icon)
		local tab = {
			Name = name,
			Icon = icon,
			Elements = {},
			Window = self,
			Sections = {},
			Active = false
		}
		
		local theme = GetTheme()
		
		local tabBtn = New("TextButton", {
			Name = "Tab_" .. name,
			Size = UDim2.fromOffset(self.IsMobile and 80 or 120, 30),
			BackgroundColor3 = theme.Main,
			BorderSizePixel = 0,
			Text = icon and icon .. " " .. name or name,
			TextColor3 = theme.TextDim,
			TextSize = 14,
			Font = Enum.Font.Gotham,
			Parent = tabBar
		})
		
		New("UICorner", {
			CornerRadius = UDim.new(0, 4),
			Parent = tabBtn
		})
		
		local tabContent = New("ScrollingFrame", {
			Name = "TabContent_" .. name,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = theme.Accent,
			Visible = false,
			CanvasSize = UDim2.fromScale(1, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Parent = contentFrame
		})
		
		New("UIListLayout", {
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = tabContent
		})
		
		New("UIPadding", {
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 10),
			Parent = tabContent
		})
		
		tabBtn.MouseButton1Click:Connect(function()
			tab:Show()
		end)
		
		tabBtn.MouseEnter:Connect(function()
			if not tab.Active then
				Tween(tabBtn, {TextColor3 = theme.Text}, self.FastTweenInfo)
			end
		end)
		
		tabBtn.MouseLeave:Connect(function()
			if not tab.Active then
				Tween(tabBtn, {TextColor3 = theme.TextDim}, self.FastTweenInfo)
			end
		end)
		
		tab.Button = tabBtn
		tab.Content = tabContent
		
		function tab:Show()
			if self.Window.ActiveTab then
				self.Window.ActiveTab:Hide()
			end
			
			self.Active = true
			self.Content.Visible = true
			Tween(self.Button, {BackgroundColor3 = theme.Accent, TextColor3 = theme.Text}, ReGui.TweenInfo)
			self.Window.ActiveTab = self
		end
		
		function tab:Hide()
			self.Active = false
			self.Content.Visible = false
			Tween(self.Button, {BackgroundColor3 = theme.Main, TextColor3 = theme.TextDim}, ReGui.TweenInfo)
		end
		
		function tab:UpdateColors()
			local theme = GetTheme()
			tabContent.ScrollBarImageColor3 = theme.Accent
			if self.Active then
				tabBtn.BackgroundColor3 = theme.Accent
				tabBtn.TextColor3 = theme.Text
			else
				tabBtn.BackgroundColor3 = theme.Main
				tabBtn.TextColor3 = theme.TextDim
			end
			
			for _, element in pairs(self.Elements) do
				if element.UpdateColors then
					element:UpdateColors()
				end
			end
		end
		
		function tab:AddSection(name)
			local section = {
				Name = name,
				Elements = {},
				Tab = self,
				Collapsed = false
			}
			
			local theme = GetTheme()
			
			local sectionFrame = New("Frame", {
				Name = "Section_" .. name,
				Size = UDim2.new(1, 0, 0, 0),
				BackgroundColor3 = theme.Main,
				BorderSizePixel = 0,
				AutomaticSize = Enum.AutomaticSize.Y,
				Parent = tabContent
			})
			
			New("UICorner", {
				CornerRadius = UDim.new(0, 6),
				Parent = sectionFrame
			})
			
			New("UIStroke", {
				Color = theme.Outline,
				Thickness = 1,
				Parent = sectionFrame
			})
			
			local header = New("TextButton", {
				Name = "Header",
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundColor3 = theme.Secondary,
				BorderSizePixel = 0,
				Text = "▼ " .. name,
				TextColor3 = theme.Text,
				TextSize = 14,
				Font = Enum.Font.GothamBold,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = sectionFrame
			})
			
			New("UICorner", {
				CornerRadius = UDim.new(0, 6),
				Parent = header
			})
			
			New("UIPadding", {
				PaddingLeft = UDim.new(0, 10),
				Parent = header
			})
			
			local container = New("Frame", {
				Name = "Container",
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.fromOffset(0, 30),
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.Y,
				Parent = sectionFrame
			})
			
			New("UIListLayout", {
				Padding = UDim.new(0, 5),
				SortOrder = Enum.SortOrder.LayoutOrder,
				Parent = container
			})
			
			New("UIPadding", {
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
				PaddingTop = UDim.new(0, 8),
				PaddingBottom = UDim.new(0, 8),
				Parent = container
			})
			
			header.MouseButton1Click:Connect(function()
				section:Toggle()
			end)
			
			header.MouseEnter:Connect(function()
				Tween(header, {BackgroundColor3 = theme.Secondary:Lerp(theme.Accent, 0.1)}, ReGui.FastTweenInfo)
			end)
			
			header.MouseLeave:Connect(function()
				Tween(header, {BackgroundColor3 = theme.Secondary}, ReGui.FastTweenInfo)
			end)
			
			section.Frame = sectionFrame
			section.Header = header
			section.Container = container
			
			function section:Toggle()
				self.Collapsed = not self.Collapsed
				self.Container.Visible = not self.Collapsed
				self.Header.Text = (self.Collapsed and "▶ " or "▼ ") .. self.Name
			end
			
			function section:UpdateColors()
				local theme = GetTheme()
				sectionFrame.BackgroundColor3 = theme.Main
				header.BackgroundColor3 = theme.Secondary
				header.TextColor3 = theme.Text
				
				for _, element in pairs(self.Elements) do
					if element.UpdateColors then
						element:UpdateColors()
					end
				end
			end
			
			function section:AddButton(config)
				config = config or {}
				local button = {
					Text = config.Text or "Button",
					Callback = config.Callback or function() end,
					Section = self
				}
				
				local theme = GetTheme()
				
				local btnFrame = New("TextButton", {
					Name = "Button_" .. button.Text,
					Size = UDim2.new(1, 0, 0, 32),
					BackgroundColor3 = theme.Accent,
					BorderSizePixel = 0,
					Text = button.Text,
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = 14,
					Font = Enum.Font.Gotham,
					Parent = container
				})
				
				New("UICorner", {
					CornerRadius = UDim.new(0, 4),
					Parent = btnFrame
				})
				
				btnFrame.MouseButton1Click:Connect(function()
					button.Callback()
				end)
				
				btnFrame.MouseEnter:Connect(function()
					Tween(btnFrame, {BackgroundColor3 = theme.AccentHover}, ReGui.FastTweenInfo)
				end)
				
				btnFrame.MouseLeave:Connect(function()
					Tween(btnFrame, {BackgroundColor3 = theme.Accent}, ReGui.FastTweenInfo)
				end)
				
				button.Frame = btnFrame
				
				function button:UpdateColors()
					local theme = GetTheme()
					btnFrame.BackgroundColor3 = theme.Accent
				end
				
				function button:SetText(text)
					self.Text = text
					btnFrame.Text = text
				end
				
				table.insert(self.Elements, button)
				table.insert(tab.Elements, button)
				table.insert(window.Elements, button)
				table.insert(ReGui.Registry, button)
				
				return button
			end
			
			function section:AddToggle(config)
				config = config or {}
				local toggle = {
					Text = config.Text or "Toggle",
					Value = config.Default or false,
					Callback = config.Callback or function() end,
					Section = self
				}
				
				local theme = GetTheme()
				
				local toggleFrame = New("Frame", {
					Name = "Toggle_" .. toggle.Text,
					Size = UDim2.new(1, 0, 0, 32),
					BackgroundColor3 = theme.Secondary,
					BorderSizePixel = 0,
					Parent = container
				})
				
				New("UICorner", {
					CornerRadius = UDim.new(0, 4),
					Parent = toggleFrame
				})
				
				local label = New("TextLabel", {
					Size = UDim2.new(1, -45, 1, 0),
					Position = UDim2.fromOffset(10, 0),
					BackgroundTransparency = 1,
					Text = toggle.Text,
					TextColor3 = theme.Text,
					TextSize = 14,
					Font = Enum.Font.Gotham,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = toggleFrame
				})
				
				local switchFrame = New("TextButton", {
					Name = "Switch",
					Size = UDim2.fromOffset(40, 20),
					Position = UDim2.new(1, -45, 0.5, 0),
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundColor3 = toggle.Value and theme.Accent or theme.Disabled,
					BorderSizePixel = 0,
					Text = "",
					Parent = toggleFrame
				})
				
				New("UICorner", {
					CornerRadius = UDim.new(1, 0),
					Parent = switchFrame
				})
				
				local knob = New("Frame", {
					Name = "Knob",
					Size = UDim2.fromOffset(16, 16),
					Position = toggle.Value and UDim2.new(1, -18, 0.5, 0) or UDim2.fromOffset(2, 2),
					AnchorPoint = toggle.Value and Vector2.new(0, 0.5) or Vector2.new(0, 0),
					BackgroundColor3 = Color3.new(1, 1, 1),
					BorderSizePixel = 0,
					Parent = switchFrame
				})
				
				New("UICorner", {
					CornerRadius = UDim.new(1, 0),
					Parent = knob
				})
				
				local function updateToggle(value)
					toggle.Value = value
					Tween(switchFrame, {
						BackgroundColor3 = value and theme.Accent or theme.Disabled
					}, ReGui.FastTweenInfo)
					Tween(knob, {
						Position = value and UDim2.new(1, -18, 0.5, 0) or UDim2.fromOffset(2, 2),
						AnchorPoint = value and Vector2.new(0, 0.5) or Vector2.new(0, 0)
					}, ReGui.FastTweenInfo)
					toggle.Callback(value)
				end
				
				switchFrame.MouseButton1Click:Connect(function()
					updateToggle(not toggle.Value)
				end)
				
				switchFrame.MouseEnter:Connect(function()
					Tween(switchFrame, {BackgroundTransparency = 0.1}, ReGui.FastTweenInfo)
				end)
				
				switchFrame.MouseLeave:Connect(function()
					Tween(switchFrame, {BackgroundTransparency = 0}, ReGui.FastTweenInfo)
				end)
				
				toggle.Frame = toggleFrame
				toggle.Switch = switchFrame
				
				function toggle:UpdateColors()
					local theme = GetTheme()
					toggleFrame.BackgroundColor3 = theme.Secondary
					label.TextColor3 = theme.Text
					switchFrame.BackgroundColor3 = self.Value and theme.Accent or theme.Disabled
				end
				
				function toggle:SetValue(value)
					updateToggle(value)
				end
				
				function toggle:SetText(text)
					self.Text = text
					label.Text = text
				end
				
				table.insert(self.Elements, toggle)
				table.insert(tab.Elements, toggle)
				table.insert(window.Elements, toggle)
				table.insert(ReGui.Registry, toggle)
				
				return toggle
			end
			
			function section:AddSlider(config)
				config = config or {}
				local slider = {
					Text = config.Text or "Slider",
					Min = config.Min or 0,
					Max = config.Max or 100,
					Default = config.Default or 50,
					Value = config.Default or 50,
					Increment = config.Increment or 1,
					Suffix = config.Suffix or "",
					Callback = config.Callback or function() end,
					Section = self
				}
				
				local theme = GetTheme()
				
				local sliderFrame = New("Frame", {
					Name = "Slider_" .. slider.Text,
					Size = UDim2.new(1, 0, 0, 50),
					BackgroundColor3 = theme.Secondary,
					BorderSizePixel = 0,
					Parent = container
				})
				
				New("UICorner", {
					CornerRadius = UDim.new(0, 4),
					Parent = sliderFrame
				})
				
				local label = New("TextLabel", {
					Size = UDim2.new(1, -60, 0, 20),
					Position = UDim2.fromOffset(10, 5),
					BackgroundTransparency = 1,
					Text = slider.Text,
					TextColor3 = theme.Text,
					TextSize = 14,
					Font = Enum.Font.Gotham,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = sliderFrame
				})
				
				local valueLabel = New("TextLabel", {
					Size = UDim2.fromOffset(50, 20),
					Position = UDim2.new(1, -55, 0, 5),
					BackgroundTransparency = 1,
					Text = tostring(slider.Value) .. slider.Suffix,
					TextColor3 = theme.TextDark,
					TextSize = 14,
					Font = Enum.Font.GothamBold,
					TextXAlignment = Enum.TextXAlignment.Right,
					Parent = sliderFrame
				})
				
				local track = New("Frame", {
					Name = "Track",
					Size = UDim2.new(1, -20, 0, 4),
					Position = UDim2.new(0, 10, 1, -15),
					BackgroundColor3 = theme.Disabled,
					BorderSizePixel = 0,
					Parent = sliderFrame
				})
				
				New("UICorner", {
					CornerRadius = UDim.new(1, 0),
					Parent = track
				})
				
				local fill = New("Frame", {
					Name = "Fill",
					Size = UDim2.fromScale((slider.Value - slider.Min) / (slider.Max - slider.Min), 1),
					BackgroundColor3 = theme.Accent,
					BorderSizePixel = 0,
					Parent = track
				})
				
				New("UICorner", {
					CornerRadius = UDim.new(1, 0),
					Parent = fill
				})
				
				local dragging = false
				
				local function updateSlider(input)
					local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
					local value = math.floor((slider.Min + (slider.Max - slider.Min) * pos) / slider.Increment + 0.5) * slider.Increment
					slider.Value = math.clamp(value, slider.Min, slider.Max)
					valueLabel.Text = tostring(slider.Value) .. slider.Suffix
					fill.Size = UDim2.fromScale((slider.Value - slider.Min) / (slider.Max - slider.Min), 1)
					slider.Callback(slider.Value)
				end
				
				track.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = true
						updateSlider(input)
					end
				end)
				
				track.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = false
					end
				end)
				
				UserInputService.InputChanged:Connect(function(input)
					if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						updateSlider(input)
					end
				end)
				
				slider.Frame = sliderFrame
				slider.Track = track
				slider.Fill = fill
				
				function slider:UpdateColors()
					local theme = GetTheme()
					sliderFrame.BackgroundColor3 = theme.Secondary
					label.TextColor3 = theme.Text
					valueLabel.TextColor3 = theme.TextDark
					track.BackgroundColor3 = theme.Disabled
					fill.BackgroundColor3 = theme.Accent
				end
				
				function slider:SetValue(value)
					value = math.clamp(value, self.Min, self.Max)
					self.Value = value
					valueLabel.Text = tostring(value) .. self.Suffix
					fill.Size = UDim2.fromScale((value - self.Min) / (self.Max - self.Min), 1)
					self.Callback(value)
				end
				
				function slider:SetText(text)
					self.Text = text
					label.Text = text
				end
				
				table.insert(self.Elements, slider)
				table.insert(tab.Elements, slider)
				table.insert(window.Elements, slider)
				table.insert(ReGui.Registry, slider)
				
				return slider
			end
			
			function section:AddDropdown(config)
				config = config or {}
				local dropdown = {
					Text = config.Text or "Dropdown",
					Options = config.Options or {},
					Default = config.Default,
					Value = config.Default,
					Callback = config.Callback or function() end,
					Section = self,
					Open = false
				}
				
				local theme = GetTheme()
				
				local dropdownFrame = New("Frame", {
					Name = "Dropdown_" .. dropdown.Text,
					Size = UDim2.new(1, 0, 0, 60),
					BackgroundColor3 = theme.Secondary,
					BorderSizePixel = 0,
					ClipsDescendants = true,
					Parent = container
				})
				
				New("UICorner", {
					CornerRadius = UDim.new(0, 4),
					Parent = dropdownFrame
				})
				
				local label = New("TextLabel", {
					Size = UDim2.new(1, -10, 0, 20),
					Position = UDim2.fromOffset(10, 5),
					BackgroundTransparency = 1,
					Text = dropdown.Text,
					TextColor3 = theme.Text,
					TextSize = 14,
					Font = Enum.Font.Gotham,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = dropdownFrame
				})
				
				local selector = New("TextButton", {
					Name = "Selector",
					Size = UDim2.new(1, -20, 0, 25),
					Position = UDim2.fromOffset(10, 30),
					BackgroundColor3 = theme.Main,
					BorderSizePixel = 0,
					Text = dropdown.Value or "Select...",
					TextColor3 = theme.TextDark,
					TextSize = 13,
					Font = Enum.Font.Gotham,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = dropdownFrame
				})
				
				New("UICorner", {
					CornerRadius = UDim.new(0, 4),
					Parent = selector
				})
				
				New("UIPadding", {
					PaddingLeft = UDim.new(0, 8),
					Parent = selector
				})
				
				New("UIStroke", {
					Color = theme.Outline,
					Thickness = 1,
					Parent = selector
				})
				
				local arrow = New("TextLabel", {
					Size = UDim2.fromOffset(20, 25),
					Position = UDim2.new(1, -25, 0, 0),
					BackgroundTransparency = 1,
					Text = "▼",
					TextColor3 = theme.TextDim,
					TextSize = 10,
					Font = Enum.Font.Gotham,
					Parent = selector
				})
				
				local optionList = New("ScrollingFrame", {
					Name = "Options",
					Size = UDim2.new(1, -20, 0, 0),
					Position = UDim2.fromOffset(10, 60),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ScrollBarThickness = 4,
					ScrollBarImageColor3 = theme.Accent,
					CanvasSize = UDim2.fromScale(1, 0),
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					Visible = false,
					Parent = dropdownFrame
				})
				
				New("UIListLayout", {
					Padding = UDim.new(0, 2),
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = optionList
				})
				
				for _, option in ipairs(dropdown.Options) do
					local optBtn = New("TextButton", {
						Name = "Option_" .. option,
						Size = UDim2.new(1, 0, 0, 25),
						BackgroundColor3 = theme.Main,
						BorderSizePixel = 0,
						Text = option,
						TextColor3 = theme.TextDark,
						TextSize = 13,
						Font = Enum.Font.Gotham,
						TextXAlignment = Enum.TextXAlignment.Left,
						Parent = optionList
					})
					
					New("UICorner", {
						CornerRadius = UDim.new(0, 4),
						Parent = optBtn
					})
					
					New("UIPadding", {
						PaddingLeft = UDim.new(0, 8),
						Parent = optBtn
					})
					
					optBtn.MouseButton1Click:Connect(function()
						dropdown.Value = option
						selector.Text = option
						dropdown:Close()
						dropdown.Callback(option)
					end)
					
					optBtn.MouseEnter:Connect(function()
						Tween(optBtn, {BackgroundColor3 = theme.Accent}, ReGui.FastTweenInfo)
					end)
					
					optBtn.MouseLeave:Connect(function()
						Tween(optBtn, {BackgroundColor3 = theme.Main}, ReGui.FastTweenInfo)
					end)
				end
				
				selector.MouseButton1Click:Connect(function()
					dropdown:Toggle()
				end)
				
				dropdown.Frame = dropdownFrame
				dropdown.Selector = selector
				dropdown.OptionList = optionList
				
				function dropdown:Toggle()
					self.Open = not self.Open
					if self.Open then
						self:Open_Menu()
					else
						self:Close()
					end
				end
				
				function dropdown:Open_Menu()
					self.Open = true
					local optionCount = #self.Options
					local height = math.min(optionCount * 27 + 5, 135)
					optionList.Visible = true
					optionList.Size = UDim2.new(1, -20, 0, height)
					dropdownFrame.Size = UDim2.new(1, 0, 0, 65 + height)
					arrow.Text = "▲"
				end
				
				function dropdown:Close()
					self.Open = false
					optionList.Visible = false
					optionList.Size = UDim2.new(1, -20, 0, 0)
					dropdownFrame.Size = UDim2.new(1, 0, 0, 60)
					arrow.Text = "▼"
				end
				
				function dropdown:UpdateColors()
					local theme = GetTheme()
					dropdownFrame.BackgroundColor3 = theme.Secondary
					label.TextColor3 = theme.Text
					selector.BackgroundColor3 = theme.Main
					selector.TextColor3 = theme.TextDark
					arrow.TextColor3 = theme.TextDim
					optionList.ScrollBarImageColor3 = theme.Accent
					
					for _, child in ipairs(optionList:GetChildren()) do
						if child:IsA("TextButton") then
							child.BackgroundColor3 = theme.Main
							child.TextColor3 = theme.TextDark
						end
					end
				end
				
				function dropdown:SetValue(value)
					if table.find(self.Options, value) then
						self.Value = value
						selector.Text = value
						self.Callback(value)
					end
				end
				
				function dropdown:SetOptions(options)
					self.Options = options
					for _, child in ipairs(optionList:GetChildren()) do
						if child:IsA("TextButton") then
							child:Destroy()
						end
					end
					
					for _, option in ipairs(options) do
						local optBtn = New("TextButton", {
							Name = "Option_" .. option,
							Size = UDim2.new(1, 0, 0, 25),
							BackgroundColor3 = theme.Main,
							BorderSizePixel = 0,
							Text = option,
							TextColor3 = theme.TextDark,
							TextSize = 13,
							Font = Enum.Font.Gotham,
							TextXAlignment = Enum.TextXAlignment.Left,
							Parent = optionList
						})
						
						New("UICorner", {
							CornerRadius = UDim.new(0, 4),
							Parent = optBtn
						})
						
						New("UIPadding", {
							PaddingLeft = UDim.new(0, 8),
							Parent = optBtn
						})
						
						optBtn.MouseButton1Click:Connect(function()
							self.Value = option
							selector.Text = option
							self:Close()
							self.Callback(option)
						end)
						
						optBtn.MouseEnter:Connect(function()
							Tween(optBtn, {BackgroundColor3 = theme.Accent}, ReGui.FastTweenInfo)
						end)
						
						optBtn.MouseLeave:Connect(function()
							Tween(optBtn, {BackgroundColor3 = theme.Main}, ReGui.FastTweenInfo)
						end)
					end
				end
				
				table.insert(self.Elements, dropdown)
				table.insert(tab.Elements, dropdown)
				table.insert(window.Elements, dropdown)
				table.insert(ReGui.Registry, dropdown)
				
				return dropdown
			end
			
			function section:AddTextbox(config)
				config = config or {}
				local textbox = {
					Text = config.Text or "Textbox",
					Placeholder = config.Placeholder or "Enter text...",
					Default = config.Default or "",
					Value = config.Default or "",
					Callback = config.Callback or function() end,
					Section = self
				}
				
				local theme = GetTheme()
				
				local textboxFrame = New("Frame", {
					Name = "Textbox_" .. textbox.Text,
					Size = UDim2.new(1, 0, 0, 60),
					BackgroundColor3 = theme.Secondary,
					BorderSizePixel = 0,
					Parent = container
				})
				
				New("UICorner", {
					CornerRadius = UDim.new(0, 4),
					Parent = textboxFrame
				})
				
				local label = New("TextLabel", {
					Size = UDim2.new(1, -10, 0, 20),
					Position = UDim2.fromOffset(10, 5),
					BackgroundTransparency = 1,
					Text = textbox.Text,
					TextColor3 = theme.Text,
					TextSize = 14,
					Font = Enum.Font.Gotham,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = textboxFrame
				})
				
				local input = New("TextBox", {
					Name = "Input",
					Size = UDim2.new(1, -20, 0, 25),
					Position = UDim2.fromOffset(10, 30),
					BackgroundColor3 = theme.Main,
					BorderSizePixel = 0,
					Text = textbox.Value,
					PlaceholderText = textbox.Placeholder,
					PlaceholderColor3 = theme.TextDim,
					TextColor3 = theme.Text,
					TextSize = 13,
					Font = Enum.Font.Gotham,
					TextXAlignment = Enum.TextXAlignment.Left,
					ClearTextOnFocus = false,
					Parent = textboxFrame
				})
				
				New("UICorner", {
					CornerRadius = UDim.new(0, 4),
					Parent = input
				})
				
				New("UIPadding", {
					PaddingLeft = UDim.new(0, 8),
					Parent = input
				})
				
				New("UIStroke", {
					Color = theme.Outline,
					Thickness = 1,
					Parent = input
				})
				
				input.FocusLost:Connect(function(enterPressed)
					textbox.Value = input.Text
					textbox.Callback(input.Text, enterPressed)
				end)
				
				input.Focused:Connect(function()
					Tween(input, {BackgroundColor3 = theme.Main:Lerp(theme.Accent, 0.1)}, ReGui.FastTweenInfo)
				end)
				
				input:GetPropertyChangedSignal("Text"):Connect(function()
					textbox.Value = input.Text
				end)
				
				textbox.Frame = textboxFrame
				textbox.Input = input
				
				function textbox:UpdateColors()
					local theme = GetTheme()
					textboxFrame.BackgroundColor3 = theme.Secondary
					label.TextColor3 = theme.Text
					input.BackgroundColor3 = theme.Main
					input.PlaceholderColor3 = theme.TextDim
					input.TextColor3 = theme.Text
				end
				
				function textbox:SetValue(value)
					self.Value = value
					input.Text = value
				end
				
				function textbox:SetText(text)
					self.Text = text
					label.Text = text
				end
				
				table.insert(self.Elements, textbox)
				table.insert(tab.Elements, textbox)
				table.insert(window.Elements, textbox)
				table.insert(ReGui.Registry, textbox)
				
				return textbox
			end
			
			function section:AddLabel(config)
				config = config or {}
				local labelElement = {
					Text = config.Text or "Label",
					Section = self
				}
				
				local theme = GetTheme()
				
				local labelFrame = New("TextLabel", {
					Name = "Label_" .. labelElement.Text,
					Size = UDim2.new(1, 0, 0, 25),
					BackgroundTransparency = 1,
					Text = labelElement.Text,
					TextColor3 = theme.TextDark,
					TextSize = 13,
					Font = Enum.Font.Gotham,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextWrapped = true,
					Parent = container
				})
				
				New("UIPadding", {
					PaddingLeft = UDim.new(0, 10),
					Parent = labelFrame
				})
				
				labelElement.Frame = labelFrame
				
				function labelElement:UpdateColors()
					local theme = GetTheme()
					labelFrame.TextColor3 = theme.TextDark
				end
				
				function labelElement:SetText(text)
					self.Text = text
					labelFrame.Text = text
				end
				
				table.insert(self.Elements, labelElement)
				table.insert(tab.Elements, labelElement)
				table.insert(window.Elements, labelElement)
				table.insert(ReGui.Registry, labelElement)
				
				return labelElement
			end
			
			function section:AddDivider()
				local theme = GetTheme()
				
				local divider = New("Frame", {
					Name = "Divider",
					Size = UDim2.new(1, -20, 0, 1),
					Position = UDim2.fromOffset(10, 0),
					BackgroundColor3 = theme.Outline,
					BorderSizePixel = 0,
					Parent = container
				})
				
				local dividerElement = {
					Frame = divider,
					Section = self
				}
				
				function dividerElement:UpdateColors()
					local theme = GetTheme()
					divider.BackgroundColor3 = theme.Outline
				end
				
				table.insert(self.Elements, dividerElement)
				table.insert(tab.Elements, dividerElement)
				table.insert(window.Elements, dividerElement)
				table.insert(ReGui.Registry, dividerElement)
				
				return dividerElement
			end
			
			function section:AddColorPicker(config)
				config = config or {}
				local colorPicker = {
					Text = config.Text or "Color",
					Default = config.Default or Color3.fromRGB(255, 255, 255),
					Value = config.Default or Color3.fromRGB(255, 255, 255),
					Callback = config.Callback or function() end,
					Section = self,
					Open = false
				}
				
				local theme = GetTheme()
				
				local pickerFrame = New("Frame", {
					Name = "ColorPicker_" .. colorPicker.Text,
					Size = UDim2.new(1, 0, 0, 32),
					BackgroundColor3 = theme.Secondary,
					BorderSizePixel = 0,
					Parent = container
				})
				
				New("UICorner", {
					CornerRadius = UDim.new(0, 4),
					Parent = pickerFrame
				})
				
				local label = New("TextLabel", {
					Size = UDim2.new(1, -45, 1, 0),
					Position = UDim2.fromOffset(10, 0),
					BackgroundTransparency = 1,
					Text = colorPicker.Text,
					TextColor3 = theme.Text,
					TextSize = 14,
					Font = Enum.Font.Gotham,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = pickerFrame
				})
				
				local display = New("TextButton", {
					Name = "Display",
					Size = UDim2.fromOffset(30, 20),
					Position = UDim2.new(1, -35, 0.5, 0),
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundColor3 = colorPicker.Value,
					BorderSizePixel = 0,
					Text = "",
					Parent = pickerFrame
				})
				
				New("UICorner", {
					CornerRadius = UDim.new(0, 4),
					Parent = display
				})
				
				New("UIStroke", {
					Color = theme.Outline,
					Thickness = 1,
					Parent = display
				})
				
				display.MouseButton1Click:Connect(function()
					colorPicker:Toggle()
				end)
				
				colorPicker.Frame = pickerFrame
				colorPicker.Display = display
				
				function colorPicker:Toggle()
					self.Open = not self.Open
				end
				
				function colorPicker:UpdateColors()
					local theme = GetTheme()
					pickerFrame.BackgroundColor3 = theme.Secondary
					label.TextColor3 = theme.Text
					display.BackgroundColor3 = self.Value
				end
				
				function colorPicker:SetValue(color)
					self.Value = color
					display.BackgroundColor3 = color
					self.Callback(color)
				end
				
				function colorPicker:SetText(text)
					self.Text = text
					label.Text = text
				end
				
				table.insert(self.Elements, colorPicker)
				table.insert(tab.Elements, colorPicker)
				table.insert(window.Elements, colorPicker)
				table.insert(ReGui.Registry, colorPicker)
				
				return colorPicker
			end
			
			function section:AddKeybind(config)
				config = config or {}
				local keybind = {
					Text = config.Text or "Keybind",
					Default = config.Default or Enum.KeyCode.E,
					Value = config.Default or Enum.KeyCode.E,
					Callback = config.Callback or function() end,
					Section = self,
					Listening = false
				}
				
				local theme = GetTheme()
				
				local keybindFrame = New("Frame", {
					Name = "Keybind_" .. keybind.Text,
					Size = UDim2.new(1, 0, 0, 32),
					BackgroundColor3 = theme.Secondary,
					BorderSizePixel = 0,
					Parent = container
				})
				
				New("UICorner", {
					CornerRadius = UDim.new(0, 4),
					Parent = keybindFrame
				})
				
				local label = New("TextLabel", {
					Size = UDim2.new(1, -80, 1, 0),
					Position = UDim2.fromOffset(10, 0),
					BackgroundTransparency = 1,
					Text = keybind.Text,
					TextColor3 = theme.Text,
					TextSize = 14,
					Font = Enum.Font.Gotham,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = keybindFrame
				})
				
				local keyButton = New("TextButton", {
					Name = "KeyButton",
					Size = UDim2.fromOffset(65, 20),
					Position = UDim2.new(1, -70, 0.5, 0),
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundColor3 = theme.Main,
					BorderSizePixel = 0,
					Text = keybind.Value.Name,
					TextColor3 = theme.TextDark,
					TextSize = 12,
					Font = Enum.Font.Gotham,
					Parent = keybindFrame
				})
				
				New("UICorner", {
					CornerRadius = UDim.new(0, 4),
					Parent = keyButton
				})
				
				New("UIStroke", {
					Color = theme.Outline,
					Thickness = 1,
					Parent = keyButton
				})
				
				keyButton.MouseButton1Click:Connect(function()
					keybind.Listening = true
					keyButton.Text = "..."
				end)
				
				local connection
				connection = self:GiveSignal(UserInputService.InputBegan:Connect(function(input, gameProcessed)
					if keybind.Listening and input.UserInputType == Enum.UserInputType.Keyboard then
						keybind.Value = input.KeyCode
						keyButton.Text = input.KeyCode.Name
						keybind.Listening = false
					elseif not gameProcessed and input.KeyCode == keybind.Value then
						keybind.Callback()
					end
				end))
				
				keybind.Frame = keybindFrame
				keybind.KeyButton = keyButton
				
				function keybind:UpdateColors()
					local theme = GetTheme()
					keybindFrame.BackgroundColor3 = theme.Secondary
					label.TextColor3 = theme.Text
					keyButton.BackgroundColor3 = theme.Main
					keyButton.TextColor3 = theme.TextDark
				end
				
				function keybind:SetValue(key)
					self.Value = key
					keyButton.Text = key.Name
				end
				
				function keybind:SetText(text)
					self.Text = text
					label.Text = text
				end
				
				table.insert(self.Elements, keybind)
				table.insert(tab.Elements, keybind)
				table.insert(window.Elements, keybind)
				table.insert(ReGui.Registry, keybind)
				
				return keybind
			end
			
			table.insert(self.Sections, section)
			table.insert(tab.Elements, section)
			
			return section
		end
		
		table.insert(self.Tabs, tab)
		
		if not self.ActiveTab then
			tab:Show()
		end
		
		return tab
	end
	
	table.insert(self.Windows, window)
	table.insert(self.Registry, window)
	
	return window
end

function ReGui:AddNotification(config)
	config = config or {}
	local notification = {
		Title = config.Title or "Notification",
		Text = config.Text or "",
		Duration = config.Duration or 3,
		Type = config.Type or "Info"
	}
	
	local theme = GetTheme()
	local typeColors = {
		Info = theme.Accent,
		Success = theme.Success,
		Warning = theme.Warning,
		Error = theme.Error
	}
	
	local notifFrame = New("Frame", {
		Name = "Notification",
		Size = UDim2.fromOffset(300, 80),
		Position = UDim2.new(1, -310, 1, 10),
		BackgroundColor3 = theme.Main,
		BorderSizePixel = 0,
		Parent = self.ScreenGui
	})
	
	New("UICorner", {
		CornerRadius = UDim.new(0, 6),
		Parent = notifFrame
	})
	
	New("UIStroke", {
		Color = typeColors[notification.Type] or theme.Accent,
		Thickness = 2,
		Parent = notifFrame
	})
	
	local titleLabel = New("TextLabel", {
		Size = UDim2.new(1, -20, 0, 25),
		Position = UDim2.fromOffset(10, 8),
		BackgroundTransparency = 1,
		Text = notification.Title,
		TextColor3 = theme.Text,
		TextSize = 15,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = notifFrame
	})
	
	local textLabel = New("TextLabel", {
		Size = UDim2.new(1, -20, 0, 40),
		Position = UDim2.fromOffset(10, 33),
		BackgroundTransparency = 1,
		Text = notification.Text,
		TextColor3 = theme.TextDark,
		TextSize = 13,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		Parent = notifFrame
	})
	
	local slideIn = Tween(notifFrame, {Position = UDim2.new(1, -310, 1, -90)}, self.TweenInfo)
	
	task.delay(notification.Duration, function()
		local slideOut = Tween(notifFrame, {Position = UDim2.new(1, -310, 1, 10)}, self.TweenInfo)
		slideOut.Completed:Wait()
		notifFrame:Destroy()
	end)
	
	return notification
end

function ReGui:Destroy()
	for _, signal in pairs(self.Signals) do
		if signal.Disconnect then
			signal:Disconnect()
		end
	end
	
	if self.ScreenGui then
		self.ScreenGui:Destroy()
	end
	
	self.Windows = {}
	self.Registry = {}
	self.Signals = {}
end

return ReGui:Init()
