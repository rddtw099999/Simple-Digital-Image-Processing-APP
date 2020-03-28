# -*- coding: utf-8 -*-
"""
Created on Mon May 27 23:43:36 2019

@author: ChouHsingTing
"""

import numpy as np
import matplotlib.pyplot as plt
from minisom import MiniSom

def returnImg(path):
    img = plt.imread(path)
    return img

def returnClustered(path, color):
    img = plt.imread(path)
    pixels = np.reshape(img, (img.shape[0]*img.shape[1], 3))/255
    som2 = MiniSom(1, int(color), 3, sigma=0.1, learning_rate=0.2)
    som2.random_weights_init(pixels)
    starting_weights = som2.get_weights().copy()
    som2.train_random(pixels, 500)
    qnt = som2.quantization(pixels)
    clustered = np.zeros(img.shape)
    for i, q in enumerate(qnt):
        clustered[np.unravel_index(i, (img.shape[0], img.shape[1]))] = q
    return clustered

def returnStartingWeights(path, color):
    img = plt.imread(path)
    pixels = np.reshape(img, (img.shape[0]*img.shape[1], 3))/255
    som2 = MiniSom(1, int(color), 3, sigma=0.1, learning_rate=0.2)
    som2.random_weights_init(pixels)
    starting_weights = som2.get_weights().copy()
    som2.train_random(pixels, 500)
    qnt = som2.quantization(pixels)
    clustered = np.zeros(img.shape)
    for i, q in enumerate(qnt):
        clustered[np.unravel_index(i, (img.shape[0], img.shape[1]))] = q
    return starting_weights

def returnSomWeight(path, color):
    img = plt.imread(path)
    pixels = np.reshape(img, (img.shape[0]*img.shape[1], 3))/255
    som2 = MiniSom(1, int(color), 3, sigma=0.1, learning_rate=0.2)
    som2.random_weights_init(pixels)
    starting_weights = som2.get_weights().copy()
    som2.train_random(pixels, 500)
    qnt = som2.quantization(pixels)
    clustered = np.zeros(img.shape)
    for i, q in enumerate(qnt):
        clustered[np.unravel_index(i, (img.shape[0], img.shape[1]))] = q
    return som2.get_weights()
