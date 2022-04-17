# Piglets-Nursing-Level-Prediction

Automatic monitoring of livestock behavior is an indispensable
part of modern farming. It can assist framers in understanding
the status of livestock in real-time so as to avoid risks in advance.
Compared with other automatic monitoring approaches, such as
video or wearable devices, using structural vibration for monitoring
can ensure reliability and economy on the premise of including rich
information. We propose a pipeline to detect three nursing levels
of piglets based on the structural vibration using machine learning
methods represented by random forest. Hundreds of features from
the time domain and frequency domain with clear physical meaning
are extracted at first. The model-based, outcome-oriented feature
selection algorithm is implemented then to screen out the sensitive
features to the nursing level. It is shown that the statistics of some
frequency bands and the local variances in the time domain are
essential for detecting the piglet nursing level. After validation, the
features extracted through the algorithm still perform well under
other common machine learning models. The detection accuracy
(F1 score) of the final model with five critical features is up to 0.78
when our approach is deployed in the test set.
