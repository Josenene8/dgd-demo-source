package;

import flixel.graphics.frames.FlxFramesCollection;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.3.2'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = ['story mode', 'awards', 'options','discord','credits','freeplay']; //for layering
	var actualOrder:Array<String> = ['story mode', 'awards', 'options','freeplay','discord','credits'];

	//var yellow:FlxSprite;
	var magenta:FlxSprite;
	var hexagon:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var menuFrames:FlxFramesCollection;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		MASKstate.saveDataSetup();

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		FlxG.mouse.visible = true;

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		menuFrames = Paths.getSparrowAtlas('mainmenu/FNF_main_menu_assets');

		//var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(0,0);
		bg.frames = menuFrames;
		bg.animation.addByPrefix('yellow', 'yellow');
		bg.animation.play('yellow');
		//bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 3));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(0);
		//magenta.scrollFactor.set(0, yScroll);
		magenta.frames = menuFrames;
		magenta.animation.addByPrefix('pink', 'pink');
		magenta.animation.play('pink');
		magenta.setGraphicSize(Std.int(magenta.width * 3));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		add(magenta);

		
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);


		hexagon = new FlxSprite(0);
		//magenta.scrollFactor.set(0, yScroll);
		hexagon.frames = menuFrames;
		hexagon.animation.addByPrefix('Hexagon', 'Hexagon', 0, false);
		hexagon.animation.play('Hexagon');
		hexagon.updateHitbox();
		hexagon.screenCenter();
		hexagon.antialiasing = ClientPrefs.globalAntialiasing;
		add(hexagon);

		var star:Array<FlxSprite> = [];

		/*for (i in 0...3)
		{
			var gfx = 'endstar';
			if (!FlxG.save.data.ending[i]) gfx += '_e';

			star[i] = new FlxSprite().loadGraphic(Paths.image(gfx));
			star[i].scrollFactor.set();
			star[i].screenCenter(X);
			star[i].y = 0;
			star[i].x += (i - 1) * 90;
			star[i].scale.x = 0.75;
			star[i].scale.y = 0.75;
			star[i].antialiasing = true;
			add(star[i]);
		}*/

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 0);
			menuItem.frames = menuFrames;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItems.add(menuItem);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();

			switch(optionShit[i])
			{
				case "freeplay": 
					menuItem.y = FlxG.height - menuItem.height;
					menuItem.ID = 3;
				case "awards": 
					menuItem.y = menuItems.members[0].height - 5;
				case "options": 
					menuItem.y = menuItems.members[0].height + menuItems.members[1].height - 10;
				case "credits": 
					menuItem.ID = 5;
					menuItem.y = menuItems.members[1].y - 5;
					menuItem.x = FlxG.width - menuItem.width + 3;
				case "discord": 
					menuItem.ID = 4;
					menuItem.y = menuItems.members[2].y;
					menuItem.x = FlxG.width - menuItem.width + 3;
			}
		}

		//FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (!Achievements.achievementsUnlocked[achievementID][1] && leDate.getDay() == 5 && leDate.getHours() >= 18) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
			Achievements.achievementsUnlocked[achievementID][1] = true;
			giveAchievement();
			ClientPrefs.saveSettings();
		}
		#end
			
                #if android
	        addVirtualPad(UP_DOWN, A);
                #end
			
		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	var achievementID:Int = 0;
	function giveAchievement() {
		add(new AchievementObject(achievementID, camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement ' + achievementID);
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		#if debug
		if (FlxG.keys.pressed.SHIFT)
		{
			if (FlxG.keys.justPressed.ONE) FlxG.save.data.p_maskGot[0] = true;
			if (FlxG.keys.justPressed.TWO) FlxG.save.data.p_maskGot[1] = true;
			if (FlxG.keys.justPressed.THREE) FlxG.save.data.p_maskGot[2] = true;
			if (FlxG.keys.justPressed.FOUR) FlxG.save.data.p_maskGot[3] = true;
		}
		#end
		
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}



		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{

			if (FlxG.mouse.justPressed)
			{
				if (FlxG.mouse.overlaps(menuItems))
				{
					menuItems.forEach(function(spr:FlxSprite)
					{
						if (FlxG.mouse.overlaps(spr))
							curSelected = spr.ID;
					});
					selectItem();
				}
				
			}
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectItem();
				}
			}
		}

		super.update(elapsed);

		/*menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});*/
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		hexagon.animation.curAnim.curFrame = curSelected % 6;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.offset.y = 0;
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				//camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
				//spr.offset.x = 0.15 * (spr.frameWidth / 2 + 180);
				//spr.offset.y = 0.15 * spr.frameHeight;
				//FlxG.log.add(spr.frameWidth);
			}
		});
	}

	function selectItem()
	{
		selectedSomethin = true;
		FlxG.sound.play(Paths.sound('confirmMenu'));

		if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

		/*FlxTween.tween(hexagon, {alpha: 0}, 0.4, {
			ease: FlxEase.quadOut,
			onComplete: function(twn:FlxTween)
			{
				hexagon.kill();
			}
		});*/

		menuItems.forEach(function(spr:FlxSprite)
		{
			if (curSelected != spr.ID)
			{
				/*FlxTween.tween(spr, {alpha: 0}, 0.4, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						spr.kill();
					}
				});*/
			}
			else
			{
				FlxFlicker.flicker(spr, 1, 0.06, true, false, function(flick:FlxFlicker)
				{
					var daChoice:String = actualOrder[curSelected];

					switch (daChoice)
					{
						case 'story mode':
							FlxG.mouse.visible = false;
							MusicBeatState.switchState(new StoryMenuState());
						case 'freeplay':
							FlxG.mouse.visible = false;
							MusicBeatState.switchState(new FreeplayState());
						case 'awards':
							selectedSomethin = false;
							//FlxG.mouse.visible = false;
							//MusicBeatState.switchState(new AchievementsMenuState());
						case 'credits':
							FlxG.mouse.visible = false;
							MusicBeatState.switchState(new CreditsState());
						case 'options':
							FlxG.mouse.visible = false;
							MusicBeatState.switchState(new OptionsState());
						case 'discord': 
							selectedSomethin = false;
							CoolUtil.browserLoad('https://discord.gg/34QpVEndbM');
							//CoolUtil.browserLoad('');
					}
				});
			}
		});
	}
}
