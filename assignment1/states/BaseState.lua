
--implements empty methods
BaseState = Class{}

--can put whatever you want here
--just for avoiding a lot of boilerplate code

function BaseState:init() end
function BaseState:enter() end
function BaseState:exit() end
function BaseState:update(dt) end
function BaseState:render() end