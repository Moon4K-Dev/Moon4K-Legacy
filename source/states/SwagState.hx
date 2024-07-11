package states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import game.Conductor;

class SwagState extends FlxUIState
{
	var curStep:Int = 0;
	var curBeat:Int = 0;

	override public function create()
	{
		super.create();
	}

	override public function update(elapsed:Float)
	{
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
			stepHit();

		super.update(elapsed);
	}

	public function transitionState(state:FlxState, ?noTransition:Bool = false)
	{
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		FlxTransitionableState.skipNextTransIn = noTransition;
		FlxTransitionableState.skipNextTransOut = noTransition;

		FlxG.switchState(state);
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / (16 / Conductor.timeScale[1]));
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}

		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		Conductor.recalculateStuff();

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);

		updateBeat();
	}

	public function stepHit():Void
	{
		if (curStep % Conductor.timeScale[0] == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		// do literally nothing dumbass
	}
}