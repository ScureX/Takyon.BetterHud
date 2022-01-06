global function betterhudPrecache

struct{
    bool usesMetric = true //true: uses kph; false: uses mph
    bool colorFade = true // true: text color is red when you are slow and green when you are fast; false: static color which you can set below
    vector position = Vector(0.4, 0.55, 0.0) //x axis: 0.0 is max left, 1.0 is max right; y axis: 0.0 is max top, 1.0 is max down; z doesn't do anything
    vector colour = Vector(1.0, 0.55, 0.0) //standard rgb format, range: min - 0.0 to max - 1.0
    float alpha = 0.9 //maxiumum alpha of the text, range: 0.0 to 1.0
    float size = 50.0 //size of the text
} settingsSpeedometer

struct{
    bool colorFade = true // true: text color is red when you are slow and green when you are fast; false: static color which you can set below
    vector position = Vector(0.525, 0.55, 0.0) //x axis: 0.0 is max left, 1.0 is max right; y axis: 0.0 is max top, 1.0 is max down; z doesn't do anything
    // For some reason ammo position is only 1/4th as far from the center as speedometer position. keep this in mind when aligning 

    vector colour = Vector(1.0, 0.55, 0.0) //standard rgb format, range: min - 0.0 to max - 1.0
    float alpha = 0.9 //maxiumum alpha of the text, range: 0.0 to 1.0
    float size = 50.0 //size of the text
} settingsAmmocounter

void function betterhudPrecache(){
    thread betterhudInit()
}

void function betterhudInit(){
    WaitFrame()
    // Speedometer
    var speedRui = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", clGlobal.topoCockpitHudPermanent, RUI_DRAW_COCKPIT, -1 )
    RuiSetInt(speedRui, "maxLines", 1)
	RuiSetInt(speedRui, "lineNum", 1)
	RuiSetFloat2(speedRui, "msgPos", settingsSpeedometer.position)
	RuiSetString(speedRui, "msgText", "speed")
	RuiSetFloat(speedRui, "msgFontSize", settingsSpeedometer.size)
	RuiSetFloat(speedRui, "msgAlpha", settingsSpeedometer.alpha)
	RuiSetFloat(speedRui, "thicken", 0.0)
	RuiSetFloat3(speedRui, "msgColor", settingsSpeedometer.colour)
    
    // Ammocounter
    var ammoRui = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", clGlobal.topoCockpitHudPermanent, RUI_DRAW_COCKPIT, -1 )
    RuiSetInt(ammoRui, "maxLines", 1)
	RuiSetInt(ammoRui, "lineNum", 1)
	RuiSetFloat2(ammoRui, "msgPos", settingsAmmocounter.position)
	RuiSetString(ammoRui, "msgText", "ammo")
	RuiSetFloat(ammoRui, "msgFontSize", settingsAmmocounter.size)
	RuiSetFloat(ammoRui, "msgAlpha", settingsAmmocounter.alpha)
	RuiSetFloat(ammoRui, "thicken", 0.0)
	RuiSetFloat3(ammoRui, "msgColor", settingsAmmocounter.colour)

    thread betterhudMain(speedRui, ammoRui)
}

void function betterhudMain(var speedRui, var ammoRui){
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
                continue
            } else{
                setAlpha(speedRui, settingsSpeedometer.alpha)
                setAlpha(ammoRui, settingsAmmocounter.alpha)
            }

            /*  Speedometer  */
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

            /*  Ammo counter  */
            entity activeWeapon = player.GetActiveWeapon()
            if (!IsValid(activeWeapon))
                continue

            entity owner = activeWeapon.GetWeaponOwner()
            float zoomFrac = owner.GetZoomFrac() // 0 = zoomed out, anything above is zoomed in
            // sets alpha based on zoom factor
            if(zoomFrac > 0){
                setAlpha(speedRui, settingsSpeedometer.alpha * (1 - zoomFrac))
                setAlpha(ammoRui, settingsAmmocounter.alpha * (1 - zoomFrac))
            }

            // debug
            printl("type: " + activeWeapon.GetWeaponType())
            

            float currAmmo
            float maxAmmo

            // ammo color change
            if( activeWeapon.GetWeaponPrimaryClipCount() == 0 && activeWeapon.GetWeaponPrimaryClipCountMax() == 0){ // is chargeable
                // THIS DOESNT WORK BEACUSE BOTH METHODS RETURN 0
                //currAmmo = float(activeWeapon.GetWeaponChargeLevel())
                //maxAmmo = float(activeWeapon.GetWeaponChargeLevelMax())
                //printl("CHARGE WEAPON")
                //printl("curr chrg: " + activeWeapon.GetWeaponChargeLevel())
                //printl("max chrg: " + activeWeapon.GetWeaponChargeLevelMax())
                //RuiSetFloat3(ammoRui, "msgColor", Vector(1.0 - (currAmmo/maxAmmo) , currAmmo/maxAmmo, 0.0)) 

                setAlpha(ammoRui) // hide whem chargerifle till fixed
            }
            else{ // has bullets
                printl("NORMAL WEAPON")
                currAmmo = float(activeWeapon.GetWeaponPrimaryClipCount())
                maxAmmo = float(activeWeapon.GetWeaponPrimaryClipCountMax())
                RuiSetFloat3(ammoRui, "msgColor", Vector(1.0 - (currAmmo/maxAmmo) , currAmmo/maxAmmo, 0.0)) 
            }
            
            string ammoCountStr = currAmmo + " / " + maxAmmo
            // draw ammo count
            RuiSetString(ammoRui, "msgText", ammoCountStr)
            
            
            /* Healt bar */
            //TODO
            // GetMaxHealth()
            // GetHealthFrac(player)

        }
        else{
            setAlpha(speedRui)
            setAlpha(ammoRui)
        }
    }
}

void function setAlpha(var rui, float alpha = 0.0){
    RuiSetFloat(rui, "msgAlpha", alpha)
}