-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local tilegap = require("tilegap")
local outtergap = require("outtergap")
local vicious = require("vicious")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
-- beautiful.init("/usr/share/awesome/themes/zenburn/theme.lua")
beautiful.init("/home/quasar/.config/awesome/themes/dark1/theme.lua")

-- This is used later as the default terminal and editor to run.
-- terminal = "urxvt -e bash -c \"tmux -q has-session -t work && exec tmux attach-session -t work || exec tmux new-session -s work\""
-- terminal = "urxvt -e bash -c \"exec tmux new-session\""
-- terminal = "sakura -e '.dotfiles/bin/sakura_launch_tmux.sh'"
-- letterSpacing -1 added to correct issue Infinality font patches caused with kerning on this font
-- terminal = "urxvt -fn \"xft:DeJa Vu Sans Mono for Powerline:pixelsize=20\" -letterSpacing -1 -e '.dotfiles/bin/sakura_launch_tmux.sh'"
terminal = "st -e tmux"
editor = os.getenv("EDITOR") or "gvim"
-- editor_cmd = terminal .. " -e " .. editor
editor_cmd = editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4" -- Windows Key


-- naughty.notify({ title = "test", text = "testing naughty"})

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{

    awful.layout.suit.tile.bottom,
    awful.layout.suit.floating,
    outtergap.bottom,

    awful.layout.suit.tile.top,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,

    tilegap,
    tilegap.left,
    tilegap.bottom,
    tilegap.top

    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
-- tags = {
--     names  = { "main", "pro", "chrome", "ff", "other" },
--     layout = { layouts[2], layouts[4], layouts[14], layouts[14], layouts[1] } 
-- }
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 0 }, s, layouts[1])
    -- tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
mymainmenu = awful.menu({
   { "edit config", editor_cmd .. " " .. awesome.conffile, beautiful.awesome_icon },
   { "open terminal", terminal },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
})

-- mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
--                                      menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
-- mytextclock = awful.widget.textclock(" %a %b %d, %H:%M test")
-- mytextclock = awful.widget.textclock(" %Y-%m-%d, %l:%M %p ")

-- For unknown reasons, the version of Awesome that ships with Arch
-- does not understand %l (12-hour hour). Need to investigate.
-- Figured it out - turns out %l is not understood by Lua, and Fedora
-- had been using a patch to their Lua that added this in.
--
-- Second parameter is how often to update the clock (in seconds)
mytextclock = awful.widget.textclock(" %Y-%m-%d, %I:%M %p ", 1)

-- MPD Display
-- some vicious widgets
mpdwidget = wibox.widget.textbox()
-- Register widget
vicious.register(mpdwidget, vicious.widgets.mpd,
    function (mpdwidget, args)
        if args["{state}"] == "Stop" then 
            return " - "
        else 
            return args["{Artist}"]..' - '.. args["{Title}"]
        end
    end, 10)

-- CPU Usage Graph
-- Initialize widget
cpuwidget = awful.widget.graph()
-- Graph properties
cpuwidget:set_width(50)
cpuwidget:set_background_color("#494B4F")
cpuwidget:set_color({ type = "linear", from = { 0, 0 }, to = { 10,0 }, stops = { {0, "#FF5656"}, {0.5, "#88A175"}, 
                    {1, "#AECF96" }}})
-- Register widget
vicious.register(cpuwidget, vicious.widgets.cpu, "$1")



-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    -- left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(mpdwidget)
    right_layout:add(cpuwidget)
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(mytextclock)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( -2.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end),

   -- Multimedia keys
   -- These audio settings require PulseAudio and pamixer.
    awful.key({ }, "XF86AudioRaiseVolume", function () awful.util.spawn_with_shell("volume_up") end),
    awful.key({ }, "XF86AudioLowerVolume", function () awful.util.spawn_with_shell("volume_down") end),
    awful.key({ }, "XF86AudioMute", function () awful.util.spawn_with_shell("volume_toggle_mute") end),

    -- awful.key({ }, "XF86AudioPlay", function () awful.util.spawn_with_shell("mpc toggle") end),
    -- awful.key({ }, "XF86AudioStop", function () awful.util.spawn_with_shell("mpc stop") end),
    -- awful.key({ }, "XF86AudioPrev", function () awful.util.spawn_with_shell("mpc prev") end),
    -- awful.key({ }, "XF86AudioNext", function () awful.util.spawn_with_shell("mpc next") end),
      
    -- specific layouts, mapped to media keys (or layer1-arrowkeys on Model M)
    awful.key({ }, "XF86AudioPlay", function () awful.layout.set(awful.layout.suit.tile.bottom) end),
    awful.key({ }, "XF86AudioStop", function () awful.layout.set(awful.layout.suit.tile.top) end),
    awful.key({ }, "XF86AudioPrev", function () awful.layout.set(awful.layout.suit.floating) end),
    awful.key({ }, "XF86AudioNext", function () awful.layout.set(outtergap.bottom) end),

    -- screen lock, and other launchers. For Model M F1, mapped to the left hand key block
    -- Current key map from the Model M, left hand EXTRA_ keys:
    -- 
    --             Key Codes                       Mapped To (below)
    --     |--------------|--------------|    |--------------|--------------|
    --   1 | XF86Favorites| Tilde        |    | restore hist | Tilde        |
    --     |--------------|--------------|    |--------------|--------------|
    --   2 | XF86Mail     | XF86Explorer |    | slock        | keepass2     |
    --     |--------------|--------------|    |--------------|--------------|
    --   3 | XF86Search   | XF86HomePage |    | focus scrn 1 | focus scrn 2 |
    --     |--------------|--------------|    |--------------|--------------|
    --   4 | XF86Back     | XF86Forward  |    | urxvt        | ???          |
    --     |--------------|--------------|    |--------------|--------------|
    --   5 | Cancel       | XF86Reload   |    | ???          | ???          |
    --     |--------------|--------------|    |--------------|--------------|

    -- Row 1 --
    -- no mappings here, all done via firmware on keyboard
    awful.key({ }, "XF86Favorites", awful.tag.history.restore),

    -- Row 2 --
    awful.key({ }, "XF86Mail", function () awful.util.spawn("slock")    end),
    awful.key({ }, "XF86Explorer", function () awful.util.spawn("keepassx /home/quasar/Dropbox/KeyPass_Database.kdbx") end),

    -- Row 3 --
    awful.key({ }, "XF86Search", function () awful.screen.focus(1) end),
    awful.key({ }, "XF86HomePage", function () awful.screen.focus(2) end),


    -- Row 4 --
    awful.key({ }, "XF86Back", function () awful.util.spawn("urxvt") end),
    
    -- Row 5 --
    -- nothing yet


    -- other mappings
    awful.key({ }, "XF86Calculator", function () awful.util.spawn("galculator") end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    -- added for Model M
    awful.key({                   }, "XF86Reload",      function (c) c:kill()                         end),

    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- F13 - F20 mapped to tags (for Model M, or BlackWidow)
globalkeys = awful.util.table.join(globalkeys,
    awful.key({}, "#191", function()
        local screen = mouse.screen
        local tag = awful.tag.gettags(screen)[1]
        if tag then
            awful.tag.viewonly(tag)
        end
    end),
    awful.key({}, "#192", function()
        local screen = mouse.screen
        local tag = awful.tag.gettags(screen)[2]
        if tag then
            awful.tag.viewonly(tag)
        end
    end),
    awful.key({}, "#193", function()
        local screen = mouse.screen
        local tag = awful.tag.gettags(screen)[3]
        if tag then
            awful.tag.viewonly(tag)
        end
    end),
    awful.key({}, "#194", function()
        local screen = mouse.screen
        local tag = awful.tag.gettags(screen)[4]
        if tag then
            awful.tag.viewonly(tag)
        end
    end),
    awful.key({}, "#195", function()
        local screen = mouse.screen
        local tag = awful.tag.gettags(screen)[5]
        if tag then
            awful.tag.viewonly(tag)
        end
    end),
    awful.key({}, "#196", function()
        local screen = mouse.screen
        local tag = awful.tag.gettags(screen)[6]
        if tag then
            awful.tag.viewonly(tag)
        end
    end),
    awful.key({}, "#197", function()
        local screen = mouse.screen
        local tag = awful.tag.gettags(screen)[7]
        if tag then
            awful.tag.viewonly(tag)
        end
    end),
    awful.key({}, "#198", function()
        local screen = mouse.screen
        local tag = awful.tag.gettags(screen)[8]
        if tag then
            awful.tag.viewonly(tag)
        end
    end)
)

-- Bind F1-F5 to the first five tags for quick switching
-- for i = 1, 5 do
--     globalkeys = awful.util.table.join(globalkeys,
--         awful.key({}, "F" .. i, function()
--             local screen = mouse.screen
--             local tag = awful.tag.gettags(screen)[i]
--             if tag then
--                 awful.tag.viewonly(tag)
--             end
--         end)
--     )
-- end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag then
                          awful.client.movetotag(tag)
                     end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag then
                          awful.client.toggletag(tag)
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     -- would like to set this to false, but
                     -- gvim misbehaves and draws giant ugly
                     -- borders
                     -- well, I was able to fix that with a custom rule
                     -- in my gtk-2 theme. Don't forget that!
                     size_hints_honor = false } },

    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "Galculator" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },

    -- float feh, and center it
    { rule = { instance = "feh" },
      properties = { floating = true },
      callback = function (c)
          awful.placement.centered(c, nil)
      end
    },
    { rule = { class = "Pidgin" },
      properties = { floating = true,
                     width = 250,
                     height = 400,
                     ontop = true } },
    { rule = { class = "Keepassx" },
      properties = { floating = true,
                     ontop = true } },
    -- match Google Hangouts windows
    { rule = { class = "Google-chrome", role = "pop-up" },
      properties = { floating = true,
                     width = 250,
                     height = 400, 
                     ontop = true } },
    -- in case we're using the unstable branch of chrome...
    { rule = { class = "Google-chrome-unstable", role = "pop-up" },
      properties = { floating = true,
                     width = 250,
                     height = 400, 
                     ontop = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

-- naughty settings
-- naughty.config.presets.normal.timeout          = 20
-- naughty.config.presets.normal.screen           = 1
-- there is no top_center unless the files are patched
--naughty.config.presets.normal.position         = "top_center"
-- naughty.config.presets.normal.margin           = 4
-- naughty.config.presets.normal.height           = 300
-- naughty.config.presets.normal.width            = 1600
naughty.config.presets.normal.gap              = 10
naughty.config.presets.normal.ontop            = true
naughty.config.presets.normal.font             = "DejaVu Sans 16"
-- naughty.config.presets.normal.icon             = nil
-- naughty.config.presets.normal.icon_size        = 16
-- naughty.config.presets.normal.fg               = beautiful.fg_focus or '#ffffff'
-- naughty.config.presets.normal.bg               = beautiful.bg_focus or '#535d6c'
naughty.config.presets.normal.border_color     = beautiful.border_focus or '#535d6c'
naughty.config.presets.normal.border_width     = 5
-- naughty.config.default_preset.hover_timeout    = nil

-- autostart
awful.util.spawn_with_shell("dex_run_once")
--awful.util.spawn_with_shell("dex -e Awesome -a")

-- special script to delay until after pulseaudio is loaded
-- awful.util.spawn("delay_volumeicon")


client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
