extends Node

# calculate similarity between 2 colors based on the RGB values
# RGB is not good for human perception similarity, but it seems to be a good approximation
# Black and white returns 0%
# same color returns 100%
# formula from stackoverflow (found the same on 2 posts)
func calculate_similarity(c_1: Color, c_2: Color):
	return (1 - ColorHelper.calculate_distance(c_1, c_2) / ColorHelper.calculate_distance(Color.BLACK, Color.WHITE)) * 100

func calculate_distance(c_1: Color, c_2: Color):
	var rmean = ( c_1.r8 + c_2.r8 ) / 2
	var r = c_1.r8 - c_2.r8
	var g = c_1.g8 - c_2.g8
	var b = c_1.b8 - c_2.b8
	return sqrt((((512+rmean)*r*r)>>8) + 4*g*g + (((767-rmean)*b*b)>>8))
