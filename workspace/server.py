"""
main server program
"""

import numpy as np
from PIL import Image
import torch
import torch.nn.functional as F
import sys
import os

from torch.autograd import Variable

import transforms as transforms
from skimage import io
from skimage.transform import resize
import vgg

cut_size = 44

transform_test = transforms.Compose([
    transforms.TenCrop(cut_size),
    transforms.Lambda(lambda crops: torch.stack([transforms.ToTensor()(crop) for crop in crops])),
])

def rgb2gray(rgb):
    return np.dot(rgb[...,:3], [0.299, 0.587, 0.114])

raw_img = io.imread(sys.argv[1])
# print("raw_img",raw_img)
#print("raw_img", np.shape(raw_img))
gray = rgb2gray(raw_img)
#print("gray=",np.shape(gray))
gray = resize(gray, (48,48), mode='symmetric').astype(np.uint8)
#print("resized_gray=",np.shape(gray))
img = gray[:, :, np.newaxis]
#print("img1=",np.shape(img))
img = np.concatenate((img, img, img), axis=2)
#print("img2=",np.shape(img))
img = Image.fromarray(img)
#print("img3=",np.shape(img))
inputs = transform_test(img)

class_names = ['Angry', 'Disgust', 'Fear', 'Happy', 'Sad', 'Surprise', 'Neutral']

net = vgg.VGG('VGG19')

checkpoint = torch.load(os.path.join('FER2013_VGG19', 'PrivateTest_model_new.pt'), map_location=torch.device('cpu'))
net.load_state_dict(checkpoint['net'])
# net.cuda()
net.eval()

ncrops, c, h, w = np.shape(inputs)

inputs = inputs.view(-1, c, h, w)

# inputs = inputs.cuda()
inputs = Variable(inputs)
#print(np.shape(inputs))
outputs = net(inputs)
#print("outputs",outputs)
outputs_avg = outputs.view(ncrops, -1).mean(0)  # avg over crops
#print("outputs_avg",outputs_avg)
score = F.softmax(outputs_avg, dim=0)
#print("socre",score)
_, predicted = torch.max(outputs_avg.data, 0)

print("{\"value\": " + str(predicted.item()) + "}")
# print("The Expression is %s" %str(class_names[int(predicted.cpu().numpy())]))
