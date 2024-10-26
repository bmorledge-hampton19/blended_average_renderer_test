extends Control

enum Test {
	BLANK,
	SAME_COLOR_FULL_ALPHA, SAME_COLOR_HALF_ALPHA, SAME_COLOR_DIFFERENT_ALPHA,
	DIFFERENT_COLORS_FULL_ALPHA, DIFFERENT_COLORS_HALF_ALPHA, DIFFERENT_COLORS_DIFFERENT_ALPHA
}

@export var whichTest: Test # Used to run several premade tests
@export var backgroundColor := Color.BLACK
@export var maxRenderedObjects: float = 256.0 # Used as the denominator when building the density map

@export var background: ColorRect

# The three render layers
@export var densityMap: SubViewport # Records how many objects intersect at each position
@export var premultAlphaMap: SubViewport # Records mixed alpha of objects
@export var mainRenderer: CanvasGroup # Visible layer. Combines information from SubViewports.

# Packed scenes for the objects to be added to each layer.
@export var densityMapObjectPS: PackedScene
@export var premultAlphaObjectPS: PackedScene
@export var mainObjectPS: PackedScene

var haveMainObjectShaderParamsBeenSet := false

func _ready():

	# Duplicate the main object packed scene with a deep copy. This will allow us to set
	# shader parameters specific to this BlendedAverageRenderer. (E.g., the density map SubViewport)
	mainObjectPS = mainObjectPS.duplicate(true)

	# Initialize the main renderer's shader.
	mainRenderer.material.set_shader_parameter("premultAlphaMap", premultAlphaMap.get_texture())

	# Set the background color
	background.color = backgroundColor

	# Set the size of the subviewports to be equal to this object.
	densityMap.size = size
	premultAlphaMap.size = size

	# Determine which test to run.
	match whichTest:
		Test.BLANK:
			pass
		Test.SAME_COLOR_FULL_ALPHA:
			addObject(Vector2(450, 150), Vector2(200, 200), Color.BLUE)
			addObject(Vector2(550, 250), Vector2(200, 200), Color.BLUE)
			addObject(Vector2(600, 100), Vector2(200, 200), Color.BLUE)
		Test.SAME_COLOR_HALF_ALPHA:
			addObject(Vector2(450, 150), Vector2(200, 200), Color(0,0,1,0.5))
			addObject(Vector2(550, 250), Vector2(200, 200), Color(0,0,1,0.5))
			addObject(Vector2(600, 100), Vector2(200, 200), Color(0,0,1,0.5))
		Test.SAME_COLOR_DIFFERENT_ALPHA:
			addObject(Vector2(450, 150), Vector2(200, 200), Color(0,0,1,0.75))
			addObject(Vector2(550, 250), Vector2(200, 200), Color(0,0,1,0.5))
			addObject(Vector2(600, 100), Vector2(200, 200), Color(0,0,1,0.25))
		Test.DIFFERENT_COLORS_FULL_ALPHA:
			addObject(Vector2(450, 150), Vector2(200, 200), Color.BLUE)
			addObject(Vector2(550, 250), Vector2(200, 200), Color.GREEN)
			addObject(Vector2(600, 100), Vector2(200, 200), Color.RED)
		Test.DIFFERENT_COLORS_HALF_ALPHA:
			addObject(Vector2(450, 150), Vector2(200, 200), Color(0,0,1,0.5))
			addObject(Vector2(550, 250), Vector2(200, 200), Color(0,1,0,0.5))
			addObject(Vector2(600, 100), Vector2(200, 200), Color(1,0,0,0.5))
		Test.DIFFERENT_COLORS_DIFFERENT_ALPHA:
			addObject(Vector2(450, 150), Vector2(200, 200), Color(0,0,1,0.75))
			addObject(Vector2(550, 250), Vector2(200, 200), Color(0,1,0,0.5))
			addObject(Vector2(600, 100), Vector2(200, 200), Color(1,0,0,0.25))


func addObject(objectPosition: Vector2, objectSize: Vector2, objectColor: Color):
	
	# Add the object to the density map using additive blending on the red channel
	var densityMapObject: ColorRect = densityMapObjectPS.instantiate()
	densityMap.add_child(densityMapObject)
	densityMapObject.position = objectPosition
	densityMapObject.size = objectSize
	densityMapObject.color = Color(objectColor.a/maxRenderedObjects, 0, 0, 1)

	# Add the object to the mixed alpha map.
	var premultAlphaObject: ColorRect = premultAlphaObjectPS.instantiate()
	premultAlphaMap.add_child(premultAlphaObject)
	premultAlphaObject.position = objectPosition
	premultAlphaObject.size = objectSize
	premultAlphaObject.color = Color(1, 1, 1, objectColor.a)

	# Add the object to the main renderer.
	var mainObject: ColorRect = mainObjectPS.instantiate()
	mainRenderer.add_child(mainObject)
	mainObject.position = objectPosition
	mainObject.size = objectSize
	mainObject.color = objectColor

	# If this is the first object we've added, initialize the shader uniforms.
	if not haveMainObjectShaderParamsBeenSet:
		print("Setting shaders...")
		mainObject.material.set_shader_parameter("densityMap", densityMap.get_texture())
		mainObject.material.set_shader_parameter("maxRenderedObjects", maxRenderedObjects)
		print("Done!")
		haveMainObjectShaderParamsBeenSet = true
