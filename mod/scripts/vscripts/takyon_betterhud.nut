global function betterhudPrecache

struct{
    bool usesMetric = true //true: uses kph; false: uses mph
    bool colorFade = true // true: text color is red when you are slow and green when you are fast; false: static color which you can set below
    vector position = Vector(0.0, 0.5, 0.0) //x axis: 0.0 is max left, 1.0 is max right; y axis: 0.0 is max top, 1.0 is max down; z doesn't do anything
    vector color = Vector(1.0, 0.55, 0.0) //standard rgb format, range: min - 0.0 to max - 1.0
    float alpha = 0.9 //maxiumum alpha of the text, range: 0.0 to 1.0
    float size = 250.0 //size of the text
} settingsSpeedometer

struct{
    bool colorFade = true // true: text color is red when you are slow and green when you are fast; false: static color which you can set below
    vector position = Vector(0.5, 0.5, 0.0) //x axis: 0.0 is max left, 1.0 is max right; y axis: 0.0 is max top, 1.0 is max down; z doesn't do anything
    // For some reason ammo position is only 1/4th as far from the center as speedometer position. keep this in mind when aligning 
    vector color = Vector(1.0, 0.55, 0.0) //standard rgb format, range: min - 0.0 to max - 1.0
    float alpha = 0.9 //maxiumum alpha of the text, range: 0.0 to 1.0
    float size = 250.0 //size of the text
} settingsAmmocounter

struct{
    vector color = Vector(0.5, 0.5, 0.5) // Color of hud (the square background)
    float alpha = 0.13 // opacity of hud
} settingsHud

void function betterhudPrecache(){
    thread betterhudInit()
}

void function betterhudInit(){
    WaitFrame()

    // Hud
    float scale = 0.3
    var customTopoS = RuiTopology_CreateSphere( 
        COCKPIT_RUI_OFFSET - <0, -39, 20>, // POSITION | in screen, left/right, up/down
        <0, -1, 0>, // ?, ?, left side down right side up
        <0, -0.15, -1>, // ?, bottom left top right, ?
        COCKPIT_RUI_RADIUS, 
        COCKPIT_RUI_WIDTH*scale, 
        COCKPIT_RUI_HEIGHT*(scale/2), 
        COCKPIT_RUI_SUBDIV*8 
    )
    var hudRui = RuiCreate( $"ui/basic_image.rpak", customTopoS, RUI_DRAW_COCKPIT, 8 )
    hudInit(hudRui)

    // Speedometer
    var speedRui = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", customTopoS, RUI_DRAW_COCKPIT, 9 )
    speedometerInit(speedRui)
    
    // Ammocounter
    var ammoRui = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", customTopoS, RUI_DRAW_COCKPIT, 9 )
    ammoCounterInit(ammoRui)

    thread betterhudMain(speedRui, ammoRui, hudRui)
}

void function hudInit(var hudRui){
    RuiSetFloat3( hudRui, "basicImageColor", settingsHud.color) 
    RuiSetFloat( hudRui, "basicImageAlpha", settingsHud.alpha)
}

void function speedometerInit(var speedRui){
    RuiSetInt(speedRui, "maxLines", 1)
	RuiSetInt(speedRui, "lineNum", 1)
	RuiSetFloat2(speedRui, "msgPos", settingsSpeedometer.position)
	RuiSetString(speedRui, "msgText", "speed")
	RuiSetFloat(speedRui, "msgFontSize", settingsSpeedometer.size)
	RuiSetFloat(speedRui, "msgAlpha", settingsSpeedometer.alpha)
	RuiSetFloat(speedRui, "thicken", 0.0)
	RuiSetFloat3(speedRui, "msgColor", settingsSpeedometer.color)
}

void function ammoCounterInit(var ammoRui){
    RuiSetInt(ammoRui, "maxLines", 1)
	RuiSetInt(ammoRui, "lineNum", 1)
	RuiSetFloat2(ammoRui, "msgPos", settingsAmmocounter.position)
	RuiSetString(ammoRui, "msgText", "ammo")
	RuiSetFloat(ammoRui, "msgFontSize", settingsAmmocounter.size)
	RuiSetFloat(ammoRui, "msgAlpha", settingsAmmocounter.alpha)
	RuiSetFloat(ammoRui, "thicken", 0.0)
	RuiSetFloat3(ammoRui, "msgColor", settingsAmmocounter.color)
}

void function betterhudMain(var speedRui, var ammoRui, var hudRui){
    while(true){
        WaitFrame()
        if(!IsLobby()){
            entity player = GetLocalViewPlayer()
            if (player == null || !IsValid(player))
			    continue
            
            // hide if dead
            if(!IsAlive(player)){
                setAlpha(speedRui)
                setAlpha(ammoRui)
                RuiSetFloat(hudRui, "basicImageAlpha", 0.0)
                continue
            } else{
                setAlpha(speedRui, settingsSpeedometer.alpha)
                setAlpha(ammoRui, settingsAmmocounter.alpha)
                RuiSetFloat(hudRui, "basicImageAlpha", settingsHud.alpha)
            }

            /*  
            Speedometer  
            */
            vector playerVelV = player.GetVelocity()
            float playerVel = sqrt(playerVelV.x * playerVelV.x + playerVelV.y * playerVelV.y)
            float playerVelNormal = playerVel * 0.068544
            string playerVelStr = format("%3i", playerVelNormal)
            if(settingsSpeedometer.usesMetric)
                playerVelStr += "kph"
            else
                playerVelStr += "mph"

            if(settingsSpeedometer.colorFade){
                // change color based on speed
                // To set the speed at which it should be fully green change greenSpeed.
                int greenSpeed = 43     // speed at which color is fully green. Use KPH if you have metric enabled. Otherwise use MPH
                if(settingsSpeedometer.usesMetric)
                    RuiSetFloat3(speedRui, "msgColor", Vector(1.0 - playerVel/(greenSpeed * 20), playerVel/(greenSpeed * 20), 0.0))
                else
                    RuiSetFloat3(speedRui, "msgColor", Vector(1.0 - (playerVel / 1.609344)/((greenSpeed / 1.609344) * 20), (playerVel / 1.609344)/((greenSpeed / 1.609344) * 20), 0.0))
            }
            // draw Speedometer
            RuiSetString(speedRui, "msgText", playerVelStr)

            /*  
            Ammo counter  
            */
            entity activeWeapon = player.GetActiveWeapon()
            if (!IsValid(activeWeapon))
                continue

            entity owner = activeWeapon.GetWeaponOwner()
            float zoomFrac = owner.GetZoomFrac() // 0 = zoomed out, anything above is zoomed in
            // sets alpha based on zoom factor: while ads you dont see the hud
            if(zoomFrac > 0){
                setAlpha(speedRui, settingsSpeedometer.alpha * (1 - zoomFrac))
                setAlpha(ammoRui, settingsAmmocounter.alpha * (1 - zoomFrac))
                RuiSetFloat(hudRui, "basicImageAlpha", settingsHud.alpha * (1 - zoomFrac))
            }

            float currAmmo
            float maxAmmo
            string ammoCountStr

            // ammo color change
            if( activeWeapon.IsChargeWeapon()){ // is chargeable
                currAmmo = activeWeapon.GetWeaponChargeFraction()
                maxAmmo = 1.0
                RuiSetFloat3(ammoRui, "msgColor", Vector(1.0 - (currAmmo/maxAmmo) , currAmmo/maxAmmo, 0.0)) 
                ammoCountStr =  int(currAmmo*100) + "%"
            }
            else if(activeWeapon.GetWeaponPrimaryClipCountMax() > 0){ // is bullet // BAD FIX TODO
                currAmmo = float(activeWeapon.GetWeaponPrimaryClipCount())
                maxAmmo = float(activeWeapon.GetWeaponPrimaryClipCountMax())
                RuiSetFloat3(ammoRui, "msgColor", Vector(1.0 - (currAmmo/maxAmmo) , currAmmo/maxAmmo, 0.0)) 
                ammoCountStr = currAmmo + " / " + maxAmmo
            }
            else { // melee
                ammoCountStr = "MELEE"
            }
            // draw ammo count
            RuiSetString(ammoRui, "msgText", ammoCountStr)
            
            
            /* 
            Healt bar 
            */
            //TODO
            // GetMaxHealth()
            // GetHealthFrac(player)

        }
        else{
            setAlpha(speedRui)
            setAlpha(ammoRui)
            RuiSetFloat(hudRui, "basicImageAlpha", 0.0)
        }
    }
}

void function setAlpha(var rui, float alpha = 0.0){
    RuiSetFloat(rui, "msgAlpha", alpha)
}