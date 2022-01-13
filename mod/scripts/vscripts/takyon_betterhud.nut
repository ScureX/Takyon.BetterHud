global function betterhudPrecache

/*
 *  SETTINGS
 */

struct{
    bool usesMetric = true //true: uses kph; false: uses mph
    bool colorFade = true // true: text color is red when you are slow and green when you are fast; false: static color which you can set below
    bool useStraightText = false
    vector position = Vector(0.0, 0.17, 0.0) //x axis: 0.0 is max left, 1.0 is max right; y axis: 0.0 is max top, 1.0 is max down; z doesn't do anything
    vector straightPosition = Vector(0 - 0.03, 0.15, 0.0)
    vector color = Vector(1.0, 0.55, 0.0) //standard rgb format, range: min - 0.0 to max - 1.0
    float alpha = 0.9 //maxiumum alpha of the text, range: 0.0 to 1.0
    float size = 350.0 //size of the text
    float straightSize = 350.0 // size of text when textTopo is used
} settingsSpeedometer

struct{
    bool colorFade = true // true: text color is red when you are slow and green when you are fast; false: static color which you can set below
    bool useStraightText = false
    vector position = Vector(0.68, 0.01, 0.0) //x axis: 0.0 is max left, 1.0 is max right; y axis: 0.0 is max top, 1.0 is max down; z doesn't do anything
    // For some reason ammo position is only 1/4th as far from the center as speedometer position. keep this in mind when aligning 
    vector chargePosition = Vector(0.68, 0.16, 0.0)
    vector straightPosition = Vector(0.68, 0 - 0.02, 0.0)
    vector straightChargePosition = Vector(0.68, 0.15, 0.0)
    vector color = Vector(1.2, 0.55, 0.0) //standard rgb format, range: min - 0.0 to max - 1.0
    float alpha = 0.9 //maxiumum alpha of the text, range: 0.0 to 1.0
    float size = 350.0 //size of the text
    float straightSize = 350.0 // size of text when textTopo is used
} settingsAmmocounter

struct{
    vector color = Vector(1.0, 1.0, 1.0) //standard rgb format, range: min - 0.0 to max - 1.0
    bool useStraightText = false
    vector position = Vector(0.04, 0 - 0.15, 0.0) //x axis: 0.0 is max left, 1.0 is max right; y axis: 0.0 is max top, 1.0 is max down; z doesn't do anything
    vector straightPosition = Vector(0 - 0.04, 0 - 0.09, 0.0)
    float alpha = 0.9 //maxiumum alpha of the text, range: 0.0 to 1.0
    float size = 210.0 //size of the text
    float straightSize = 213.0 // size of text when textTopo is used
} settingsWeaponName

struct{
    vector color = Vector(0.5, 0.5, 0.5) // Color of hud (the square background) 
    float alpha = 0.13 // opacity of hud
    float transformHorizontal = -0.15
    float transformVertical = 0
    float positionHorizontal = -31 
    float positionVertical = 20
    float hudHeight = 0.15
    float hudWidth = 0.18
} settingsHud

struct{
    vector color = Vector(0.23, 0.23, 0.23) // Color of hud (the square background) make this a bit darker than in settingsHud
    float alpha = 0.20 // opacity of hud
    float transformHorizontal = -0.15 // -0.15
    float transformVertical = 0
    float positionHorizontal = -31.8 
    float positionVertical = 14.0
    float hudHeight = 0.045
    float hudWidth = 0.20
} settingsNameHud

struct{
    vector colorPrimary = Vector(0.1, 0.1, 0.1)
    vector colorSecondary = Vector(0.5, 0.5, 0.5)
    float alphaPrimary = 0.20 
    float alphaSecorndary = 0.40 
    float transformHorizontal = -0.15
    float transformVertical = 0
    float positionHorizontal = -52.5
    float positionVertical = 20.0
    float hudHeight = 0.149
    float hudWidth = 0.017
} settingsOrdnanceBarHud

struct{
    vector colorPrimary = Vector(0.1, 0.1, 0.1)
    vector colorSecondary = Vector(0.5, 0.5, 0.5)
    float alphaPrimary = 0.20 
    float alphaSecorndary = 0.40 
    float transformHorizontal = -0.15
    float transformVertical = 0
    float positionHorizontal = -57.0
    float positionVertical = 20.0
    float hudHeight = 0.149
    float hudWidth = 0.017
} settingsAbilityBarHud

void function betterhudPrecache(){
    thread betterhudInit()
}

/*
 *  MAIN INITIALIZE FUNCTION
 */

void function betterhudInit(){
    WaitFrame()

    // Hud // the big square that acts as background
    var hudTopo = CreateRuiTopo(settingsHud.positionHorizontal, settingsHud.positionVertical, settingsHud.transformVertical, settingsHud.transformHorizontal, settingsHud.hudWidth, settingsHud.hudHeight)
    var hudRui = RuiCreate( $"ui/basic_image.rpak", hudTopo, RUI_DRAW_COCKPIT, 7 )
    hudInit(hudRui)

    // nameHud // The little box around the weapon name
    var nameHudTopo = CreateRuiTopo(settingsNameHud.positionHorizontal, settingsNameHud.positionVertical, settingsNameHud.transformVertical, settingsNameHud.transformHorizontal, settingsHud.hudWidth, settingsNameHud.hudHeight)
    var nameHudRui = RuiCreate( $"ui/basic_image.rpak", nameHudTopo, RUI_DRAW_COCKPIT, 8 )
    nameHudInit(nameHudRui)

    //OrdnanceBarHud
    var ordnanceBarTopo = CreateRuiTopo(settingsOrdnanceBarHud.positionHorizontal, settingsOrdnanceBarHud.positionVertical, settingsOrdnanceBarHud.transformVertical, settingsOrdnanceBarHud.transformHorizontal, settingsOrdnanceBarHud.hudWidth, settingsOrdnanceBarHud.hudHeight)
    var ordnanceBarSecondaryTopo = CreateRuiTopo(settingsOrdnanceBarHud.positionHorizontal, settingsOrdnanceBarHud.positionVertical, settingsOrdnanceBarHud.transformVertical, settingsOrdnanceBarHud.transformHorizontal, settingsOrdnanceBarHud.hudWidth, settingsOrdnanceBarHud.hudHeight)
    var ordnanceBarHud = RuiCreate( $"ui/basic_image.rpak", ordnanceBarTopo, RUI_DRAW_COCKPIT, 7 )
    var ordnanceBarSecondaryHud = RuiCreate( $"ui/basic_image.rpak", ordnanceBarSecondaryTopo, RUI_DRAW_COCKPIT, 8 )
    ordnanceBarHudInit(ordnanceBarHud, ordnanceBarSecondaryHud)

    //AbilityBarHud
    var abilityBarTopo = CreateRuiTopo(settingsAbilityBarHud.positionHorizontal, settingsAbilityBarHud.positionVertical, settingsAbilityBarHud.transformVertical, settingsAbilityBarHud.transformHorizontal, settingsAbilityBarHud.hudWidth, settingsAbilityBarHud.hudHeight)
    var abilityBarSecondaryTopo = CreateRuiTopo(settingsAbilityBarHud.positionHorizontal, settingsAbilityBarHud.positionVertical, settingsAbilityBarHud.transformVertical, settingsAbilityBarHud.transformHorizontal, settingsAbilityBarHud.hudWidth, settingsAbilityBarHud.hudHeight)
    var abilityBarHud = RuiCreate( $"ui/basic_image.rpak", abilityBarTopo, RUI_DRAW_COCKPIT, 7 )
    var abilityBarSecondaryHud = RuiCreate( $"ui/basic_image.rpak", abilityBarSecondaryTopo, RUI_DRAW_COCKPIT, 8 )
    abilityBarHudInit(abilityBarHud, abilityBarSecondaryHud)

    // Text topology // this is so the text isnt slanted. if you want slanted text change the textTopo to hudTopo when creating rui below
    var textTopo = CreateRuiTopo(settingsHud.positionHorizontal, settingsHud.positionVertical, 0, 0, settingsHud.hudHeight, settingsHud.hudWidth)

    var speedRui
    var ammoRui
    var weaponNameRui
    
    // Speedometer
    if(settingsSpeedometer.useStraightText)
        speedRui = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", textTopo, RUI_DRAW_COCKPIT, 9 ) // hudTopo for slanted, textTopo for straight
    else
        speedRui = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", hudTopo, RUI_DRAW_COCKPIT, 9 ) // hudTopo for slanted, textTopo for straight
    speedometerInit(speedRui)
    
    // Ammocounter
    if(settingsAmmocounter.useStraightText)
        ammoRui = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", textTopo, RUI_DRAW_COCKPIT, 9 ) // hudTopo for slanted, textTopo for straight
    else
        ammoRui = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", hudTopo, RUI_DRAW_COCKPIT, 9 ) // hudTopo for slanted, textTopo for straight
    ammoCounterInit(ammoRui)

    // WeaponName
    if(settingsWeaponName.useStraightText)
        weaponNameRui = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", textTopo, RUI_DRAW_COCKPIT, 9 ) // hudTopo for slanted, textTopo for straight
    else
        weaponNameRui = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", hudTopo, RUI_DRAW_COCKPIT, 9 ) // hudTopo for slanted, textTopo for straight
    weaponNameInit(weaponNameRui)

    thread betterhudMain(speedRui, ammoRui, hudRui, weaponNameRui, nameHudRui, ordnanceBarHud, abilityBarHud, ordnanceBarSecondaryHud, abilityBarSecondaryHud, ordnanceBarSecondaryTopo, abilityBarSecondaryTopo)
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

void function ordnanceBarHudInit(var ordnanceBarHud, var ordnanceBarSecondaryHud){
    RuiSetFloat3( ordnanceBarHud, "basicImageColor", settingsOrdnanceBarHud.colorPrimary)
    RuiSetFloat( ordnanceBarHud, "basicImageAlpha", settingsOrdnanceBarHud.alphaPrimary) 

    RuiSetFloat3( ordnanceBarSecondaryHud, "basicImageColor", settingsOrdnanceBarHud.colorSecondary) 
    RuiSetFloat( ordnanceBarSecondaryHud, "basicImageAlpha", settingsOrdnanceBarHud.alphaSecorndary)
}

void function abilityBarHudInit(var abilityBarHud, var abilityBarSecondaryHud){
    RuiSetFloat3( abilityBarHud, "basicImageColor", settingsAbilityBarHud.colorPrimary) 
    RuiSetFloat( abilityBarHud, "basicImageAlpha", settingsAbilityBarHud.alphaPrimary)

    RuiSetFloat3( abilityBarSecondaryHud, "basicImageColor", settingsAbilityBarHud.colorSecondary) 
    RuiSetFloat( abilityBarSecondaryHud, "basicImageAlpha", settingsAbilityBarHud.alphaSecorndary)
}

void function speedometerInit(var speedRui){
    RuiSetInt(speedRui, "maxLines", 1)
	RuiSetInt(speedRui, "lineNum", 1)
    if(settingsSpeedometer.useStraightText){
        RuiSetFloat2(speedRui, "msgPos", settingsSpeedometer.straightPosition) // can be straightPosition
        RuiSetFloat(speedRui, "msgFontSize", settingsSpeedometer.straightSize) // can be straightSize
    }
    else{
        RuiSetFloat2(speedRui, "msgPos", settingsSpeedometer.position) // can be straightPosition
        RuiSetFloat(speedRui, "msgFontSize", settingsSpeedometer.size) // can be straightSize
    }
	RuiSetString(speedRui, "msgText", "speed")
	RuiSetFloat(speedRui, "msgAlpha", settingsSpeedometer.alpha)
	RuiSetFloat(speedRui, "thicken", 0.0)
	RuiSetFloat3(speedRui, "msgColor", settingsSpeedometer.color)
}

void function ammoCounterInit(var ammoRui){
    RuiSetInt(ammoRui, "maxLines", 1)
	RuiSetInt(ammoRui, "lineNum", 1)
    if(settingsAmmocounter.useStraightText){
        RuiSetFloat2(ammoRui, "msgPos", settingsAmmocounter.straightPosition) // can be straightPosition
        RuiSetFloat(ammoRui, "msgFontSize", settingsAmmocounter.straightSize) // can be straightSize
    }
    else{
        RuiSetFloat2(ammoRui, "msgPos", settingsAmmocounter.position) // can be straightPosition
        RuiSetFloat(ammoRui, "msgFontSize", settingsAmmocounter.size) // can be straightSize
    }
    RuiSetString(ammoRui, "msgText", "ammo")
	RuiSetFloat(ammoRui, "msgAlpha", settingsAmmocounter.alpha)
	RuiSetFloat(ammoRui, "thicken", 0.0)
	RuiSetFloat3(ammoRui, "msgColor", settingsAmmocounter.color)
}

void function weaponNameInit(var weaponNameRui){
    RuiSetInt(weaponNameRui, "maxLines", 1)
	RuiSetInt(weaponNameRui, "lineNum", 1)
    if(settingsWeaponName.useStraightText){
        RuiSetFloat2(weaponNameRui, "msgPos", settingsWeaponName.straightPosition) // can be straightPosition
        RuiSetFloat(weaponNameRui, "msgFontSize", settingsWeaponName.straightSize) // can be straightSize
    }
    else{
        RuiSetFloat2(weaponNameRui, "msgPos", settingsWeaponName.position) // can be straightPosition
        RuiSetFloat(weaponNameRui, "msgFontSize", settingsWeaponName.size) // can be straightSize
    }
	RuiSetString(weaponNameRui, "msgText", "name")
	
	RuiSetFloat(weaponNameRui, "msgAlpha", settingsWeaponName.alpha)
	RuiSetFloat(weaponNameRui, "thicken", 0.0)
	RuiSetFloat3(weaponNameRui, "msgColor", settingsWeaponName.color)
}

/*
 *  MAIN FUNCTION LOOP
 */
void function betterhudMain(var speedRui, var ammoRui, var hudRui, var weaponNameRui, var nameHudRui, var ordnanceBarHud, var abilityBarHud, var ordnanceBarSecondaryHud, var abilityBarSecondaryHud, var ordnanceBarSecondaryTopo, var abilityBarSecondaryTopo){
    while(true){
        WaitFrame()
        if(!IsLobby()){
            entity player = GetLocalViewPlayer()
            entity activeWeapon = player.GetActiveWeapon()

            if (player == null || !IsValid(player) || !IsValid(activeWeapon))
			    continue
            
            // Hide weapon status
            ClWeaponStatus_SetWeaponVisible( false )

            // hide if dead or in dropship
            if(!IsAlive(player) || IsPlayerInDropship(player)){
                SetTextAlpha(speedRui)
                SetTextAlpha(ammoRui)
                SetTextAlpha(weaponNameRui)
                RuiSetFloat(hudRui, "basicImageAlpha", 0.0)
                RuiSetFloat(nameHudRui, "basicImageAlpha", 0.0)
                RuiSetFloat(ordnanceBarHud, "basicImageAlpha", 0.0)
                RuiSetFloat(abilityBarHud, "basicImageAlpha", 0.0)
                RuiSetFloat(ordnanceBarSecondaryHud, "basicImageAlpha", 0.0)
                RuiSetFloat(abilityBarSecondaryHud, "basicImageAlpha", 0.0)

                continue
            } else{
                SetTextAlpha(speedRui, settingsSpeedometer.alpha)
                SetTextAlpha(ammoRui, settingsAmmocounter.alpha)
                SetTextAlpha(weaponNameRui, settingsWeaponName.alpha)
                RuiSetFloat(hudRui, "basicImageAlpha", settingsHud.alpha)
                RuiSetFloat(nameHudRui, "basicImageAlpha", settingsNameHud.alpha)
                RuiSetFloat(ordnanceBarHud, "basicImageAlpha", settingsOrdnanceBarHud.alphaPrimary)
                RuiSetFloat(abilityBarHud, "basicImageAlpha", settingsAbilityBarHud.alphaPrimary)
                RuiSetFloat(ordnanceBarSecondaryHud, "basicImageAlpha", settingsOrdnanceBarHud.alphaSecorndary)
                RuiSetFloat(abilityBarSecondaryHud, "basicImageAlpha", settingsAbilityBarHud.alphaSecorndary)
            }

            /*
             *  HIDE ON ADS
             */
            // sets alpha based on zoom factor: while ads you dont see the hud 
            float zoomFrac = activeWeapon.GetWeaponOwner().GetZoomFrac() // 0 = zoomed out, anything above is zoomed in
            if(zoomFrac > 0){
                SetTextAlpha(speedRui, settingsSpeedometer.alpha * (1 - zoomFrac))
                SetTextAlpha(ammoRui, settingsAmmocounter.alpha * (1 - zoomFrac))
                SetTextAlpha(weaponNameRui, settingsWeaponName.alpha * (1 - zoomFrac))
                RuiSetFloat(hudRui, "basicImageAlpha", settingsHud.alpha * (1 - zoomFrac))
                RuiSetFloat(nameHudRui, "basicImageAlpha", settingsNameHud.alpha * (1 - zoomFrac))
                RuiSetFloat(ordnanceBarHud, "basicImageAlpha",  settingsOrdnanceBarHud.alphaPrimary * (1 - zoomFrac))
                RuiSetFloat(abilityBarHud, "basicImageAlpha",  settingsAbilityBarHud.alphaPrimary * (1 - zoomFrac))
                RuiSetFloat(ordnanceBarSecondaryHud, "basicImageAlpha",  settingsAbilityBarHud.alphaSecorndary * (1 - zoomFrac))
                RuiSetFloat(abilityBarSecondaryHud, "basicImageAlpha",  settingsAbilityBarHud.alphaSecorndary * (1 - zoomFrac))
            }

            /*  
             *  Speedometer  
             */
            drawSpeedometer(player, speedRui)

            /*  
             *  Ammo counter  
             */
            drawAmmoCount(activeWeapon, ammoRui)
            
            /*
             *  Weapon name
             */ 
            drawWeaponName(player, activeWeapon, weaponNameRui)

            /*
             *  Ordnance Bar
             */
            // apparently you cant get other peoples offhand so this will throw null? i think?? 
            entity offhand = player.GetOffhandWeapon(0)
            if(offhand != null){
                RuiTopology_UpdateSphereArcs( ordnanceBarSecondaryTopo, 
                COCKPIT_RUI_WIDTH*settingsOrdnanceBarHud.hudWidth, 
                (COCKPIT_RUI_HEIGHT*(settingsOrdnanceBarHud.hudHeight*offhand.GetWeaponPrimaryClipCount()/offhand.GetWeaponPrimaryClipCountMax())), 
                COCKPIT_RUI_SUBDIV ) // ERROR OFFHAND NULL??
            }
            // TODO Show when ready

            /*
             *  Ability Bar
             */
            entity ability = player.GetOffhandWeapon(OFFHAND_SPECIAL)
            // Grapple is fucking shit
            float maxGrapplePower = 100.0 // TODO this is bad
            if(ability.GetWeaponClassName() == "mp_ability_grapple"){
                if(offhand != null){
                    RuiTopology_UpdateSphereArcs( abilityBarSecondaryTopo, 
                    COCKPIT_RUI_WIDTH*settingsAbilityBarHud.hudWidth, 
                    (COCKPIT_RUI_HEIGHT*(settingsAbilityBarHud.hudHeight*player.GetSuitGrapplePower()/maxGrapplePower)), 
                    COCKPIT_RUI_SUBDIV )
                }
            }
            else {
                if(offhand != null){
                    RuiTopology_UpdateSphereArcs( abilityBarSecondaryTopo, 
                    COCKPIT_RUI_WIDTH*settingsAbilityBarHud.hudWidth, 
                    (COCKPIT_RUI_HEIGHT*(settingsAbilityBarHud.hudHeight*ability.GetWeaponPrimaryClipCount()/ability.GetWeaponPrimaryClipCountMax())), 
                    COCKPIT_RUI_SUBDIV )
                }
            }
            // TODO Show when ready
            
            /* 
            Healt bar 
            */
            //TODO // GetMaxHealth() // GetHealthFrac(player)
        }
        else{
            // Hide if in Lobby
            SetTextAlpha(speedRui)
            SetTextAlpha(ammoRui)
            SetTextAlpha(weaponNameRui)
            RuiSetFloat(hudRui, "basicImageAlpha", 0.0)
            RuiSetFloat(nameHudRui, "basicImageAlpha", 0.0)
            RuiSetFloat(ordnanceBarHud, "basicImageAlpha", 0.0)
            RuiSetFloat(abilityBarHud, "basicImageAlpha", 0.0)
            RuiSetFloat(ordnanceBarSecondaryHud, "basicImageAlpha", 0.0)
            RuiSetFloat(abilityBarSecondaryHud, "basicImageAlpha", 0.0)
        }
    }
}

/*
 *  HUD LOGIC
 */

void function drawSpeedometer(entity player, var speedRui){
    vector playerVelV = player.GetVelocity()
    float playerVel = sqrt(playerVelV.x * playerVelV.x + playerVelV.y * playerVelV.y)
    float playerVelNormal = playerVel * (0.274176/3)
    if(!settingsSpeedometer.usesMetric)
        playerVelNormal *= (0.621371)
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

    SetAmmoCounterStraightOrSlanted(ammoRui, settingsAmmocounter.useStraightText, activeWeapon.IsChargeWeapon())
    // ammo color change
    if( activeWeapon.IsChargeWeapon()){ // is chargeable
        currAmmo = activeWeapon.GetWeaponChargeFraction()
        maxAmmo = 1.0
        ammoCountStr =  int(currAmmo*100) + "%"
        if(settingsAmmocounter.colorFade)
            RuiSetFloat3(ammoRui, "msgColor", Vector(1.0 - (currAmmo/maxAmmo) , currAmmo/maxAmmo, 0.0)) 
    }
    else if(activeWeapon.GetWeaponPrimaryClipCountMax() > 0){ // is bullet // BAD FIX TODO
        currAmmo = float(activeWeapon.GetWeaponPrimaryClipCount())
        maxAmmo = float(activeWeapon.GetWeaponPrimaryClipCountMax())
        ammoCountStr = currAmmo + "\n" + maxAmmo
        if(settingsAmmocounter.colorFade)
            RuiSetFloat3(ammoRui, "msgColor", Vector(1.0 - (currAmmo/maxAmmo) , currAmmo/maxAmmo, 0.0)) 
    }
    else { // melee
        ammoCountStr = ""
    }
    // draw ammo count
    RuiSetString(ammoRui, "msgText", ammoCountStr)
}

void function drawWeaponName(entity player, entity activeWeapon, var weaponNameRui){
    string weaponClassName = activeWeapon.GetWeaponClassName();
    string weaponName = GetWeaponInfoFileKeyField_GlobalString( weaponClassName, "shortprintname" )
    RuiSetString(weaponNameRui, "msgText", weaponName)
}

/*
 *  HELPER FUNCTIONS
 */

void function SetTextAlpha(var rui, float alpha = 0.0){
    RuiSetFloat(rui, "msgAlpha", alpha)
}

var function CreateRuiTopo(float positionHorizontal, float positionVertical, float transformVertical, float transformHorizontal, float hudWidth, float hudHeight){
    var topo = RuiTopology_CreateSphere( 
        COCKPIT_RUI_OFFSET - <0, positionHorizontal, positionVertical>, // POSITION | in screen, left/right, up/down
        <0, -1, transformVertical>, // ?, ?, left side down right side up
        <0, transformHorizontal, -1>, // ?, bottom left top right, ?
        COCKPIT_RUI_RADIUS, 
        COCKPIT_RUI_WIDTH*hudWidth, 
        COCKPIT_RUI_HEIGHT*hudHeight, 
        3.5 // 3.5
    )
    return topo
}

bool function IsPlayerInDropship(entity player){
    if(player.GetParent() != null){
        return IsDropship(player.GetParent())
    }
    return false
}

void function SetAmmoCounterStraightOrSlanted(var rui, bool usesStraightText, bool isChargeWeapon){
    if(settingsAmmocounter.useStraightText){
        if(isChargeWeapon){
            RuiSetFloat2(rui, "msgPos", settingsAmmocounter.straightChargePosition)
            return
        }
        RuiSetFloat2(rui, "msgPos", settingsAmmocounter.straightPosition)
    }
    else {
        if(isChargeWeapon){
            RuiSetFloat2(rui, "msgPos", settingsAmmocounter.chargePosition)
            return
        }          
        RuiSetFloat2(rui, "msgPos", settingsAmmocounter.position)
    }
}