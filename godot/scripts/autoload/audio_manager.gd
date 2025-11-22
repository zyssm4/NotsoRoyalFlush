extends Node

# Royal Rush 3D - Audio Manager
# Generates procedural sounds similar to the original game

var sample_rate: int = 44100

func play_sound(type: String) -> void:
	var player = AudioStreamPlayer.new()
	add_child(player)

	match type:
		"shuffle":
			player.stream = generate_shuffle_sound()
		"flip":
			player.stream = generate_flip_sound()
		"win":
			player.stream = generate_win_sound()
		"fail":
			player.stream = generate_fail_sound()
		"coin":
			player.stream = generate_coin_sound()
		"achievement":
			player.stream = generate_achievement_sound()
		"prestige":
			player.stream = generate_prestige_sound()

	player.play()
	player.finished.connect(func(): player.queue_free())

func generate_shuffle_sound() -> AudioStreamWAV:
	var duration = 0.1
	var samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(samples * 2)

	for i in range(samples):
		var t = float(i) / sample_rate
		var freq = lerp(200.0, 100.0, t / duration)
		var amplitude = lerp(0.3, 0.01, t / duration)
		var sample = sin(t * freq * TAU) * amplitude
		var value = int(sample * 32767)
		data[i * 2] = value & 0xFF
		data[i * 2 + 1] = (value >> 8) & 0xFF

	return create_wav_stream(data, samples)

func generate_flip_sound() -> AudioStreamWAV:
	var duration = 0.05
	var samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(samples * 2)

	for i in range(samples):
		var t = float(i) / sample_rate
		var freq = lerp(800.0, 1200.0, t / duration)
		var amplitude = lerp(0.2, 0.01, t / duration)
		var sample = sin(t * freq * TAU) * amplitude
		var value = int(sample * 32767)
		data[i * 2] = value & 0xFF
		data[i * 2 + 1] = (value >> 8) & 0xFF

	return create_wav_stream(data, samples)

func generate_win_sound() -> AudioStreamWAV:
	var duration = 0.6
	var samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(samples * 2)

	var frequencies = [523.25, 659.25, 783.99]

	for i in range(samples):
		var t = float(i) / sample_rate
		var sample = 0.0

		for j in range(frequencies.size()):
			var note_start = j * 0.1
			var note_end = note_start + 0.4
			if t >= note_start and t < note_end:
				var note_t = t - note_start
				var amplitude = lerp(0.2, 0.01, note_t / 0.4)
				sample += sin(t * frequencies[j] * TAU) * amplitude

		var value = int(clamp(sample, -1.0, 1.0) * 32767)
		data[i * 2] = value & 0xFF
		data[i * 2 + 1] = (value >> 8) & 0xFF

	return create_wav_stream(data, samples)

func generate_fail_sound() -> AudioStreamWAV:
	var duration = 0.3
	var samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(samples * 2)

	for i in range(samples):
		var t = float(i) / sample_rate
		var freq = lerp(300.0, 100.0, t / duration)
		var amplitude = lerp(0.3, 0.01, t / duration)
		var sample = sin(t * freq * TAU) * amplitude
		var value = int(sample * 32767)
		data[i * 2] = value & 0xFF
		data[i * 2 + 1] = (value >> 8) & 0xFF

	return create_wav_stream(data, samples)

func generate_coin_sound() -> AudioStreamWAV:
	var duration = 0.1
	var samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(samples * 2)

	for i in range(samples):
		var t = float(i) / sample_rate
		var freq = 1200.0 if t < 0.05 else 1600.0
		var amplitude = lerp(0.2, 0.01, t / duration)
		var sample = sin(t * freq * TAU) * amplitude
		var value = int(sample * 32767)
		data[i * 2] = value & 0xFF
		data[i * 2 + 1] = (value >> 8) & 0xFF

	return create_wav_stream(data, samples)

func generate_achievement_sound() -> AudioStreamWAV:
	var duration = 0.6
	var samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(samples * 2)

	var frequencies = [880.0, 1108.73, 1318.51]

	for i in range(samples):
		var t = float(i) / sample_rate
		var sample = 0.0

		for j in range(frequencies.size()):
			var note_start = j * 0.15
			var note_end = note_start + 0.3
			if t >= note_start and t < note_end:
				var note_t = t - note_start
				var amplitude = lerp(0.15, 0.01, note_t / 0.3)
				sample += sin(t * frequencies[j] * TAU) * amplitude

		var value = int(clamp(sample, -1.0, 1.0) * 32767)
		data[i * 2] = value & 0xFF
		data[i * 2 + 1] = (value >> 8) & 0xFF

	return create_wav_stream(data, samples)

func generate_prestige_sound() -> AudioStreamWAV:
	var duration = 0.7
	var samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(samples * 2)

	for i in range(samples):
		var t = float(i) / sample_rate
		var sample = 0.0

		for j in range(5):
			var note_start = j * 0.1
			var note_end = note_start + 0.3
			if t >= note_start and t < note_end:
				var note_t = t - note_start
				var freq = 400.0 + j * 200.0
				var amplitude = lerp(0.2, 0.01, note_t / 0.3)
				sample += sin(t * freq * TAU) * amplitude

		var value = int(clamp(sample, -1.0, 1.0) * 32767)
		data[i * 2] = value & 0xFF
		data[i * 2 + 1] = (value >> 8) & 0xFF

	return create_wav_stream(data, samples)

func create_wav_stream(data: PackedByteArray, samples: int) -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	return stream
