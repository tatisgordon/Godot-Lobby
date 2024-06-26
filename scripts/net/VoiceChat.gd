extends Node
@onready var player: AudioStreamPlayer = $AudioStreamPlayer
@onready var recorder: AudioStreamPlayer = $AudioStreamRecord
var effect: AudioEffectRecord
var recordActive: bool = false
var listenActive: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	var idx = AudioServer.get_bus_index("VCBus")
	effect = AudioServer.get_bus_effect(idx, 0)
	#effect.set_recording_active(false)
	set_process(false)


func onListenActive(toggle: bool):
	listenActive = toggle


func onRecordActive(toggle: bool):
	recordActive = toggle
	recorder.playing = toggle
	record()


func record():
	while recordActive:
		await get_tree().create_timer(0).timeout
		if multiplayer.multiplayer_peer and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED and recordActive:
			if not effect.is_recording_active():
				effect.set_recording_active(true)
				await get_tree().create_timer(0.5).timeout
				var recording := effect.get_recording()
				effect.set_recording_active(false)
				sendRecordData.rpc(recording.data)


@rpc("any_peer", "call_local", "unreliable", 99)
func sendRecordData(audioData: PackedByteArray):
	if listenActive:
		print("listening")
		var sample = AudioStreamWAV.new()
		sample.data = audioData
		sample.format = AudioStreamWAV.FORMAT_16_BITS
		sample.mix_rate = AudioServer.get_mix_rate()
		player.stream = sample
		player.play()
