#!/usr/bin/python

import sys
import numpy as np
from PIL import Image
import matplotlib.pyplot as plt  

def get_proj_xf_by_points(p, q):
	# AX = B
	a = np.array([
					 [ p[0][0], p[0][1], p[0][2], 0, 0, 0, 0, 0, 0, -q[0][0], 0, 0, 0 ],
					 [ p[1][0], p[1][1], p[1][2], 0, 0, 0, 0, 0, 0, 0, -q[1][0], 0, 0 ],
					 [ p[2][0], p[2][1], p[2][2], 0, 0, 0, 0, 0, 0, 0, 0, -q[2][0], 0 ],
					 [ p[3][0], p[3][1], p[3][2], 0, 0, 0, 0, 0, 0, 0, 0, 0, -q[3][0] ],
					 [ 0, 0, 0, p[0][0], p[0][1], p[0][2], 0, 0, 0, -q[0][1], 0, 0, 0 ],
					 [ 0, 0, 0, p[1][0], p[1][1], p[1][2], 0, 0, 0, 0, -q[1][1], 0, 0 ],
					 [ 0, 0, 0, p[2][0], p[2][1], p[2][2], 0, 0, 0, 0, 0, -q[2][1], 0 ],
					 [ 0, 0, 0, p[3][0], p[3][1], p[3][2], 0, 0, 0, 0, 0, 0, -q[3][1] ],
					 [ 0, 0, 0, 0, 0, 0, p[0][0], p[0][1], p[0][2], -q[0][2], 0, 0, 0 ],
					 [ 0, 0, 0, 0, 0, 0, p[1][0], p[1][1], p[1][2], 0, -q[1][2], 0, 0 ],
					 [ 0, 0, 0, 0, 0, 0, p[2][0], p[2][1], p[2][2], 0, 0, -q[2][2], 0 ],
					 [ 0, 0, 0, 0, 0, 0, p[3][0], p[3][1], p[3][2], 0, 0, 0, -q[3][2] ],
					 [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0]
				])

	b = np.array([ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1])

	x = np.linalg.solve(a, b)

	# get coefficients of projective transformation H
	h = np.array([
					[x[0], x[1], x[2]],
					[x[3], x[4], x[5]],
					[x[6], x[7], x[8]]
				])

	return h

def get_inv_xf(h):
	# get inverse of this transformation matrix H^-1
	inv_h = np.linalg.inv(h)
	return inv_h

def check_inside_rectangle(pixel, rectangle):
	# rectangle = (x_min, x_max, y_min, y_max)
	x_min, x_max, y_min, y_max = rectangle

	if pixel[0] < x_min or pixel[0] > x_max:
		return False
	if pixel[1] < y_min or pixel[1] > y_max:
		return False

	return True

def get_pixel_color(pixel, colors, width, height):
	rounded_pixel = (round(pixel[0]) % width, -round(pixel[1]) % height)

	return colors[rounded_pixel[0], rounded_pixel[1]]

def rp2_to_r2(pixel):
	norm = 1/pixel[2]
	return (pixel[0]*norm, pixel[1]*norm)

if __name__ == "__main__":
	texture = Image.open("texture.jpg")
	background = Image.open("background.jpg")
	width, height = texture.size
	p = [(0,0,1), (width-1,0,1), (width-1,height-1,1), (0,height-1,1)]
	q = [(236,247,1), (336,246,1), (337,61,1), (238,69,1)]

	if len(sys.argv) > 1:
		texture = Image.open(sys.argv[1])
		background = Image.open(sys.argv[2])
		width, height = texture.size
		p = [(0,0,1), (width-1,0,1), (width-1,height-1,1), (0,height-1,1)]
		pi = [int(sys.argv[i]) for i in range(3,11)]
		q = [(pi[0],pi[1],1), (pi[2],pi[3],1), (pi[4],pi[5],1), (pi[6],pi[7],1)]


	inv_h = get_inv_xf(get_proj_xf_by_points(p, q))

	bck_width, bck_height = background.size
	texture_dim = (0, width, 0, height)

	texture_colors = texture.load()
	background_colors = background.load()

	for x in range(bck_width):
		for y in range(bck_height):
			pixel = (x, y, 1)
			xformed_pixel = rp2_to_r2(np.dot(inv_h, pixel))

			if check_inside_rectangle(xformed_pixel, texture_dim):
				color = get_pixel_color(xformed_pixel, texture_colors, width, height)
				background.putpixel((x,y), color)

	background.save('return.jpg')






