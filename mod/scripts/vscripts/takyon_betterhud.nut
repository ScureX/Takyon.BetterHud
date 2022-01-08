global function betterhudPrecache

/*
 *  SETTINGS
 */

struct{
    bool usesMetric = true //true: uses kph; false: uses mph
    bool colorFade = true // true: text color is red when you are slow and green when you are fast; false: static color which you can set below
    vector position = Vector(0 - 0.03, 0.5, 0.0) //x axis: 0.0 is max left, 1.0 is max right; y axis: 0.0 is max top, 1.0 is max down; z doesn't do anything
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
    vector position = Vector(0.04, 0 - 0.05, 0.0) //x axis: 0.0 is max left, 1.0 is max right; y axis: 0.0 is max top, 1.0 is max down; z doesn't do anything
    vector color = Vector(1.0, 1.0, 1.0) //standard rgb format, range: min - 0.0 to max - 1.0
    float alpha = 0.9 //maxiumum alpha of the text, range: 0.0 to 1.0
    float size = 150.0 //size of the text
} settingsWeaponName

struct{
    vector color = Vector(0.5, 0.5, 0.5) // Color of hud (the square background) 
    float alpha = 0.13 // opacity of hud
    float horizontal = 0.0
    float vertical = 0.0
    float transformHorizontal = -0.15
    float transformVertical = 0
    float positionHorizontal = -39
    float positionVertical = 20
    float hudScale = 0.3
} settingsHud

struct{
    vector color = Vector(0.23, 0.23, 0.23) // Color of hud (the square background) make this a bit darker than in settingsHud
    float alpha = 0.20 // opacity of hud
    float horizontal = 0.0
    float vertical = 0.0
    float transformHorizontal = -0.15
    float transformVertical = 0
    float positionHorizontal = -39.8
    float positionVertical = 14.0
    float nameHudScale = 0.045
} settingsNameHud

void function betterhudPrecache(){
    thread betterhudInit()
}

/*
 *  MAIN INITIALIZE FUNCTION
 */

void function betterhudInit(){
    WaitFrame()

    // Hud // the big square that acts as background
    var hudTopo = RuiTopology_CreateSphere( 
        COCKPIT_RUI_OFFSET - <0, settingsHud.positionHorizontal, settingsHud.positionVertical>, // POSITION | in screen, left/right, up/down
        <0, -1, settingsHud.transformVertical>, // ?, ?, left side down right side up
        <0, settingsHud.transformHorizontal, -1>, // ?, bottom left top right, ?
        COCKPIT_RUI_RADIUS, 
        COCKPIT_RUI_WIDTH*settingsHud.hudScale, 
        COCKPIT_RUI_HEIGHT*(settingsHud.hudScale/2), 
        COCKPIT_RUI_SUBDIV*8 
    )
    var hudRui = RuiCreate( $"ui/basic_image.rpak", hudTopo, RUI_DRAW_COCKPIT, 7 )
    hudInit(hudRui)

    // nameHud // The little box around the weapon name
    var nameHudTopo = RuiTopology_CreateSphere( 
        COCKPIT_RUI_OFFSET - <0.0, settingsNameHud.positionHorizontal, settingsNameHud.positionVertical>, // POSITION | in screen, left/right, up/down
        <0, -1, settingsNameHud.transformVertical>, // ?, ?, left side down right side up
        <0, settingsNameHud.transformHorizontal, -1>, // ?, bottom left top right, ?
        COCKPIT_RUI_RADIUS, 
        COCKPIT_RUI_WIDTH*settingsHud.hudScale, // taking settingshud and not settingsNameHud so it has the same width
        COCKPIT_RUI_HEIGHT*(settingsNameHud.nameHudScale), 
        COCKPIT_RUI_SUBDIV*8 
    )
    var nameHudRui = RuiCreate( $"ui/basic_image.rpak", nameHudTopo, RUI_DRAW_COCKPIT, 8 )
    nameHudInit(nameHudRui)

    // Text topology // this is so the text isnt slanted. if you want slanted text change the textTopo to hudTopo when creating rui below
    var textTopo = RuiTopology_CreateSphere( 
        COCKPIT_RUI_OFFSET - <0, settingsHud.positionHorizontal, settingsHud.positionVertical>, // POSITION | in screen, left/right, up/down
        <0, -1, 0>, // ?, ?, left side down right side up
        <0, 0, -1>, // ?, bottom left top right, ?
        COCKPIT_RUI_RADIUS, 
        COCKPIT_RUI_WIDTH*settingsHud.hudScale, 
        COCKPIT_RUI_HEIGHT*(settingsHud.hudScale/2), 
        COCKPIT_RUI_SUBDIV*8 
    )

    // Speedometer
    var speedRui = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", hudTopo, RUI_DRAW_COCKPIT, 9 )
    speedometerInit(speedRui)
    
    // Ammocounter
    var ammoRui = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", hudTopo, RUI_DRAW_COCKPIT, 9 )
    ammoCounterInit(ammoRui)

    // WeaponName
    var weaponNameRui = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", hudTopo, RUI_DRAW_COCKPIT, 9 )
    weaponNameInit(weaponNameRui)

    thread betterhudMain(speedRui, ammoRui, hudRui, weaponNameRui, nameHudRui)
}

/*
 *  INITIALIZE UI
 */

void function hudInit(var hudRui){
    RuiSetFloat3( hudRui, "basicImageColor", settingsHud.color) 
    RuiSetFloat( hudRui, "basicImageAlpha", settingsHud.alpha)
}

void function nameHudInit(var nameHudRui){
    RuiSetFloat3( nameHudRui, "basicImageColor", settingsNameHud.color) 
    RuiSetFloat( nameHudRui, "basicImageAlpha", settingsNameHud.alpha)
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

void function weaponNameInit(var weaponNameRui){
    RuiSetInt(weaponNameRui, "maxLines", 1)
	RuiSetInt(weaponNameRui, "lineNum", 1)
	RuiSetFloat2(weaponNameRui, "msgPos", settingsWeaponName.position)
	RuiSetString(weaponNameRui, "msgText", "name")
	RuiSetFloat(weaponNameRui, "msgFontSize", settingsWeaponName.size)
	RuiSetFloat(weaponNameRui, "msgAlpha", settingsWeaponName.alpha)
	RuiSetFloat(weaponNameRui, "thicken", 0.0)
	RuiSetFloat3(weaponNameRui, "msgColor", settingsWeaponName.color)
}

/*
 *  MAIN FUNCTION LOOP
 */

void function betterhudMain(var speedRui, var ammoRui, var hudRui, var weaponNameRui, var nameHudRui){
    while(true){
        WaitFrame()
        if(!IsLobby()){
            entity player = GetLocalViewPlayer()
            if (player == null || !IsValid(player))
			    continue
            
            // hide if dead or in dropship
            bool playerInDropship
            if(player.GetParent() != null){
                playerInDropship = IsDropship(player.GetParent())
            }
            else {
                playerInDropship = false
            }

            if(!IsAlive(player) || playerInDropship){
                setAlpha(speedRui)
                setAlpha(ammoRui)
                setAlpha(weaponNameRui)
                RuiSetFloat(hudRui, "basicImageAlpha", 0.0)
                RuiSetFloat(nameHudRui, "basicImageAlpha", 0.0)
                continue
            } else{
                setAlpha(speedRui, settingsSpeedometer.alpha)
                setAlpha(ammoRui, settingsAmmocounter.alpha)
                setAlpha(weaponNameRui, settingsWeaponName.alpha)
                RuiSetFloat(hudRui, "basicImageAlpha", settingsHud.alpha)
                RuiSetFloat(nameHudRui, "basicImageAlpha", settingsNameHud.alpha)
            }

            /*  
            Speedometer  
            */
            // draw
            drawSpeedometer(player, speedRui)

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
                setAlpha(weaponNameRui, settingsWeaponName.alpha * (1 - zoomFrac))
                RuiSetFloat(hudRui, "basicImageAlpha", settingsHud.alpha * (1 - zoomFrac))
                RuiSetFloat(nameHudRui, "basicImageAlpha", settingsNameHud.alpha * (1 - zoomFrac))
            }
            // draw ammo count
            drawAmmoCount(activeWeapon, ammoRui)
            
            /*
            Weapon name
            */
            /* 
            problem with:
            ALL TITAN WEAPONS AND ABILITIES
            40mm: should be: TITAN_40MM_TRACKER | is: STICKY_40MM
            particle: should be: TITAN_PARTICLE_ACCEL | is: PARTICLE_ACCELERATOR
            */
            string className = activeWeapon.GetWeaponClassName().toupper() // MP_WEAPON_EPG NEEDS TO BE WPN_NAME_SHORT
            array< string > asd = split(className, "_") // 0 = MP; 1 = WEAPON
            string name
            if(asd[0] == "MP" && !player.IsTitan()){
                name = "WPN"
                for(int i = 2; i < asd.len(); i += 1){
                    name += "_" + asd[i].toupper()
                }
                name += "_SHORT"
            } 
            else if (asd[1] == "TITANABILITY"){
                /*name = "WPN_TITANABILITY"
                for(int i = 2; i < asd.len(); i += 1){
                    name += "_" + asd[i].toupper()
                }
                printl(name) */
                name = "TITAN"
            } 
            else if(asd[1] == "TITANWEAPON"){
                /*name = "WPN_TITAN"
                for(int i = 2; i < asd.len(); i += 1){
                    name += "_" + asd[i].toupper()
                }*/
                name = "TITAN"
            }
            else {
                //name = className // debugging :(
                name = "" // dont show name if it cant be localized // TODO: localize this shit ughhh
            }
            RuiSetString(weaponNameRui, "msgText", name)
            
            
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
            setAlpha(weaponNameRui)
            RuiSetFloat(hudRui, "basicImageAlpha", 0.0)
            RuiSetFloat(nameHudRui, "basicImageAlpha", 0.0)
        }
    }
}

void function drawSpeedometer(entity player, var speedRui){
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
}

void function drawAmmoCount(entity activeWeapon, var ammoRui){ // TODO: maybe check how big the numbers are and alighn accordingly?
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
        ammoCountStr = currAmmo + "/" + maxAmmo
    }
    else { // melee
        ammoCountStr = "MELEE"
    }
    // draw ammo count
    RuiSetString(ammoRui, "msgText", ammoCountStr)
}

void function setAlpha(var rui, float alpha = 0.0){
    RuiSetFloat(rui, "msgAlpha", alpha)
}