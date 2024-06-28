local mathsies = require("lib.mathsies")
local vec3 = mathsies.vec3
local quat = mathsies.quat
local mat4 = mathsies.mat4

local consts = require("consts")

local normaliseOrZero = require("util.normalise-or-zero")
local limitVectorLength = require("util.limit-vector-length")

local mouseDx, mouseDy

local outputCanvas
local skyFromDirectionShader, skyFromMapShader
local skybox, dummyTexture

local camera

function love.mousepressed()
	love.mouse.setRelativeMode(not love.mouse.getRelativeMode())
end

function love.mousemoved(_, _, dx, dy)
	mouseDx, mouseDy = dx, dy
end

function love.load()
	outputCanvas = love.graphics.newCanvas(love.graphics.getDimensions())
	skyFromDirectionShader = love.graphics.newShader(
		love.filesystem.read("shaders/include/lib/simplex3d.glsl") ..
		love.filesystem.read("shaders/include/sky.glsl") ..
		love.filesystem.read("shaders/sky-from-direction.glsl")
	)
	skyFromMapShader = love.graphics.newShader("shaders/sky-from-map.glsl")
	dummyTexture = love.graphics.newImage(love.image.newImageData(1, 1))

	camera = {
		orientation = quat(),
		verticalFOV = math.rad(50)
	}

	local sideSize = 2048
	local faceCanvas = love.graphics.newCanvas(sideSize, sideSize)
	local faces = {} -- ImageData
	love.graphics.setShader(skyFromDirectionShader)
	local cameraToClip = mat4.perspectiveLeftHanded(
		1,
		consts.tau * 0.25,
		2,
		1
	)
	for _, orientation in ipairs({
		quat.fromAxisAngle(consts.upVector * consts.tau * 0.25),
		quat.fromAxisAngle(consts.upVector * consts.tau * -0.25),
		quat.fromAxisAngle(consts.rightVector * consts.tau * 0.25),
		quat.fromAxisAngle(consts.rightVector * consts.tau * -0.25),
		quat(),
		quat.fromAxisAngle(consts.upVector * consts.tau * 0.5)
	}) do
		love.graphics.setCanvas(faceCanvas)
		-- love.graphics.clear()
		local worldToCameraStationary = mat4.camera(vec3(), orientation)
		local clipToSky = mat4.inverse(cameraToClip * worldToCameraStationary)
		skyFromDirectionShader:send("clipToSky", {mat4.components(clipToSky)})
		love.graphics.draw(dummyTexture, 0, 0, 0, sideSize)
		love.graphics.setCanvas()
		faces[#faces + 1] = faceCanvas:newImageData()
	end
	love.graphics.setShader()
	skybox = love.graphics.newCubeImage(faces)
end

local function updateState(dt)
	local maxAngularSpeed = consts.tau * 2
	local keyboardRotationSpeed = consts.tau / 4
	local keyboardRotationMultiplier = keyboardRotationSpeed / maxAngularSpeed
	local mouseMovementForMaxSpeed = 20
	local rotation = vec3()
	if love.keyboard.isDown("k") then rotation = rotation + consts.rightVector * keyboardRotationMultiplier end
	if love.keyboard.isDown("i") then rotation = rotation - consts.rightVector * keyboardRotationMultiplier end
	if love.keyboard.isDown("l") then rotation = rotation + consts.upVector * keyboardRotationMultiplier end
	if love.keyboard.isDown("j") then rotation = rotation - consts.upVector * keyboardRotationMultiplier end
	if love.keyboard.isDown("u") then rotation = rotation + consts.forwardVector * keyboardRotationMultiplier end
	if love.keyboard.isDown("o") then rotation = rotation - consts.forwardVector * keyboardRotationMultiplier end
	rotation = rotation + consts.upVector * mouseDx / mouseMovementForMaxSpeed
	rotation = rotation + consts.rightVector * mouseDy / mouseMovementForMaxSpeed
	camera.orientation = quat.normalise(camera.orientation * quat.fromAxisAngle(limitVectorLength(rotation, 1) * maxAngularSpeed * dt))
end

function love.update(dt)
	if not love.window.hasFocus() then
		love.mouse.setRelativeMode(false)
	end
	if not (mouseDx and mouseDy) or love.mouse.getRelativeMode() == false then
		mouseDx = 0
		mouseDy = 0
	end

	updateState(dt)

	mouseDx, mouseDy = nil, nil
end

function love.draw()
	local worldToCameraStationary = mat4.camera(vec3(), camera.orientation)
	local cameraToClip = mat4.perspectiveLeftHanded(
		outputCanvas:getWidth() / outputCanvas:getHeight(),
		camera.verticalFOV,
		consts.farPlaneDistance,
		consts.nearPlaneDistance
	)
	local clipToSky = mat4.inverse(cameraToClip * worldToCameraStationary)

	love.graphics.setDepthMode("lequal", true)
	love.graphics.setCanvas({outputCanvas, depth = true})
	love.graphics.clear()

	if love.keyboard.isDown("space") then
		love.graphics.setShader(skyFromDirectionShader)
		skyFromDirectionShader:send("clipToSky", {mat4.components(clipToSky)})
		love.graphics.draw(dummyTexture, 0, 0, 0, outputCanvas:getDimensions())
		love.graphics.setShader()
	else
		love.graphics.setShader(skyFromMapShader)
		skyFromMapShader:send("clipToSky", {mat4.components(clipToSky)})
		skyFromMapShader:send("skybox", skybox)
		love.graphics.draw(dummyTexture, 0, 0, 0, outputCanvas:getDimensions())
		love.graphics.setShader()
	end

	love.graphics.setDepthMode("always", false)
	love.graphics.setShader()
	love.graphics.setCanvas()
	love.graphics.draw(outputCanvas, 0, love.graphics.getHeight(), 0, 1, -1)
end
