<h4><code>dpm_tracking_urban_safety</code></h4>
<h3>Measuring urban traffic safety by tracking Deformable Parts Models</h3>



Getting started:
<pre>open a Matlab prompt
<b>compile_voc_release5</b> #only need to do this the 1st time.
<b>demo_sensys_dataset</b> #detect cars in Dir_2_Lane_3_285

see the images with the detected car bounding boxes in Dir_2_Lane_3_285_detections
look in <b>detectionDetails.mat</b> for the HOG features from the detected image and the HOGs from the DPM model
</pre>

Directory structure:
<pre>voc-release5 -- off-the-shelf Deformable Parts Model (DPM) code by Girshick, R. B. and Felzenszwalb, P. F. and McAllester, D.
sensys_models -- car model trained on Sensys urban traffic dataset
auxiliary_forTracking -- additional hooks into voc-release5 for tracking 
</pre>



