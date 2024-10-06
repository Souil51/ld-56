extends Node

enum Sounds { BONUS, END, MAIN, MERGE, PICK, RECYCLE, START, TEST_BAD, TEST_NORMAL, TEST_GOOD }

var sound_files = [
	"res://sounds/sound1.wav",
	"res://sounds/sound2.wav",
	"res://sounds/sound3.wav"
]

var dic_sound = {
	Sounds.BONUS: "res://sound/bonus.wav",
	Sounds.END: "res://sound/end.wav",
	Sounds.MAIN: "res://sound/main_song.wav",
	Sounds.MERGE: "res://sound/merge.wav",
	Sounds.PICK: "res://sound/pick.wav",
	Sounds.RECYCLE: "res://sound/recycle.wav",
	Sounds.START: "res://sound/start.wav",
	Sounds.TEST_BAD: "res://sound/test_bad.wav",
	Sounds.TEST_NORMAL: "res://sound/test_normal.wav",
	Sounds.TEST_GOOD: "res://sound/test_good.wav"
}

func play_sound(player: AudioStreamPlayer , sound: Sounds) -> void:
	# Load the audio stream from the given file path
	var audio_stream = load(dic_sound[sound]) as AudioStream
	if audio_stream:
		player.stream = audio_stream
		player.play()
	else:
		print("Error: Could not load sound file: ", sound)
