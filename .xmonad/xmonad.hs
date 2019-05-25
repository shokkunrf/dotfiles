--
-- import
--
import System.Exit                     -- Quit xmonad
import System.IO                       -- for xmobar
import Control.Monad (liftM2)          -- myManageHookShift
import XMonad
import XMonad.Actions.CycleWS          -- add action for prevWS and nextWS
import XMonad.Hooks.DynamicLog         -- for xmobar
import XMonad.Hooks.ManageDocks        -- avoid xmobar area
import XMonad.Hooks.EwmhDesktops       -- full screen event
import XMonad.Layout
import XMonad.Layout.Spacing           -- this makes smart space around windows
import XMonad.Layout.Simplest           
import XMonad.Layout.TwoPane          
import XMonad.Layout.ThreeColumns      -- for many windows
import XMonad.Layout.Magnifier         -- this makes window bigger
import XMonad.Layout.ResizableTile     -- Resizable Horizontal border
import XMonad.Layout.DragPane          -- see only two window
import XMonad.Layout.ToggleLayouts     -- Full window at any time
import XMonad.Layout.NoBorders         -- In Full mode, border is no use
import XMonad.Layout.Gaps
import XMonad.Util.EZConfig            -- removeKeys, additionalKeys
import XMonad.Util.Run(spawnPipe)      -- spawnPipe, hPutStrLn
import XMonad.Util.NamedScratchpad     -- Float window location
import qualified XMonad.StackSet as W  -- myManageHookShift
import XMonad.Layout.IndependentScreens(countScreens)

-- 
-- variables
-- var:otherVariable, wid:width, pth:path, col:color, app:application
--
varTerm       = "urxvt"
varModm       = mod4Mask -- Win key or Super_L
varBar        = "xmobar ~/.xmonad/.xmobarrc"
varWorkspaces = ["1","2","3","4","5"]
widBorder     = 2
widGap        = 3
widEdge       = -widGap
pthWallpaper  = "~/Pictures/wallpaper/*"
colBorder     = "#81daf5"
colFocused    = "#2e64fe"
appFloatClass = ["Nautilus","Gimp"]
appFloatTitle = ["Event Tester"]

--
-- function
--
-- startup
myStartupHook = do
    spawn $ "feh --recursive --randomize --bg-fill " ++ pthWallpaper

-- layout
myLayoutHook = avoidStruts $ toggleLayouts (noBorders Full) $ myLayout
myLayout = spacing widGap  $ gaps [(U,widEdge),(D,widEdge),(L,widEdge),(R,widEdge)]
    $ first ||| second ||| third
        where
            first  = Tall 1 (1/100) (1/2)
            second = Full
            third  = ThreeCol 1 (1/100) (1/2)
--	    third  = TwoPane (1/100)(1/2)
--          third  = ResizableTall 0 (3/100) (3/5) []
--          third  = Simplest
--          third  = (dragPane Vertical   (1/10) (1/2))
--          third  = (dragPane Horizontal (1/10) (1/2))

-- new window will created in Float mode
myManageHookFloat = composeAll
    [ className =? "Nautilus"     --> doFloat
    , className =? "Gimp"         --> doFloat
    , title     =? "Event Tester" --> xevFloat
    ]
    where xevFloat = customFloating $ W.RationalRect (1/2) (1/60) (1/16) (1/9)
-- new window shift
myManageHookShift = composeAll
    [ className =? "Gimp" --> mydoShift "3"
    , stringProperty "WM_NAME" =? "Figure 1" --> doShift "5"
    ]
    where mydoShift = doF . liftM2 (.) W.greedyView W.shift
-- statusbar
myLogHook argBars = dynamicLogWithPP $ wsPP
    { ppOutput = hPutStrLnMulti argBars
    }
wsPP = xmobarPP
    { ppCurrent         = xmobarColor "#ff5252" "" . \s -> "◆"
    , ppVisible         = xmobarColor "#ff5252" "" . \s -> "▼"
    , ppHidden          = xmobarColor "#f2411e" "" . \s -> "◇"
    , ppHiddenNoWindows = xmobarColor "#bf360c" "" . \s -> "□"
    , ppUrgent          = xmobarColor "#000000" "#dc1432"
    , ppSep             = " ::: "
    , ppWsSep           = " "
    , ppTitle           = xmobarColor "#41d85c" "" . shorten 50
    , ppLayout          = xmobarColor "#41d85c" ""
			. \layoutName -> (drop 9 layoutName)
    , ppOrder           = \(ws:layout:title:_) -> [layout,ws,title]
    }

-- key bind
removeBind =
    [ "M-<Return>"
    , "M-S-<Return>"
--  , "M-<Space>"
    , "M-<Tab>"
    , "M-q"
    , "M-S-q"
    , "M-S-c"
    , "M-S-p"
    ]
addtionalBind = 
    [ ("M4-<Return>"  , spawn varTerm)
--  , ("M4-<Space>"   , spawn "exe=`dmenu_path | dmenu` && eval \"exec $exe\"")
    , ("M4-<Tab>"   , spawn "exe=`dmenu_path | dmenu` && eval \"exec $exe\"")
--  , ("M4-<Tab>"     , sendMessage NextLayout)
    , ("M4-b"         , sendMessage ToggleStruts)
    -- Move the focus
    , ("M4-<D>"  , windows W.focusDown)
    , ("M4-<U>"  , windows W.focusUp)
    , ("M4-<L>"  , windows W.focusMaster)
    , ("M4-<R>"  , windows W.focusMaster
               <+> windows W.focusUp)
    -- Swap the focused window
    , ("M4-S-<D>"  , windows W.swapDown)
    , ("M4-S-<U>"  , windows W.swapUp)
    , ("M4-S-<L>"  , windows W.shiftMaster)
    , ("M4-S-<R>"  , windows W.shiftMaster
                 <+> windows W.swapUp)
    , ("M4-C-<L>"  , sendMessage (IncMasterN 1)
                 <+> windows W.shiftMaster)
    , ("M4-C-<R>"  , windows W.shiftMaster
                 <+> windows W.swapUp
	         <+> sendMessage (IncMasterN (-1)))
	 
    -- Close the focused window
    , ("M4-S-q" , kill)
    -- Restart xmonad
    , ("M4-`"   , spawn "if type xmonad; then xmonad --recompile && xmonad --restart; else xmessage xmonad not in \\$PATH: \"$PATH\"; fi")
    -- Quit xmonad
    , ("M4-S-`" , io (exitWith ExitSuccess))

     -- workspace
    , ("M4-<Page_Up>"        , prevWS)
    , ("M4-<Page_Down>"      , nextWS)
    , ("M4-S-<Page_Up>"      , shiftToPrev
                           <+> prevWS)
    , ("M4-S-<Page_Down>"    , shiftToNext
                           <+> nextWS)
    , ("M4-C-<Page_Up>"      , prevScreen)
    , ("M4-C-<Page_Down>"    , nextScreen)
    , ("M4-C-S-<Page_Up>"    , shiftPrevScreen
                           <+> prevScreen)
    , ("M4-C-S-<Page_Down>"  , shiftNextScreen
                           <+> nextScreen)
    -- Volume setting media keys
    , ("<XF86AudioRaiseVolume>" , spawn "set-volume up")
    , ("<XF86AudioLowerVolume>" , spawn "set-volume down")
    , ("<XF86AudioMute>"        , spawn "set-volume mute")
    -- TouchPad toggle
    , ("M1-<Space>" , spawn "set-touchpad")
    -- Brightness
    , ("<XF86MonBrightnessUp>" , spawn "set-brightness up")
    , ("<XF86MonBrightnessDown>" , spawn "set-brightness down")
    -- Display lock
    , ("M1-x" , spawn "slock")
    -- Notice window names
    , ("M1-z" , spawn "lsw | xargs -I@ notify-send @")
    ]

--
-- main config
--
main :: IO()
main = do
    numScreens <- countScreens
    wsbars <- mapM xmobarScreen [0 .. (numScreens - 1)]

    xmonad $ ewmh defaultConfig
        { terminal           = varTerm
        , modMask            = varModm
        , borderWidth        = widBorder
        , workspaces         = varWorkspaces
        , normalBorderColor  = colBorder
        , focusedBorderColor = colFocused
        , startupHook        = myStartupHook
        , manageHook         = manageDocks
                           <+> manageHook defaultConfig
		           <+> myManageHookFloat
			   <+> myManageHookShift
        -- statusbar setting
        , logHook            = myLogHook wsbars
        -- any time Full mode, avoid xmobar area
        , layoutHook         = myLayoutHook
        , handleEventHook    = fullscreenEventHook
	                 --  <+> fadeWindowsEventHook
        }
        `removeKeysP` removeBind
        `additionalKeysP` addtionalBind

xmobarScreen :: Int -> IO Handle
xmobarScreen = spawnPipe . ("xmobar ~/.xmonad/.xmobarrc -x " ++) . show

hPutStrLnMulti :: [Handle] -> String -> IO ()
hPutStrLnMulti handles string = mapM_ (`hPutStrLn` string) handles
