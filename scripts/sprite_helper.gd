extends Node

# Helper function to create SpriteFrames from a sprite sheet
# This assumes the sprite sheet is a horizontal strip of frames

static func create_sprite_frames_from_sheet(texture_path: String, frame_count: int = 6, frame_width: int = 32, fps: float = 8.0) -> SpriteFrames:
	var sprite_frames = SpriteFrames.new()
	var texture = load(texture_path)
	
	if texture == null:
		push_error("Failed to load texture: " + texture_path)
		return sprite_frames
	
	# Create animation
	sprite_frames.add_animation("idle")
	sprite_frames.set_animation_speed("idle", fps)
	sprite_frames.set_animation_loop("idle", true)
	
	# Extract frames from sprite sheet using AtlasTexture
	for i in range(frame_count):
		var atlas_texture = AtlasTexture.new()
		atlas_texture.atlas = texture
		atlas_texture.region = Rect2(i * frame_width, 0, frame_width, texture.get_height())
		sprite_frames.add_frame("idle", atlas_texture)
	
	return sprite_frames
