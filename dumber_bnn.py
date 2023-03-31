import tensorflow as tf
import numpy as np
from tensorflow.keras.datasets import mnist

# load data
(x_train, y_train), (x_test, y_test) = mnist.load_data()

# normalize images to binary
x_train = x_train.astype('float32') / 255.0
x_test = x_test.astype('float32') / 255.0

# swap from 2D array to 1D array
x_train = x_train.reshape(-1, 28*28)
x_test = x_test.reshape(-1, 28*28)

# one hot encoding
y_train = tf.keras.utils.to_categorical(y_train, num_classes=10)
y_test = tf.keras.utils.to_categorical(y_test, num_classes=10)

# define bnn
model = tf.keras.models.Sequential([
    tf.keras.layers.Dense(256, input_shape=(784,)), # multiply inputs
    tf.keras.layers.BatchNormalization(), # normalize layers
    tf.keras.layers.Activation('relu'), # switch -1's to 0
    tf.keras.layers.Dense(128),
    tf.keras.layers.BatchNormalization(),
    tf.keras.layers.Activation('relu'),
    tf.keras.layers.Dense(10),
    tf.keras.layers.Activation('softmax') # probability distribution
])

# initialize binary weights
binary_weights = model.get_weights()

# make weights binary
for i in range(len(binary_weights)):
    binary_weights[i] = np.where(binary_weights[i] >= 0, 1, -1)

model.set_weights(binary_weights)

# compile model
model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])

# train model with 10 layers
model.fit(x_train, y_train, epochs=10, batch_size=128, validation_data=(x_test, y_test))

# evaluate model
metrics = model.evaluate(x_test, y_test)
print("Test accuracy:", metrics[1])

# print binary weights
for layer in model.layers:
    if isinstance(layer, tf.keras.layers.Dense):
        binary_weights = layer.get_weights()
        binary_weights[0] = np.where(binary_weights[0] >= 0, 1, -1)
        layer.set_weights(binary_weights)
        print(layer.get_weights())